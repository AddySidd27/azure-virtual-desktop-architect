#!/usr/bin/env python3
"""Run repository checks that do not require Azure credentials."""

from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[1]
MARKDOWN_LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
MARKDOWN_HEADING = re.compile(r"^#{1,6}\s+(.+?)\s*#*$", re.MULTILINE)


def github_slug(heading: str) -> str:
    heading = re.sub(r"<[^>]+>", "", heading).strip().lower()
    heading = re.sub(r"[^\w\- ]", "", heading)
    return re.sub(r" +", "-", heading)


def markdown_anchors(document: Path) -> set[str]:
    anchors: set[str] = set()
    occurrences: dict[str, int] = {}
    text = document.read_text(encoding="utf-8")
    for heading in MARKDOWN_HEADING.findall(text):
        base = github_slug(heading)
        number = occurrences.get(base, 0)
        occurrences[base] = number + 1
        anchors.add(base if number == 0 else f"{base}-{number}")
    return anchors


def local_link_errors() -> list[str]:
    errors: list[str] = []
    anchor_cache = {document.resolve(): markdown_anchors(document) for document in ROOT.rglob("*.md")}
    for document in ROOT.rglob("*.md"):
        text = document.read_text(encoding="utf-8")
        for raw_target in MARKDOWN_LINK.findall(text):
            target = raw_target.strip().split(maxsplit=1)[0].strip("<>")
            if not target or target.startswith(("http://", "https://", "mailto:")):
                continue
            if target.startswith("#"):
                fragment = unquote(target[1:]).lower()
                if fragment and fragment not in anchor_cache[document.resolve()]:
                    errors.append(f"{document.relative_to(ROOT)}: missing anchor: {target}")
                continue
            path_text = unquote(target.split("#", 1)[0])
            if not path_text:
                continue
            resolved = (document.parent / path_text).resolve()
            try:
                resolved.relative_to(ROOT)
            except ValueError:
                errors.append(f"{document.relative_to(ROOT)}: link leaves repository: {target}")
                continue
            if not resolved.exists():
                errors.append(f"{document.relative_to(ROOT)}: missing target: {target}")
                continue
            if "#" in target and resolved.suffix.lower() == ".md":
                fragment = unquote(target.split("#", 1)[1]).lower()
                if fragment and fragment not in anchor_cache.get(resolved, set()):
                    errors.append(f"{document.relative_to(ROOT)}: missing anchor: {target}")
    return errors


def diagram_errors() -> list[str]:
    errors: list[str] = []
    architecture = ROOT / "diagrams" / "architecture"
    drawio = {path.stem for path in architecture.glob("*.drawio")}
    svg = {path.stem for path in architecture.glob("*.svg")}
    for name in sorted(drawio - svg):
        errors.append(f"diagrams/architecture/{name}.drawio: SVG export missing")
    for name in sorted(svg - drawio):
        errors.append(f"diagrams/architecture/{name}.svg: draw.io source missing")
    for path in sorted(architecture.glob("*.drawio")) + sorted(architecture.glob("*.svg")):
        try:
            ET.parse(path)
        except ET.ParseError as exc:
            errors.append(f"{path.relative_to(ROOT)}: invalid XML: {exc}")
    return errors


def sensitive_file_errors() -> list[str]:
    errors: list[str] = []
    forbidden_names = {"terraform.tfstate", "terraform.tfstate.backup", ".env"}
    forbidden_suffixes = {".pfx", ".p12", ".pem", ".key"}
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if path.name in forbidden_names or path.suffix.lower() in forbidden_suffixes:
            errors.append(f"{path.relative_to(ROOT)}: sensitive file type must not be committed")
        if path.name.endswith(".tfvars") and not path.name.endswith(".tfvars.example"):
            errors.append(f"{path.relative_to(ROOT)}: use a .tfvars.example file instead")
    return errors


def strip_hcl_comments(text: str) -> str:
    """Blank out #, // and /* ... */ comments, keeping strings and line breaks.

    Comment text becomes spaces so line numbers and layout are preserved.
    Block comments may span lines and are not treated as nesting. A quote that
    is still open at the end of a line is closed there.
    """
    out: list[str] = []
    in_string = False
    escaped = False
    in_block = False
    index = 0
    while index < len(text):
        char = text[index]
        if in_block:
            if text.startswith("*/", index):
                in_block = False
                index += 2
                out.append(" ")
            else:
                out.append("\n" if char == "\n" else " ")
                index += 1
        elif in_string:
            out.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char in '"\n':
                in_string = False
            index += 1
        elif char == '"':
            in_string = True
            out.append(char)
            index += 1
        elif char == "#" or text.startswith("//", index):
            while index < len(text) and text[index] != "\n":
                index += 1
        elif text.startswith("/*", index):
            in_block = True
            index += 2
            out.append(" ")
        else:
            out.append(char)
            index += 1
    return "".join(out)


def top_level_assignments(text: str) -> set[str]:
    """Return names assigned at nesting depth 0 in HCL variable-file text.

    Attributes nested inside objects or maps (for example the attributes of
    each entry in a `shares = { ... }` map) are not variables and are skipped.
    Comments (#, // and /* ... */) and string contents are ignored while
    counting brackets.
    """
    names: set[str] = set()
    depth = 0
    for line in strip_hcl_comments(text).splitlines():
        if depth == 0:
            match = re.match(r"\s*([A-Za-z_][A-Za-z0-9_]*)\s*=", line)
            if match:
                names.add(match.group(1))
        in_string = False
        escaped = False
        for char in line:
            if in_string:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    in_string = False
            elif char == '"':
                in_string = True
            elif char in "{[(":
                depth += 1
            elif char in "}])":
                depth = max(depth - 1, 0)
    return names


def terraform_variable_errors() -> list[str]:
    """Catch stale examples and simple variable-reference mistakes per root module."""
    errors: list[str] = []
    terraform_root = ROOT / "terraform"
    module_directories = sorted({path.parent for path in terraform_root.rglob("versions.tf")})
    for directory in module_directories:
        configuration = "\n".join(
            path.read_text(encoding="utf-8") for path in sorted(directory.glob("*.tf"))
        )
        declared = set(re.findall(r'variable\s+"([A-Za-z0-9_]+)"', configuration))
        referenced = set(re.findall(r"\bvar\.([A-Za-z0-9_]+)", configuration))
        for name in sorted(referenced - declared):
            errors.append(
                f"{directory.relative_to(ROOT)}: var.{name} is referenced but not declared"
            )
        for name in sorted(declared - referenced):
            errors.append(
                f"{directory.relative_to(ROOT)}: variable {name!r} is declared but not used"
            )

        example = directory / "terraform.tfvars.example"
        if example.exists():
            assigned = top_level_assignments(example.read_text(encoding="utf-8"))
            for name in sorted(assigned - declared):
                errors.append(
                    f"{example.relative_to(ROOT)}: {name!r} is not declared by this module"
                )
    return errors


def main() -> int:
    checks = {
        "local Markdown links": local_link_errors(),
        "draw.io and SVG diagrams": diagram_errors(),
        "Terraform variable references": terraform_variable_errors(),
        "sensitive file types": sensitive_file_errors(),
    }
    failed = False
    for name, errors in checks.items():
        if errors:
            failed = True
            print(f"FAIL: {name}")
            for error in errors:
                print(f"  - {error}")
        else:
            print(f"PASS: {name}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

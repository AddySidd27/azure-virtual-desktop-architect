# Contributing

This is primarily a solo-authored technical book, kept open for corrections because AVD changes fast enough that any single author will fall behind without them.

## The most valuable contribution: a technical correction

If Microsoft has changed a behaviour, retired a feature, or renamed something since a chapter was written, open an issue with:

1. The chapter, lab, or project file and section.
2. What the repository currently says.
3. A link to the current official Microsoft Learn page showing the correct behaviour.
4. The date you checked it.

Corrections with a Microsoft Learn link are actioned faster than corrections without one, because the standard for every technical claim in this repository is "verified against current Microsoft documentation," and a fix needs the same standard.

## Other welcome contributions

- A broken local or external link.
- A Terraform issue found by running `terraform validate` or reviewing a plan. The repository includes CI validation; see the [Terraform validation record](TERRAFORM-VALIDATION.md) for the current evidence boundary.
- A diagram that fails the topic-accuracy test described in [DIAGRAM-STANDARD.md](DIAGRAM-STANDARD.md): removing the title, does it still read as the correct topic.
- Typos and unclear passages, though see the note on scope below.

## What is unlikely to be accepted

- New chapters or projects outside the structure documented in [SUMMARY.md](SUMMARY.md) and the [book master plan](appendices/book-master-plan.md). This book follows a deliberate structure (see [Structure change 03](appendices/structure-change-03-project-led.md)); large unsolicited additions are more likely to conflict with planned content than to fit it.
- Rewrites of the prose style. See [STYLE-GUIDE.md](STYLE-GUIDE.md) before proposing stylistic changes; the voice is deliberate.
- Content that reproduces Microsoft's own diagrams, icon artwork, or documentation text verbatim. Paraphrase and link instead.

## How to submit

1. Fork the repository.
2. Make the change on a branch.
3. Open a pull request referencing the issue, if one exists, and the Microsoft Learn source for any technical claim.
4. Expect a request for a source link before a technical correction is merged.

## Security issues

Do not open a public issue for anything that looks like a real secret, credential, or private detail accidentally committed. Follow [SECURITY.md](SECURITY.md) instead.

# Glossary and Abbreviations

| Term | Meaning in this repository |
|---|---|
| AVD | Azure Virtual Desktop |
| Application group | AVD object that publishes a desktop or RemoteApps to assigned users or groups |
| Azure Compute Gallery | Service used to store, version, and replicate VM images |
| Azure Monitor Agent | Agent that sends configured guest monitoring data through a Data Collection Rule |
| BCDR | Business continuity and disaster recovery |
| Breadth-first | Load balancing that spreads new sessions across available hosts |
| Cloud Cache | FSLogix capability that works with multiple profile storage locations |
| Conditional Access | Microsoft Entra policy evaluation applied before access is granted |
| DCR | Data Collection Rule used by Azure Monitor Agent |
| Depth-first | Load balancing that fills hosts before using additional capacity |
| Drain mode | Session-host state that prevents new sessions while allowing controlled maintenance |
| FSLogix | Microsoft profile-container technology commonly used with AVD |
| Host pool | Collection of AVD session hosts with common configuration and load balancing |
| IaC | Infrastructure as code |
| Image | Standardized operating-system and application source used to create session hosts |
| Landing zone | Governed Azure environment that supplies subscriptions, identity, connectivity, policy, management, and security foundations |
| Microsoft Entra ID | Microsoft's cloud identity and access service |
| Multi-session | Windows Enterprise edition that supports multiple concurrent user sessions in Azure |
| PIM | Microsoft Entra Privileged Identity Management |
| Pooled host pool | Host pool in which users share session-host capacity |
| Personal host pool | Host pool that assigns a desktop to an individual user |
| RDP Shortpath | Direct UDP-based transport option between a supported client and session host |
| RemoteApp | An application published without presenting the full remote desktop |
| Reverse connect | AVD connection model in which the session host establishes outbound connectivity to the service |
| RPO | Recovery point objective, the acceptable amount of data loss measured in time |
| RTO | Recovery time objective, the target duration for restoring service |
| Session host | Windows VM or supported machine that runs user sessions and applications |
| Session host configuration | AVD-managed declaration used to create and update hosts in supported pooled host pools |
| Start VM on Connect | Capability that starts a deallocated host when a user needs capacity |
| Workspace | AVD object that presents associated application groups to users |

Primary reference: [Azure Virtual Desktop terminology](https://learn.microsoft.com/en-us/azure/virtual-desktop/terminology)

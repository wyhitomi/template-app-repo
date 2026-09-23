# Documentation

| Folder | Purpose | When to write |
|--------|---------|---------------|
| [`architecture/`](architecture/) | How the system is built **today**: context, containers, deployment, pipelines. | Keep it current with every significant change. |
| [`adr/`](adr/) | Architecture Decision Records: one immutable record per decision. | A decision is hard to reverse, affects structure, or was debated. |
| [`rfc/`](rfc/) | Requests for Comments: proposals open for discussion **before** building. | Cross-team impact, new infrastructure, public API/data changes. |

**Flow:** idea → RFC (discussion) → accepted → ADR(s) record the decisions → architecture docs updated to reflect reality.

Diagrams use [Mermaid](https://mermaid.js.org/) so they render on GitHub and diff cleanly.

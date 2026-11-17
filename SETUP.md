<!-- Seismic: https://ibm.seismic.com/Link/Content/DCMhGH8HMFdJ2G4QRdFjDJT6m438 -->

# IBM Pre-Sales Demo Builder — Setup Guide

---

## Quick Start (Recommended)

No terminal required. The unzipped folder is a ready-to-use Bob workspace.

1. **Unzip** this package to any folder on your machine.
2. **Open that folder** in your IDE (VS Code, Cursor, etc.) with Bob installed.
3. In Bob, click the **mode switcher** and select **IBM Pre-Sales Demo Builder**.
4. Paste the verification prompt below to confirm everything loaded correctly.
5. Start describing your demo use case — Bob will guide you from there.

---

## Verify

After switching to the mode, paste this into the Bob chat and send it:

```
Who are you and what can you help me build?
```

**Expected response:** Bob introduces itself as IBM DemoArchitect, describes its role building IBM pre-sales demo applications, and mentions capabilities like React/Carbon frontends and IBM API integrations — without asking clarifying questions first.

---

## Make It Global (Optional)

By default the mode is only available when you have this folder open. Run the install script once to make it available in **every** project you open in Bob.

**macOS / Linux:**

> If you extracted the ZIP using Finder (double-click), run this first:
> ```
> chmod +x install.sh
> ```

Then run:
```
bash install.sh
```

**Windows (PowerShell):**

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

Restart Bob after the script completes.

---

## MCP Servers

Three optional MCP servers are pre-configured in this package. `watsonx-orchestrate-docs` connects automatically with no credentials. Leave the placeholders as-is for 
`carbon-mcp` and `techzone` and the mode will still work without them.

---

## Troubleshooting

If the **IBM Pre-Sales Demo Builder** mode doesn't appear in the Bob mode switcher, close and reopen the folder in your IDE (or restart Bob).

---

## Package Contents

```
IBM-Demo-Builder/
├── .bob/
│   ├── custom_modes.yaml          ← Mode definition
│   ├── mcp.json                   ← MCP server config
│   ├── rules/
│   │   └── rules-ai-agent-safety/
│   │       └── ai-agent-safety.md
│   └── skills/
│       ├── carbon-mcp/
│       │   ├── SKILL.md
│       │   └── README.md
│       ├── ibm-watsonx.ai/
│       │   ├── SKILL.md
│       │   ├── README.md
│       │   └── references/        ← 6 reference guides
│       ├── techzone/
│       │   ├── SKILL.md
│       │   └── README.md
│       └── watsonx-orchestrate/
│           ├── SKILL.md
│           ├── README.md
│           └── references/        ← 8 reference guides + 2 scripts
├── demos/
│   └── new-demo/                  ← Your demo gets built here
│       ├── .env.example
│       ├── frontend/src/
│       │   ├── components/
│       │   ├── pages/
│       │   ├── services/
│       │   ├── context/
│       │   ├── data/mockResponses/
│       │   └── utils/
│       ├── backend/
│       │   ├── routers/
│       │   └── services/
│       └── scripts/
├── install.sh                     ← Global install (macOS/Linux)
├── install.ps1                    ← Global install (Windows)
└── SETUP.md                       ← This file
```

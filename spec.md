# Glaser

## Overview

**Glaser** is an AI-powered code review and commentary tool that uses Shopify’s [Roast](https://github.com/Shopify/roast) workflow engine to "roast" your codebase — not just by finding bugs and inefficiencies, but by delivering those insights with snark, wit, and a comedic edge inspired by Nikki Glaser.

It starts as a **CLI tool** that accepts a path to a local codebase or a GitHub URL and spins up an autonomous workflow of sub-agents to analyze, critique, and mock — all in good fun.

---

## Implementation Guide

### Foundation

This project uses [Roast by Shopify](https://shopify.engineering/introducing-roast) as the backbone for orchestrating intelligent, multi-agent code analysis workflows.

Start with grounding in:

* 📦 [https://github.com/Shopify/roast](https://github.com/Shopify/roast)
* 🧐 [https://shopify.engineering/introducing-roast](https://shopify.engineering/introducing-roast)

### Environment

* Language: TypeScript or Python (TBD based on Roast compatibility/preference)
* CLI Framework: `Ink` (if TS) or `Typer` (if Python)
* OpenAI or Anthropic API integration (for wit + code analysis)
* GitHub API (for remote repo support)

---

## Core Functionality

### 🏑 CLI Entry Point

```bash
glaser ./my-codebase
# or
glaser https://github.com/user/repo
```

Accepts:

* Local file path to codebase
* Remote GitHub repo URL (clone & cache locally)

Triggers a Roast workflow, passing the repo as the root subject of analysis.

---

### 🧠 Workflow Logic (Roast Agents)

Breaks down the codebase into key domains and assigns sub-agents accordingly:

1. **📝 Documentation Agent**

   * Reviews README, doc folders, and inline comments.
   * Flags missing or poor documentation.
   * Comments like:

     > "This README is more confused than your project's dependency tree."

2. **🧱 Code Quality Agent**

   * Splits repo into chunks (per file/module)
   * Looks for:

     * Dead code
     * Over-complex functions
     * Anti-patterns
     * Outdated syntax or bad practices
   * Example roast:

     > "This function is so long it should qualify for severance pay."

3. **📦 Dependency Agent**

   * Analyzes package.json / requirements.txt etc.
   * Looks for:

     * Vulnerabilities
     * Unused dependencies
     * Outdated packages
   * Example roast:

     > "You're still using Lodash? What is this, 2015?"

4. **🕵️ Bug Hunter Agent**

   * Uses LLMs to look for likely bugs, logic errors, or security flaws.
   * Tags files or lines with concerns.
   * Example roast:

     > "This logic is so broken it should come with a therapy dog."

---

### 🧹 Chunking Strategy

Large repos are chunked:

* By folder/module
* By file type
* By size threshold

Each chunk analyzed independently and in parallel where possible using Roast's fan-out features.

---

## Output

### 📜 Report Format

* Markdown or HTML report
* Structured like a roast script:

  * Sectioned by agent (Docs, Code, Deps, Bugs)
  * Roasts with accompanying links to file + line
  * Optionally allow “serious mode” toggle for raw issues without humor

### 📦 CLI Output

```bash
Glaser is roasting your code...

🔥 Roasting docs...
🔥 Roasting source code...
🔥 Roasting dependencies...
🔥 Lo
```


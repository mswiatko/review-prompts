# HOWTO: Running Review Prompts in Copilot and opencode

This guide covers installing and running the review prompts with two agents:
**GitHub Copilot in VS Code** and **opencode**. It also gives guidance on which
language model to pick for a given review.

## Choosing a Model

The review prompts are model-agnostic, but the multi-stage reviews (especially
`/kreview-sashiko` and `/kreview-sashiko-series`) benefit from stronger
reasoning models. Rough guidance:

| Model | Best for | Notes |
|-------|----------|-------|
| **Opus 5** | Deep, hard reviews where correctness matters most | Strongest reasoning; **high token usage** and slower. Use for final passes, subtle concurrency/locking bugs, and series reconciliation. |
| **Opus 4.8** | Everyday deep reviews | Efficient balance of reasoning quality and cost. A good default for `/kreview` and `/kreview-sashiko`. |
| **Sonnet 5** | First-pass / triage review | Fast and cheap; good for an initial sweep before escalating findings to an Opus model. |
| **Gemini 3.1 Pro (preview)** | Mailing-list-style review | Produces LKML-style inline review output; good fit for the `inline-template.md` report format. |

Suggested workflow: triage with **Sonnet 5**, do the main review with
**Opus 4.8**, escalate anything subtle or high-risk to **Opus 5**, and use
**Gemini 3.1 Pro** when you want a mailing-list-style writeup.

---

## GitHub Copilot in VS Code

Copilot support uses VS Code's native
[Agent Skills](https://code.visualstudio.com/docs/agent-customization/agent-skills)
standard. The installer writes each project skill and each slash command as a
`SKILL.md` under `~/.copilot/skills/`.

### Install

Run the installer on the machine whose home directory VS Code reads:

```bash
./setup.sh copilot <project>
```

Where `<project>` is `kernel`, `systemd`, or `iproute`. Repeat per project.

**Where to run it, by VS Code setup:**

- **Remote-SSH** to a Linux host: run it on the remote host (the VS Code server
  reads `~/.copilot/skills/` there). This is the simplest case.
- **Remote - WSL**: run it inside the WSL distro.
- **Native Windows (local)**: run it under Git Bash so `$HOME` maps to
  `C:\Users\<you>`. Note that Git-Bash-style paths (`/c/Users/...`) baked into
  the generated files may not resolve for the Windows agent; WSL or Remote-SSH
  is recommended instead.

### Verify

```bash
ls ~/.copilot/skills
grep -rl '{{' ~/.copilot/skills   # should print nothing (placeholders expanded)
```

In VS Code (reload the window first with **Developer: Reload Window**):

- Type `/` in Copilot Chat to see the commands: `/kreview`, `/kreview-sashiko`,
  `/kdebug`, `/kverify`, etc.
- Or open **Chat: Open Customizations** -> **Skills** tab to see the installed
  skills (`kernel`, and one per command).

### Run a review

- Pick a model in the Chat model picker (see [Choosing a Model](#choosing-a-model)).
- Open a chat in agent mode, then run a command, e.g.:
  - `/kreview` - deep-dive regression analysis of the top commit.
  - `/kreview-sashiko` - multi-stage single-commit review.
  - `/kreview-sashiko <commit>` or `/kreview-sashiko base..head` for a range.

The project context skill (e.g. `kernel`) is auto-loaded by relevance when you
work in that tree; the command skills are on-demand slash commands only.

> Note: `/kreview-sashiko-series` fans out one reviewer subagent per commit,
> which relies on subagent support. This is best run in opencode.

---

## opencode

opencode installs skills, slash commands, and subagents to your opencode config
directory.

### Install opencode

Install the opencode CLI using any of the following:

```bash
# Install script (Linux/macOS)
curl -fsSL https://opencode.ai/install | bash

# npm
npm install -g opencode-ai

# Homebrew (macOS/Linux)
brew install sst/tap/opencode
```

Verify the install and sign in / configure a provider:

```bash
opencode --version
opencode auth login   # configure your model provider (e.g. Anthropic, Google)
```

See the [opencode docs](https://opencode.ai/docs) for provider setup and other
install options.

### Install the prompts

```bash
./setup.sh opencode <project>
```

This writes to:

- Skills: `~/.config/opencode/skills/<project>/SKILL.md`
- Commands: `~/.config/opencode/commands/*.md`
- Subagents: `~/.config/opencode/agent/*.md`

### Verify

```bash
ls ~/.config/opencode/skills ~/.config/opencode/commands ~/.config/opencode/agent
```

### Run a review

Start opencode in the project tree (the project skill auto-loads), select a
model, and use the slash commands:

- `/kreview` - deep-dive regression analysis of the top commit.
- `/kreview-sashiko` - multi-stage single-commit review; accepts a `<commit>`
  or `base..head` range.
- `/kreview-sashiko-series base..head` - reviews a whole git range by fanning
  out one full per-commit reviewer subagent per commit. This is the recommended
  runtime for series reviews because opencode supports subagents.

---

## Reference

- Available commands per project: see [README.md](README.md).
- Kernel-specific details: see [kernel/README.md](kernel/README.md).

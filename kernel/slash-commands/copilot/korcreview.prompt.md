---
name: korcreview
description: "Deep dive kernel ORC regression analysis using orc.md"
agent: "agent"
---
MANDATORY: You MUST use read_file to load each of the following files at the
start of every review, even if you think you already have them in context from
a previous turn. Do not rely on memory or prior conversation state.

1. Read `{{KERNEL_REVIEW_PROMPTS_DIR}}/kernel/agent/orc.md`
2. Read `{{KERNEL_REVIEW_PROMPTS_DIR}}/kernel/technical-patterns.md`
3. Read `{{KERNEL_REVIEW_PROMPTS_DIR}}/kernel/subsystem/subsystem.md`

Then load any additional subsystem guides matched by subsystem.md.

If a git range is provided, it's meant for the false-positive-guide.md section

Using the orc.md prompt, do a deep dive regression analysis of the top commit,
or the provided patch/commit. Follow the full orchestrator protocol defined in
orc.md including all phases and output file requirements.

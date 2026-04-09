---
name: kreview
description: "Deep dive kernel commit regression analysis using review-core.md"
agent: "agent"
---
Read the prompt `{{KERNEL_REVIEW_PROMPTS_DIR}}/kernel/review-core.md`

If a git range is provided, it's meant for the false-positive-guide.md section

Using the prompt, do a deep dive regression analysis of the top commit, or the provided patch/commit

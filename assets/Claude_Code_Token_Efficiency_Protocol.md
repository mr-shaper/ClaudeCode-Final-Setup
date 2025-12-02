# Claude Code Protocol: The Art of Token Efficiency
> **Version**: 1.0 (The "Precision" Edition)
> **Target Audience**: Claude Code Users, AI Agents, Efficiency Maximiners
> **Objective**: Maximize Coding Velocity while Minimizing Token Consumption & Cost.
> **Motto**: "Context is Currency. Spend it Wisely."

---

## Table of Contents

1.  [The Core Philosophy](#1-the-core-philosophy)
2.  [The Tool Arsenal](#2-the-tool-arsenal)
3.  [Operational Workflows](#3-operational-workflows)
4.  [Anti-Patterns (The "Seven Deadly Sins")](#4-anti-patterns)
5.  [Emergency Recovery](#5-emergency-recovery)

---

## 1. The Core Philosophy

### 1.1 The Token as Currency
In Claude Code, every line of history is a tax on your next turn.
*   **Cost**: More tokens = Higher cost ($) + Slower latency.
*   **Accuracy**: "Lost in the Middle" applies here too. A 100k token session with 90k tokens of old `ls` output makes Claude dumber.
*   **Rule**: If a piece of information is not needed for the *next* prompt, it is pollution.

### 1.2 The "Spoon-Feeding" Principle
Claude Code is smart, but it lacks object permanence. It only knows what is in the current context window.
*   **Bad**: "Fix the bug in the auth module." (Claude reads 50 files to find it).
*   **Good**: "Fix the `login` function in `src/auth.ts`. Here is the error log." (Claude reads 1 file).

---

## 2. The Tool Arsenal

### 2.1 The Constitution: `CLAUDE.md`
This is your project's "System Prompt". It is injected into every session.
*   **Purpose**: Define style, architecture, and common commands.
*   **Best Practice**: Keep it under 200 lines. High-density information only.
    *   Build commands (`npm run build`)
    *   Test commands (`npm test`)
    *   Lint rules
    *   Project structure summary

### 2.2 The Scalpel: Explicit Context (`@`)
Never let Claude guess what files to read.
*   **Usage**: `claude "Refactor this function" @src/utils.py`
*   **Effect**: Forces Claude to focus *only* on the tagged files + `CLAUDE.md`.
*   **Pro Tip**: Use globs carefully. `@src/**/*.ts` might blow up your context.

### 2.3 The Reset Button: `/clear` & `/compact`
*   **`/compact`**: Summarizes the conversation history. Use this every 5-10 turns.
*   **`/clear`**: Wipes history completely but keeps the files loaded. Use this when switching tasks (e.g., from "Debugging" to "Feature Implementation").
    *   *Analogy*: Cleaning your desk before starting a new project.

### 2.4 The Inspector: `/context`
*   **Usage**: Check what is currently in Claude's brain.
*   **Rule**: If you see files you haven't touched in 10 turns, run `/clear`.

---

## 3. Operational Workflows

### 3.1 The "Plan-Approve-Execute" (PAE) Pattern
**For Feature Development**

1.  **Plan**: `claude "Create a plan to implement X. List necessary file changes."`
    *   *Cost*: Low (Text generation).
2.  **Review**: User approves the plan.
3.  **Execute**: `claude "Implement step 1 of the plan."`
    *   *Cost*: Medium (Code generation).
4.  **Iterate**: Repeat for subsequent steps.
    *   *Why*: Prevents Claude from generating 500 lines of wrong code that you have to pay to read and fix.

### 3.2 The "Search-Drill-Fix" (SDF) Pattern
**For Bug Fixing**

1.  **Search**: `claude "Find files related to UserAuthentication."` (Claude uses `ls`, `grep`).
2.  **Drill**: `claude "Read src/auth/User.ts and explain the login logic."`
3.  **Fix**: `claude "Fix the logic error in line 45 of src/auth/User.ts."`
    *   *Efficiency*: You only load the file *after* you know it's the right one.

### 3.3 The "One-Shot Script" Pattern
**For Data/Refactoring**

Instead of asking Claude to edit 50 files manually:
1.  **Prompt**: "Write a Python script to rename variable `x` to `y` in all `.py` files."
2.  **Verify**: Read the script.
3.  **Run**: Execute the script yourself (or let Claude run it).
4.  **Result**: 1 turn, 50 files changed. Zero context pollution from opening 50 files.

---

## 4. Anti-Patterns (The "Seven Deadly Sins")

1.  **The "Implicit Context"**: Asking "Why is it broken?" without providing error logs or file paths.
    *   *Result*: Claude guesses, hallucinates, or asks clarifying questions (wasting turns).
2.  **The "Infinite Scroll"**: Never running `/clear`.
    *   *Result*: Context fills up with garbage. Latency spikes. IQ drops.
3.  **The "Mega-Prompt"**: Pasting 500 lines of code into the prompt instead of using `@filename`.
    *   *Result*: Hard to read, messes up formatting.
4.  **The "Blind Trust"**: Letting Claude run `rm -rf` or broad `sed` commands without review.
    *   *Result*: Data loss.
5.  **The "IDE Overload"**: Using the VS Code extension for everything.
    *   *Result*: IDEs often send hidden context (linters, open tabs) that bloats usage. Terminal is leaner.
6.  **The "Premature Optimization"**: Spending 10 turns optimizing a script that runs once.
    *   *Result*: Token cost > Compute savings.
7.  **The "Zombie Session"**: Leaving a session open for days.
    *   *Result*: Context drift. Just start a new session.

---

## 5. Emergency Recovery

**Trigger**: Claude is hallucinating or stuck in a loop.

**Procedure**:
1.  **Stop**: Ctrl+C.
2.  **Clear**: Run `/clear`.
3.  **Restate**: "We are working on [Task]. Here is the current state of [File]. Please continue."
4.  **Re-seed**: If needed, re-add context with `@file`.

---

**End of Protocol.**
*Efficiency is not just about saving money; it's about saving your attention.*

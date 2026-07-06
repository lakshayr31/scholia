# scholia

Render Claude Code's long-form output as self-contained, commentable HTML — then comment inline, copy, and paste the comments back to Claude to revise. Local-first, with zero runtime dependencies beyond a POSIX shell and a browser.

## What it does

When Claude is about to hand you a substantial document — a plan, report, research write-up, or comparison — scholia renders it as a single commentable HTML file in `./.claude-output/` and opens it in your browser. You leave anchored feedback by:

- hovering any line and clicking the gutter `+` to comment on that whole line, or
- selecting any span of text and clicking **+ Add comment**.

Comments live in your browser (localStorage) and survive a reload. When you're done, click **Copy comments** (top right). That puts a self-instructing block on your clipboard: paste it back into any Claude chat and Claude revises the document and regenerates the HTML. No server, no account, no database.

## Install

Two commands inside Claude Code (replace `<owner>` with the GitHub owner or org that hosts this repo):

```
/plugin marketplace add <owner>/scholia
/plugin install scholia@scholia
```

`scholia@scholia` reads as `plugin-name@marketplace-name` — both happen to be named `scholia`.

## Use

**Automatic.** Just ask Claude for something substantial — "write a plan for X", "research Y and compare the options". When the reply is a long, multi-section document, scholia renders and opens it for you. Short answers, snippets, and normal chat are left as plain text.

**Explicit.** Ask for it by name:

```
/scholia:scholia a plan for the payments migration
```

Plugin skills are namespaced `plugin:skill`; here both are `scholia`.

## The comment → paste → revise loop

1. Claude generates the doc and opens it in your browser.
2. Comment on lines (`+`) and spans (**+ Add comment**). Manage them in the right-hand sidebar — Jump, Edit, Delete.
3. Click **Copy comments**.
4. Paste the copied block back into chat. It begins with a one-line instruction, so Claude knows to revise and regenerate even in a fresh chat with no personal setup.
5. Claude applies your comments and reopens the updated doc. A new version stamp retires the old comments so nothing mis-anchors.

## Turning off auto-invoke

Scholia auto-selects when Claude is about to produce a substantial multi-section document. To use it on demand only:

- Add a line to your `CLAUDE.md` (project- or user-level `~/.claude/CLAUDE.md`): *"Only use the scholia skill when I explicitly ask for it."* Claude honours instruction files when deciding whether to auto-invoke a skill.
- Or disable the plugin from `/plugin` (Manage plugins → scholia) and re-enable it when you want it.
- Advanced (your own fork): set `disable-model-invocation: true` in `plugins/scholia/skills/scholia/SKILL.md`. That blocks auto-selection while keeping the explicit `/scholia:scholia` command available.

## Platform notes

Generation is pure shell plus Read/Write/Edit — no Python or Node required. Opening the browser is handled by `scripts/open-browser.sh`, which uses `open` on macOS, `xdg-open` on Linux (including WSL, whose `$OSTYPE` is `linux-gnu*`), and `start` on Windows (Git Bash / Cygwin).

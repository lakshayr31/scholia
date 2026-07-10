# scholia

Render Claude Code's long-form output as **self-contained, commentable HTML** — then **comment inline, copy, and paste the comments back to Claude to revise**. **Local-first**, with zero runtime dependencies beyond a POSIX shell and a browser.

## What it does

When Claude is about to hand you a **substantial document** — a plan, report, research write-up, or comparison — scholia renders it as a **single commentable HTML file** in `./.claude-output/` and **opens it in your browser**. You leave anchored feedback by:

- hovering any line and clicking the gutter `+` to comment on that whole line, or
- selecting any span of text and clicking **+ Add comment**.

Selecting text **highlights every whole block it touches** (line, paragraph, or list item) in yellow with a numbered badge; the gutter `+` comments a single line. Comments **live in your browser** (localStorage) and survive a reload. When you're done, click **Copy comments** (top right). That puts a **self-instructing block** on your clipboard: paste it back into any Claude chat and Claude **revises the document and regenerates the HTML**. No server, no account, no database.

Keyboard: **Cmd/Ctrl+Enter** saves a comment, **Esc** cancels.

## Features

- **Comment anywhere** — click the gutter `+` for a whole line, or select text to highlight every block it touches (line, paragraph, list item).
- **Paste-back revision loop** — one **Copy comments** button produces a self-instructing block; paste it into any Claude chat and the doc is revised and reopened, same filename.
- **Comments that carry over** — a regeneration keeps your comments; each is marked carried-over with a **Resolve** button and a **"How it was addressed"** note from Claude.
- **Open / Resolved tabs** — resolve, reopen, resolve-all, and clear-resolved; resolved comments drop out of the next copy.
- **Local-first** — comments live in your browser; no server, account, or database. No runtime deps beyond a POSIX shell and a browser.

## Install

Two commands inside Claude Code (replace `<owner>` with the GitHub owner or org that hosts this repo):

```
/plugin marketplace add <owner>/scholia
/plugin install scholia@scholia
```

`scholia@scholia` reads as `plugin-name@marketplace-name` — both happen to be named `scholia`.

## Use

**Automatic.** Just ask Claude for something substantial — "write a plan for X", "research Y and compare the options". When the reply is a long, multi-section document, scholia **renders and opens it for you**. Short answers, snippets, and normal chat are left as plain text.

**Explicit.** Ask for it by name:

```
/scholia:scholia a plan for the payments migration
```

Plugin skills are namespaced `plugin:skill`; here both are `scholia`.

## The comment → paste → revise loop

1. Claude **generates the doc and opens it** in your browser.
2. **Comment** on lines (`+`) and spans (**+ Add comment**). Manage them in the right-hand sidebar — Jump, Edit, Delete.
3. Click **Copy comments**.
4. **Paste the copied block back into chat.** It begins with a one-line instruction, so Claude knows to revise and regenerate even in a fresh chat with no personal setup.
5. Claude **applies your comments and reopens the updated doc** — with the **same filename**, so your comment thread stays intact.

## Comments that carry over

When Claude regenerates the doc, your comments don't disappear — they **carry over** and you track each to done:

- Every prior comment reappears marked **carried-over** (a "↻") with a **Resolve** button. Fresh comments made on the current version have no Resolve button.
- Each carried-over comment shows a **"How it was addressed"** note — Claude's one-line summary of what it changed — so you can confirm the fix in place, then **Resolve** it.
- Resolved comments move to a **Resolved** tab, are excluded from the next **Copy comments**, and can be **Reopen**ed. **Resolve all carried-over** and **Clear resolved** handle them in bulk.
- If Claude removed the text a comment was on, the comment goes **detached**: it stays in the list (still resolvable) with no highlight.

## Turning off auto-invoke

Scholia auto-selects when Claude is about to produce a substantial multi-section document. To use it on demand only:

- Add a line to your `CLAUDE.md` (project- or user-level `~/.claude/CLAUDE.md`): *"Only use the scholia skill when I explicitly ask for it."* Claude honours instruction files when deciding whether to auto-invoke a skill.
- Or disable the plugin from `/plugin` (Manage plugins → scholia) and re-enable it when you want it.
- Advanced (your own fork): set `disable-model-invocation: true` in `plugins/scholia/skills/scholia/SKILL.md`. That blocks auto-selection while keeping the explicit `/scholia:scholia` command available.

## Platform notes

Generation is pure Read/Write/Edit plus a single directory-create — no Python or Node required. To display the finished file, Claude opens it directly with the platform-appropriate command: `open` on macOS, `xdg-open` on Linux (including WSL, which takes the Linux path), and `start` on Windows (Git Bash / Cygwin).

## Contributing

Issues and pull requests are welcome. Fork the repo, branch, and open a PR — `main` is protected, so every change is merged only after the maintainer reviews and approves it. Please keep the template a single self-contained HTML file (inline CSS + vanilla JS, no external dependencies); that constraint is the point of the project.

## License

MIT — see [LICENSE](LICENSE).

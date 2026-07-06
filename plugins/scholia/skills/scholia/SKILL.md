---
name: scholia
description: Render a substantial, multi-section document — a plan, report, research write-up, comparison, design doc, or similar — as a self-contained commentable HTML file and open it in the browser so the user can leave anchored inline comments and paste them back for revision. Use this when you are about to hand the user a long, structured document, or when the user explicitly asks for scholia or a "commentable" / "annotatable" version. Do NOT use it for short answers, quick code snippets, single-paragraph replies, small edits, or ordinary conversation.
allowed-tools: Read, Write, Edit, Bash(${CLAUDE_PLUGIN_ROOT}/scripts/open-browser.sh *), Bash(open *), Bash(xdg-open *), Bash(start *)
---

# scholia — commentable document generator

Turn a substantial document you are about to produce into a single self-contained
commentable HTML file and open it in the user's browser. The user comments inline,
clicks "Copy comments," and pastes a self-instructing block back into chat; you then
revise and regenerate. Local-first — no server, no dependencies beyond a POSIX shell.

## Guardrail — when to invoke

Use scholia when the output is a **substantial, multi-section document**: a plan,
report, research write-up, comparison, design doc, or anything with several sections
or headings that the user will want to read and give feedback on. Also use it whenever
the user explicitly asks (e.g. `/scholia:scholia ...` or "make this commentable").

Do NOT use it for short answers, quick code snippets, single-paragraph replies, small
edits, or normal conversation. When it is borderline, prefer NOT generating — the user
can always force it explicitly.

## Generation procedure

1. **Draft the document content first**, structured so the comment engine can anchor to it:
   - one `<h1>` title and one `<p class="summary">` one-liner,
   - an optional `<nav class="toc">` table of contents,
   - one `<section id="...">` per major section. Every section MUST have a **unique
     `id`** and start with an `<h2>` — the comment engine derives each comment's section
     from the nearest `section[id]` and its `<h2>`.
   - inside each section: a bold lead sentence `<p class="lead"><strong>…</strong></p>`,
     1–3 lines of visible context, and dense material (tables, code, long lists) tucked
     into `<details><summary>…</summary>…</details>`.

2. **Pick `type` and `topic`.** `type` is the closest of: `plan`, `report`, `research`,
   `compare`, `explore`, `review`, `explain`. `topic` is a short kebab-case slug. Build
   the filename `<type>_<topic>_<YYYY-MM-DD>.html` using today's date. If that name
   already exists and this is a NEW document (not a revision), append `_2`, `_3`, ….

3. **Ensure the output directory exists** (run from the user's cwd):
   `mkdir -p ./.claude-output`

4. **Confirm `${CLAUDE_PLUGIN_ROOT}` is set.** If it is empty or unset, STOP and tell the
   user the plugin root is unavailable — do NOT write a partial or broken file.

5. **Copy the bundled template** to the target path:
   `cp "${CLAUDE_PLUGIN_ROOT}/templates/scholia-template.html" ./.claude-output/<filename>`
   (If `cp` is not permitted, Read the template and Write the identical bytes to the target.)

6. **Inject a unique version stamp.** In the copied file, replace the empty `content` of
   `<meta name="scholia-doc-version" content="">` with a value unique to THIS generation —
   a Unix timestamp, an ISO timestamp, or a short content hash. This stamp scopes the
   browser's saved comments; it MUST change on every generation and regeneration, otherwise
   stale comments will reload and mis-anchor.

7. **Fill the template** with Edit (leave the comment machinery alone):
   - `<title>__TITLE__</title>` → the document title,
   - the block between `<!-- CONTENT START -->` and `<!-- CONTENT END -->` (it holds
     `<h1>__TITLE__</h1>`, `<p class="summary">__SUMMARY__</p>`, and a demo section) →
     your real content: the `<h1>` title, the `<p class="summary">` one-liner, the optional
     TOC, and the sections from step 1.
   - Do NOT touch the `<style>`, the `<script>`, `<header class="bar">`,
     `<aside class="sidebar">`, the selection toolbar, or the compose popup — those power
     the commenting. Keep the `<head>` `<title>` in sync with the `<h1>`.

8. **Open it in the browser:**
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/open-browser.sh" "./.claude-output/<filename>"`

9. **Tell the user, briefly:** the doc is open in the browser; hover any line for the gutter
   `+` or select text to comment on a span; when done, click **Copy comments** (top right)
   and paste the block back into chat to revise.

## Revision behaviour

When the user pastes a block that begins with the self-instructing header:

`The comments below are anchored feedback on ` + "`<filename>`" + `. Please revise the document to address each comment, then regenerate the commentable HTML (same filename).`

then:

1. Read each entry — index, `Line`/`Span`, section title, the quoted anchor, and the comment.
   Use the quote + section title to locate the target in the current document.
2. Apply **every** requested change to the document content.
3. Re-run the generation procedure to the **same filename**, with a **new** unique version
   stamp (step 6). The new stamp gives a fresh storage key, so the old — now possibly
   misaligned — comments are retired and the reopened doc is clean.
4. Keep section `id`s stable across the revision where you can, so any surviving comments
   still map to the right section.
5. If the pasted block carries the header but has **zero** comment entries, ask the user what
   they want changed rather than inventing edits.

## Notes

- **Zero runtime deps:** generation is Read/Write/Edit plus a POSIX shell; no Python or Node.
- **Fail loud on a missing plugin root:** if `${CLAUDE_PLUGIN_ROOT}` is unset, stop with a clear
  message instead of silently producing a broken file.

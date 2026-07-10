---
name: scholia
description: Render a substantial, multi-section document — a plan, report, research write-up, comparison, design doc, or similar — as a self-contained commentable HTML file and open it in the browser so the user can leave anchored inline comments and paste them back for revision. Use this when you are about to hand the user a long, structured document, or when the user explicitly asks for scholia or a "commentable" / "annotatable" version. Do NOT use it for short answers, quick code snippets, single-paragraph replies, small edits, or ordinary conversation.
allowed-tools: Read, Write, Edit, Bash(mkdir -p ./.claude-output), Bash(open *), Bash(xdg-open *), Bash(start *)
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

2. **Determine the filename.** This depends on whether you are revising or generating fresh:
   - **REVISION path** (the paste is a revision request — see "Revision behaviour"): reuse the
     filename **verbatim** from the pasted block. Take it from the backticked name in the header
     line or from the `## Comments on <filename>` line, and write to exactly that name. Do NOT
     re-derive `<type>_<topic>_<date>` — the whole point is to overwrite the same file so the
     browser reopens the doc the user commented on.
   - **NEW-DOC path** (a fresh document, not a revision): pick `type` — the closest of `plan`,
     `report`, `research`, `compare`, `explore`, `review`, `explain` — and `topic`, a short
     kebab-case slug. Build `<type>_<topic>_<YYYY-MM-DD>.html` using today's date. If a file with
     that name already exists in `./.claude-output/`, append `_2`, then `_3`, … until the name is
     unique, so a new document never clobbers an earlier one.

3. **Ensure the output directory exists** (run from the user's cwd):
   `mkdir -p ./.claude-output`

4. **Confirm `${CLAUDE_PLUGIN_ROOT}` is set.** If it is empty or unset, STOP and tell the
   user the plugin root is unavailable — do NOT write a partial or broken file.

5. **Copy the bundled template** to the target path:
   `cp "${CLAUDE_PLUGIN_ROOT}/templates/scholia-template.html" ./.claude-output/<filename>`
   (If `cp` is not permitted, Read the template and Write the identical bytes to the target.)

6. **No version stamp — comments persist.** Earlier versions injected a per-generation stamp so
   that regenerating a doc *retired* its comments. That is no longer the behaviour. Comments now
   **persist** across regenerations under a single filename-scoped key (`scholia::<filename>`):
   they carry over, gain a Resolve button, and move to a Resolved tab once you confirm them. There
   is nothing to stamp — the engine derives everything from the document's content hash on its own.
   Skip straight to filling the template.

7. **Fill the template** with Edit (leave the comment machinery alone):
   - `<title>__TITLE__</title>` → the document title,
   - the block between `<!-- CONTENT START -->` and `<!-- CONTENT END -->` (it holds
     `<h1>__TITLE__</h1>`, `<p class="summary">__SUMMARY__</p>`, and a demo section) →
     your real content: the `<h1>` title, the `<p class="summary">` one-liner, the optional
     TOC, and the sections from step 1.
   - Do NOT touch the `<style>`, the `<script>`, `<header class="bar">`,
     `<aside class="sidebar">`, the selection toolbar, or the compose popup — those power
     the commenting. Keep the `<head>` `<title>` in sync with the `<h1>`.
   - **HTML-escape the content you author.** When filling `<title>`, `<h1>`, the
     `<p class="summary">`, any section body text, and — with special care — every
     `<pre><code>` block, replace literal `<` with `&lt;`, `>` with `&gt;`, and `&`
     with `&amp;`. Otherwise content such as `std::vector<int>`, `A < B`, or `a && b`
     is parsed as markup and corrupts the render (a stray `<int>` becomes an unknown
     tag, `&amp` an entity). This matters most inside code blocks, where such
     characters are common.

7.5. **Self-verify the generated file before opening it.** Read the finished file back and
   confirm ALL of the following. If any check fails, fix the file and re-verify — do not open a
   broken document:
   - **No template remnants.** The strings `__TITLE__`, `__SUMMARY__`, and the demo section's
     "Try the commenting" heading must NOT appear anywhere in the file. If any remain, you
     failed to fully replace the placeholder content between `<!-- CONTENT START -->` and
     `<!-- CONTENT END -->`.
   - **Exactly one `<h1>`, and well-formed sections.** The document must contain exactly one
     `<h1>`. Every `<section>` must have an `id` that is both **non-empty** and **unique** across
     the file — the comment engine derives a comment's section from `section[id]`, so duplicate or
     missing ids mis-anchor comments.
   - **Escaped code blocks.** Spot-check each `<pre><code>` block for raw, unescaped `<` or `&`.
     Any literal `<` (not `&lt;`) or bare `&` (not `&amp;`/`&lt;`/… entity) inside code must be
     escaped, or the block corrupts the render.

8. **Open it in the browser** by running the platform-appropriate open command directly for the OS
   you are running on — pick the branch, do not guess:
   - **macOS:** `open "./.claude-output/<filename>"`
   - **Linux (including WSL):** `xdg-open "./.claude-output/<filename>"`
   - **Windows (Git Bash / Cygwin):** `start "" "./.claude-output/<filename>"`
   Choose based on the known platform. If none is available, tell the user the file path and ask
   them to open it manually.

9. **Tell the user, briefly:** the doc is open in the browser; hover any line for the gutter
   `+` or select text to comment on a span; when done, click **Copy comments** (top right)
   and paste the block back into chat to revise.

## Revision behaviour

**Recognising a revision request.** Treat a pasted block as a scholia revision request if EITHER
of these holds — do NOT key recognition on the exact prose of the self-instructing sentence, which
may be reworded or dropped:

- it contains the stable sentinel line `<!-- scholia:revision v1 -->`, OR
- it contains at least one comment entry matching the structural pattern: a header line
  `[#N — Line in section: "…"]` or `[#N — Span in section: "…"]` (a stable `· id=<commentId>` may
  appear right after `#N`), followed by a quoted anchor line `> "…"`, followed by a `Comment: …` line.

When either condition matches, treat the whole paste as anchored feedback and revise the document.

Then:

1. Read each entry — its index, its stable `id` (shown as `· id=<commentId>` in the header line),
   `Line`/`Span`, section title, the quoted anchor, and the comment. Use the quote + section title to
   locate the target in the current document, and keep each `id` — you will key its resolution note
   back to it in step 4. If an entry is marked `· detached` in its header line (or its quoted anchor
   can no longer be found in the current document because a prior round rewrote or removed that text),
   do NOT skip it — fall back to the section title plus the comment text to decide what the change
   should be.
2. Apply **every** requested change to the document content.
3. Re-run the generation procedure, reusing the filename **verbatim** from the pasted block (the
   backticked name in the header line or the `## Comments on <filename>` line — see step 2's
   REVISION path; never re-derive it). Do NOT rotate any version stamp — **comments persist across
   the regeneration** under the single `scholia::<filename>` key. Every prior comment carries over:
   on reload it becomes **Carried-over** (a "↻" mark and a Resolve button). Comments re-anchor by
   BLOCK POSITION, not by text: each is pinned to the section + the block's ordinal position (the
   Nth paragraph/list-item/heading of its section), so editing a block's wording IN PLACE keeps its
   comment attached, and a comment only goes **detached** (kept in the list, no highlight) when its
   whole block is removed. Prefer revising blocks in place over inserting/reordering blocks above a
   commented one — inserting a block shifts later positions, which can move a comment's highlight to
   an adjacent block. Keeping the filename identical is exactly what lets the browser reopen the same
   doc with its comment thread intact — so the user can confirm each change and Resolve it.
4. **Emit a resolution-notes map.** In the regenerated HTML, add ONE JSON script tag —
   `<script type="application/json" id="scholia-resolution-notes">{ … }</script>` — placed inside
   `<body>` but OUTSIDE `<main>` (e.g. right before `</body>`), so it never affects the document's
   content hash or the commentable text. Its JSON is an object keyed by the comment `id`s from the
   pasted block, each value a one-line, plain-English summary of HOW you addressed that comment —
   e.g. `{"c7a3":"Lowered the enterprise tier to 10% and added an annual option.","c9f1":"Rewrote the vague Q3 wording to a concrete 15 Aug date."}`.
   Include ONLY ids you actually addressed; a comment you did not change gets no entry (its card then
   shows without a note — never blank or invented). On reload the engine merges each note onto its
   carried-over comment, so the user sees "How it was addressed" beside their original comment before
   they Resolve it. HTML-escape the note values like any other authored content.
5. Keep section `id`s stable across the revision where you can, so carried-over comments
   still map to the right section.
6. If the pasted block is recognised as a revision request (e.g. the sentinel is present) but has
   **zero** comment entries, ask the user what they want changed rather than inventing edits.

## Notes

- **Zero runtime deps:** generation is Read/Write/Edit plus a POSIX shell; no Python or Node.
- **Fail loud on a missing plugin root:** if `${CLAUDE_PLUGIN_ROOT}` is unset, stop with a clear
  message instead of silently producing a broken file.

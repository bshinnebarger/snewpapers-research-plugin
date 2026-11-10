# A research folder, one per topic

Offer it once, only when the researcher is digging rather than browsing; a casual question
needs none. It is the record of everything acquired or derived for the topic, so a later
pass - by you, another agent, or the researcher - can replay it.

**Before offering, check which of these you can actually reach:**

1. The researcher's own filesystem (a local agent, an IDE, a desktop app with folder
   access). A sandbox or container that resets between sessions, or that the researcher
   cannot browse, does NOT count - never keep the folder only there. Results have to reach
   the researcher: attach them in the chat or write to their machine; do not assume they
   can browse your filesystem.
2. A storage connector whose tools are loaded right now (Google Drive, OneDrive, Notion, a
   docs tool).
3. A storage connector the researcher has but that is not enabled in this session - you may
   offer to enable it, without pushing.
4. None: keep the record in the conversation.

Then ask in one sentence, naming the real options, for example: "This could become a long
investigation. I can keep a research folder (queries, citations, notes) so it can be re-run
later - in your Google Drive, or here in the chat, which will not carry over to a new
conversation. Which do you prefer?" Say what staying in the conversation loses: replay,
`created_after` re-runs on new material, continuity into a new chat.

If they pick a connector, say where it will go (folder name or path) and confirm once before
the first write - writing to someone's drive is a side effect. On connector storage use the
**lite layout** unless they ask for the full one: creating a dozen files through a connector
costs a call each.

If they decline or nothing is reachable, explore ad hoc: keep the exact query arguments and
the citations in your replies so the researcher can save them, and offer one summary
(README plus citations) at the end.

## Lite layout (connector storage)

```
<topic-slug>/
  README        question, findings, caveats, run log (date, index size, tokens), queries used verbatim
  citations     uuid,title,date,state,page,site_url,quote
```

## Full layout (the researcher's own filesystem)

```
<topic-slug>/
  README.md        question, angle, status, key findings so far, caveats
  meta.json        provenance and re-run state (below)
  queries/         one .json per useful query: tool, exact args verbatim, cost, result count, date
    notes.md       why each query exists; patterns that worked and that failed
  data/            derived CSV/JSON plus the scripts that produced them
  articles/        saved component full text: <issue-date>_<title-slug>_<uuid8>.md
  images/          charts plus the script that drew each one
  analysis/        findings and write-ups (article drafts, for publishing use cases)
  citations.csv    uuid,title,date,state,page,site_url,quote
  CHANGELOG.md     one line per run: date, index size, tokens, what changed
```

## meta.json

```json
{
  "topic": "pandemic-parallels",
  "title": "...",
  "started": "2026-10-14",
  "updated": "2026-10-14",
  "tags": ["epidemic", "cholera"],
  "guarded": true,
  "excluded_ids": [{"uuid": "...", "reason": "OCR garbage / duplicate / off-topic"}],
  "runs": [
    {"date": "2026-10-14", "index_docs": 1818377, "index_components": 1797263,
     "newest_first_indexed_at": "2026-10-14T04:53:13Z", "tokens": 46}
  ],
  "token_total": 46
}
```

## Rules

- Every search / facets response carries `corpus: {docs, components, newest_first_indexed_at,
  measured_at}` (`docs` = event docs, what facets count; `components` = distinct components).
  Record both in `runs[]` at the start of a run (or call `research_corpus`, which gives the
  same two numbers). The corpus grows about 150,000 docs a day, so every number needs a
  "measured on".
- To re-run on new material only, pass `filters.created_after` = the previous run's
  `newest_first_indexed_at`; `updated_after` catches re-extracted components.
- Save queries verbatim, with the date they ran. A re-run is: replay `queries/*.json`, then
  run the scripts in `data/`. Do not keep raw responses: the queries, the run log and the
  saved articles are the record, and the index moves on anyway.
- Tool friction belongs in the chat, not in the folder.
- Every quoted passage gets a row in `citations.csv` before it goes into an analysis file,
  and the quote comes from full text, never from a summary.
- Record the token cost per query and per run.

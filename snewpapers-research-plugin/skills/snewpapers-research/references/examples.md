# Twelve worked investigations

Each shows the question, the calls in order (MCP tool + the `query`), what to expect, and
the token cost. Component ids are real ones from the current index.

## 1. Coverage first: "1918 influenza in Midwestern local papers"

```
research_facets  {"query": {"filters": {"regions": ["midwest"], "start_date": "1918-09-01", "end_date": "1919-04-30"},
                            "text": {"should_have_keywords": "influenza flu grippe epidemic"},
                            "flat_facets": ["decade_histogram", "states", "labels"]}}
```
If `total_docs` is ~0, do not re-query with other words; run the coverage check:
```
research_facets  {"query": {"filters": {"regions": ["midwest"]}, "flat_facets": ["decade_histogram"]}}
```
If the 1910s bucket is tiny, say so: "the corpus holds few Midwestern papers from the 1910s
yet" (it grows daily; this will change). Then offer what exists - drop the region:
```
research_facets  {"query": {"filters": {"start_date": "1918-09-01", "end_date": "1919-04-30"},
                            "text": {"should_have_keywords": "influenza flu grippe epidemic"},
                            "flat_facets": ["states", "lccns", "labels"]}}
```
and search where the counts are. Cost: 6.

## 2. Destruction inventories: "what was burnt and destroyed in the War of 1812"

Spellings go in `should_have_keywords`; the anchor is the one thing every report shares.
```
research_facets  {"query": {"filters": {"start_date": "1812-06-18", "end_date": "1815-03-31",
                                        "labels": {"values": ["domestic_news", "foreign_news", "local_news"], "mode": "include"}},
                            "text": {"must_have_keywords": "british",
                                     "should_have_keywords": "burnt burned destroyed conflagration fired plundered"},
                            "flat_facets": ["keywords", "lccns", "year_histogram"]}}
```
Facet keywords will surface `burning of washington`, `capture of york`, `fort niagara`,
`lewiston`. Search each hotspot, keyword-filtered:
```
research_search  {"query": {"filters": {"start_date": "1814-08-24", "end_date": "1814-12-31",
                                        "term_filters": [{"field": "keywords", "values": ["navy yard", "capitol", "public buildings"]}]},
                            "text": {"should_have_keywords": "burnt burned destroyed"},
                            "sort": "issue_date:asc"}}
```
Triage on `fields.news_casualties_or_outcome` - it often names what burned before you open
anything. Open the primary report:
```
research_component  {"component_id": "d11d0795-0c12-4652-9695-0f5df99c01ff_evt_0", "include_text": true}
```
(Commodore Tingey's Navy Yard report, Norfolk Gazette, 17 Sep 1814.) Cost: 2 + 1 per page + 4.

## 3. A touchy subject, done right: pre-1800 slavery editorials and letters

Learn the vocabulary before searching:
```
research_vocabulary  {"label": "letter_to_editor", "year_to": 1799}
research_vocabulary  {"label": "editorial", "year_to": 1799}
```
Themes show `slavery_abolition`; keywords show `slave trade`, `abolition`, `emancipation`.
Filter on them (any of), not on the word "slavery" (Revolutionary metaphor):
```
research_search  {"query": {"filters": {"end_date": "1799-12-31", "embed_worthy": true,
                                        "labels": {"values": ["editorial", "letter_to_editor"], "mode": "include"},
                                        "any_of": [{"field": "themes", "values": ["slavery_abolition"]},
                                                   {"field": "keywords", "values": ["slave trade", "abolition", "emancipation"]}]},
                            "text": {"semantic_text": "argument for or against the slave trade and abolition"}}}
```
About a third of the hits carry `caution: true` and show only `caution_description`. Apply
the guardrail rule: on a host that can display them, ask once, then re-run with
`"guarded": false`. A non-caution example to open: `46ff422f-1c05-4071-ba27-30d6b474f39b_evt_0`
(New-Hampshire Gazette, 22 May 1784); caution examples: `8bcc953b-f661-4d12-9616-d33d28beb005_evt_0`
(Gazette of the United States, 2 Jun 1796), `d004b6dd-cac0-4fbf-a41d-805865481a8c_evt_0`
(New-Hampshire Gazette, 23 Jul 1789, graphic).

## 4. A person: "obituaries for anyone named Tingey"

Persons are extracted strings; try the forms the papers used and let OR do the work:
```
research_search  {"query": {"filters": {"labels": {"values": ["obituary"], "mode": "include"},
                                        "term_filters": [{"field": "persons", "values": ["thomas tingey", "commodore tingey", "tingey"]}]},
                            "sort": "issue_date:asc"}}
```
If that is empty, fall back to text: `{"text": {"must_have_keywords": "tingey"}}` with the
obituary label. Read `fields.obi_name`, `obi_death_date`, `obi_age_at_death`,
`obi_survivors_or_heirs` from the hits; the full text is rarely needed for an obituary.
Cost: 1 per page.

## 5. Runaway notices by place and date (a never-embed genre)

No vector: keywords and structured fields only, never `semantic_text` or `embed_worthy`.
Most runaway notices carry `caution: true`, so under guardrails their `run_*` fields are
empty - this is the genre where the guardrail question comes first.
```
research_vocabulary  {"label": "runaway"}
research_search  {"query": {"filters": {"labels": {"values": ["runaway"], "mode": "include"},
                                        "start_date": "1770-01-01", "end_date": "1779-12-31",
                                        "term_filters": [{"field": "states", "values": ["virginia"]},
                                                         {"field": "types", "values": ["slave"]}]},
                            "sort": "issue_date:asc"}}
```
Each hit's `fields` carry `run_name`, `run_age`, `run_complexion`, `run_skills_or_trade`,
`run_suspected_destination`, `run_owner_or_subscriber`, `run_reward_amount`. Tabulate those
rather than opening full texts; open one or two with `include_text` for the wording.
Facet `types`, `locations` and `year_histogram` on the same filters to size the set.

## 6. Read a whole issue

From any hit take `issue_uuid`, then page the paper in print order:
```
research_search  {"query": {"filters": {"issue_uuid": "2ff816a8-d942-4a9a-ad64-003bf36f79a6"},
                            "sort": "pages:asc"}}
```
Page 2+ with the cursor; issue browse pages beyond 10 (the whole issue). Group the hits by
`pages` for the researcher. Cost: 1 per page of 25 components.

## 7. A page of summaries, then a batch of the ones that matter

```
research_search  {"query": {"filters": {"start_date": "1853-01-01", "end_date": "1853-12-31",
                                        "labels": {"values": ["domestic_news", "local_news", "editorial"], "mode": "include"}},
                            "text": {"must_have_phrase": "yellow fever",
                                     "should_have_keywords": "epidemic deaths quarantine new orleans mobile",
                                     "semantic_text": "yellow fever epidemic in a southern town"}}}
```
Pick the five whose summaries answer the question, then one call:
```
research_components  {"query": {"ids": ["<event_id 1>", "<event_id 2>", "<event_id 3>", "<event_id 4>", "<event_id 5>"],
                                "include_text": true}}
```
Cost: 1 for the page + 3 per text never paid before (0 for one you paid for in an
earlier session; without `include_text` it is 1 each). Each component reports its own
`tokens_charged`. Ids the index does
not know come back in `missing`, free.

## 8. Paging correctly

Page 1 returns `cursor`. Page 2 is the same `filters` and `text` plus `"page": 2, "cursor": "<from page 1>"`.
The cursor pins the ranking, so pages never overlap or shift. It expires ~10 minutes after
its last use (a 400 says start again). Page 11 is a 400 by design: if the answer is not in
250 hits, the query is too wide - facet on `keywords`, `lccns` or `year_histogram` and add
filters. Do not page to "see everything".

## 9. Hotspots: which papers covered a topic, and when

```
research_facets  {"query": {"filters": {"start_date": "1848-01-01", "end_date": "1856-12-31"},
                            "text": {"must_have_phrase": "gold", "should_have_keywords": "california mines diggings sacramento san francisco"},
                            "nested_facets": {"lccns": ["year_histogram"]}, "flat_facets": ["states", "labels"]}}
```
The nested result comes back as `facets.lccns_nested` (papers, each with a `year_histogram`); render it as papers x years (display.md). Then restrict:
`"term_filters": [{"field": "lccns", "values": ["<lccn>"]}]` and search that paper by
`issue_date:asc`. Cost: 2 per facets call.

## 10. Topic search by meaning

For narrative genres, one sentence:
```
research_search  {"query": {"filters": {"start_date": "1760-01-01", "end_date": "1775-12-31",
                                        "labels": {"values": ["editorial", "letter_to_editor", "domestic_news"], "mode": "include"}},
                            "text": {"semantic_text": "colonial resistance to British taxation",
                                     "should_have_keywords": "stamp act duties nonimportation boycott merchants"}}}
```
Hybrid (semantic + keywords) is the best default for a topic; pure `semantic_text` alone
is fine for a fuzzy question. Remember it only reaches embed-worthy components - add a
keyword-only pass for notices, auctions or runaways on the same topic.

## 11. Multi-event components

A notice listing many deaths, a shipping column, a society column: one uuid, N events.
```
research_search  {"query": {"filters": {"labels": {"values": ["notice", "obituary"], "mode": "include"},
                                        "start_date": "1853-08-01", "end_date": "1853-10-31"},
                            "text": {"must_have_keywords": "fever", "should_have_keywords": "died deaths interments"},
                            "expand_events": true}}
```
Each event is its own hit with its own `event_id` and `fields`; `event_count` says how many
siblings it has. `research_component` on any event id returns the whole component with
every event and echoes the `requested_event_idx` you asked with.

## 12. Fragments and continuations

A hit with `resolved: false` or `chain_members > 1` is part of something longer. To find the
rest:
```
research_search  {"query": {"filters": {"term_filters": [{"field": "lccns", "values": ["<the hit's lccn>"]}],
                                        "start_date": "<its issue_date>", "end_date": "<+ 3 weeks>"},
                            "text": {"should_have_keywords": "<3-5 distinctive words from its summary>"},
                            "sort": "issue_date:asc"}}
```
Read the candidates' summaries in date order and open the continuation with `include_text`.
Tell the researcher which pieces are fragments and why (the evidence numbers on the
component say lost opening vs continued).

## Also: the balance

`research_account_tokens` any time; every metered response already carries
`tokens_charged` and `tokens_remaining`. A 402 names the price and the remaining tokens -
report it and stop.

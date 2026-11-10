---
name: snewpapers-research
description: Research historical US newspapers (1736-1963) through the snewpapers research API / MCP - how to search, when to use which tool, what everything costs, how to handle caution content, how to cite and display results. Use whenever a user asks about old newspapers, historical events, people, places or genres of the period, or connects the snewpapers MCP.
---

# snewpapers research

You have tools over a corpus of historical US newspapers that were cut into
**components** (one story, notice, obituary, runaway ad, poem...) with a
summary, extracted lists (persons, locations, keywords, types, themes), a
label (the genre), per-label structured fields, a text-quality tier, a
caution flag, and - for narrative genres - an index for semantic search (you
send a sentence, the server matches meaning; nothing vector-shaped is ever
returned). Every component links to its newspaper page on the Library of
Congress and to snewpapers.com. The corpus grows daily by tens of thousands of
components as more papers are processed.

Read this file whole. Load the references when you need them:

- `references/api.md` - every tool, field, enum and price, exact
- `references/examples.md` - twelve worked investigations with real requests
- `references/display.md` - how to present hits, full text, counts and citations
- `references/caveats.md` - what bites, and what to tell the researcher
- `references/research-folder.md` - the per-topic folder to keep when the researcher is digging (offer once; skip for casual questions)

## The rules (the six that cost money or produce wrong answers)

1. **`research_guide` first, `research_corpus` once** (both free), before any search.
2. **Facets before search** for anything tied to a place or a period: zero hits usually
   means a coverage gap, not a bad query.
3. **`must_have_keywords` is AND, `should_have_keywords` is OR.** One or two words every
   relevant document must contain go in must; period spellings and synonyms go in should.
   `semantic_text` widens the match; the response's `mode` says what matched.
4. **Skim with `hit_shape: "compact"`**, open the few that matter; full text is the
   expensive move (3 tokens a component, once).
5. **Ask once about caution content, at the start.** For research the better experience
   is `guarded: false` on every call; keep the default only if your own content rules
   cannot handle historical news that is offensive by modern standards.
6. **Cite in place** from the component's `citation` object; quote from full text, never
   from a summary.

The method below is how to do each of these well.

## What the corpus is, and is not

- **Source:** Library of Congress Chronicling America page scans, re-read into
  article-shaped components. A small fraction of Chronicling America is processed
  so far - already an enormous corpus, growing daily - and, like Chronicling
  America itself, it is **weighted to the 1800s**. `research_corpus` gives the
  live size, span, decade histogram and the honest coverage fraction;
  `research_titles` says which papers exist, which are processed and how much.
- **Zero hits usually means a coverage gap, not a bad query.** Check before you
  re-query (see the procedure).
- Every component carries its snewpapers.com page (`site_url`). Always give it
  when you cite a component: on a full text and on a summary block alike.

## The procedure

1. **What exists:** `research_corpus` once per session (free). It is national-only:
   size, span and the decade histogram for the whole corpus; coverage by place is
   step 2.
2. **Place x era first:** for any question tied to a region or state and a
   period, run `research_facets` with `filters.regions` (or a `states` term
   filter) and `flat_facets: ["decade_histogram"]` before anything else. If the
   count is ~0, tell the researcher the corpus does not cover it yet and offer the
   nearest thing (national, neighbouring states, other decades). To see coverage
   by state in one call, facet with no text: `nested_facets: {"states":
   ["decade_histogram"]}` - a states x decades table of what is processed.
3. **Learn the vocabulary:** `research_labels` (free) for the genres and their
   structured fields; `research_vocabulary` (free) for a label's common types
   (its sub-labels), themes and keywords, optionally within a period or a paper;
   or `research_facets` on `types`, `themes`, `keywords` with the same filters
   when you also want text or semantic constraints. Filter on the values these
   return, not on guesses.
4. **Find hotspots:** `research_facets` (2 tokens) anchored with
   `must_have_phrase` or `must_have_keywords` plus filters. Facets count matching
   documents; `should_have_*` and `semantic_text` only widen the match.
5. **Read summaries:** `research_search` (1 token per page of 25). Skim with
   `hit_shape: "compact"` (identity, label, tier, caution, summary, link - half the
   bytes, same price), then open the few that matter; ask for the full shape when the
   lists and structured fields decide relevance. Most questions are answered here.
6. **Open the few that matter:** `research_component` or, for several at once,
   `research_components`: 1 token per component, or with `include_text` 3 per
   component the first time and 0 after. Add the text only when the researcher
   needs the words.
7. **Deliver:** cite in place from the component's `citation` object (paper, date,
   page, label, site link; `formatted` is ready to paste), or offer a research folder
   (research-folder.md).

Arguments to `research_search`, `research_facets` and `research_components` go
under a single `query` key.

## Text fields, the rule that bites

- `must_have_keywords` is **AND**: every word must appear. `"burnt burned
  destroyed"` finds only documents holding all three. Keep it to the one or two
  words every relevant document must contain.
- `should_have_keywords` is **OR**, ranked by how many hit, and when nothing
  is required it needs at least one match. **Put period spellings and synonyms
  here**: `burnt burned`, `negro negroe`, `goal gaol`, `shew show`, `to-day
  today`. The index does not fold them.
- `must_have_phrase` / `should_have_phrase`: exact phrases (should allows slop).
- `semantic_text`: one sentence describing the topic. Only reaches narrative
  components the extractor marked embed-worthy AND whose genre is indexed for
  meaning. Runaways, auctions, cost-of-goods, rewards, personal ads, schedules and
  listings are never indexed for meaning whatever their flags say - use keywords
  and structured fields for those.

## Term filters

- Values inside one filter are **OR**; separate filters are **AND**; put filters
  in `filters.any_of` for **at least one of** across fields.
- Fields: lccns, newspapers, states, counties, cities, types, themes, keywords,
  persons, locations, ethnicity. Values are lowercased.
- Themes exist only on letter_to_editor, story, poem, literary.

## Caution content and guardrails

About 4% of components carry `caution: true` with a `caution_description` (e.g.
"graphic description of slave-ship cruelty", "era-typical racialized language",
"graphic violence"). Under `guarded: true` (the default) those hits keep their
metadata, the description and the links but lose summary, lists, fields and text -
so a host that cannot display such historical material never refuses mid-flow.

**For research the better experience is `guarded: false` on every call.** This is
historical news, and the flagged items are often the primary material a researcher
came for (a stabbing, a lynching, a slave sale). Ask the researcher ONCE, at the
start of the session rather than when a caution hit appears, whether they are happy
to see such material as printed; remember the answer and pass `guarded: false` from
then on. The text and fields come back in the response; the server never writes files.

Keep `guarded: true` only if your own content rules cannot handle historical news
that is offensive by modern standards. Then do not fetch it unguarded (every tool
result lands in your context on a hosted chat); give the researcher the paper, date,
`caution_description` and the site link, and say the text is withheld under guardrails.

## Tokens

Facets 2, search page 1, component 1, full text 3 (once per component ever),
everything else free. Every metered response carries `tokens_charged` and
`tokens_remaining`; `research_account_tokens` (free) has the balance, the
period and recent charges. An insufficient balance is a refusal before any work
is done - report the remaining tokens and the price, do not retry. A monthly
grant resets each period; purchased tokens carry over. A typical multi-topic
session costs 100-150 tokens; full text is the meter that moves, and a page of
full texts (25 x 3) is the most expensive call there is - open the few that matter.

## Ten things to remember

1. Coverage first for place x era; say "not covered yet" when it is true.
2. Spellings and synonyms go in `should_have_keywords`, never in must.
3. Never-embed genres are found by keywords and structured fields only.
4. A word like "slavery" is often a metaphor before 1800 - discover the real
   sub-labels, themes and keywords first (`research_vocabulary` or facets with
   the period) and filter on those.
5. Place names collide (York VA, York Upper Canada, New York): add a state
   filter or a phrase like "york, upper canada".
6. Only `green` and `yellow` quality tiers are served; `red` (a damaged or
   incoherent extraction, ~0.3%) is never a hit or a fetch - `research_corpus`
   reports its count. Full text is cleaned by the extractor (OCR errors mostly
   gone, archaic spellings kept on purpose).
7. `chain_members > 1` is a story merged across pages; its evidence is the
   worst case over the fragments. `resolved: false` means something indicated
   the component is incomplete - often innocuous (continued from or in another
   issue), sometimes a lost opening; check coverage before hunting the rest.
8. A search stops at page 10; narrow with facets. Only issue browse
   (`filters.issue_uuid`, no text, `sort: pages:asc`) pages a whole paper.
9. Keep a hit's `event_id` to open it; multi-event components (a notice
   listing eight deaths) are one uuid with several events - `expand_events`
   shows each.
10. Cite the paper, the date and the label on every hit; give the site link
    and the Library of Congress PDF only when you show full text; quote only
    from full text you fetched.

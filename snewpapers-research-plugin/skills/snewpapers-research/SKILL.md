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

## The rules (ten; the method below is how to do each of them well)

1. **`research_guide` first, `research_corpus` once** (both free), before any search.
2. **Coverage before topic** for anything tied to a place or a period: facet the place x era
   first. Zero hits usually means a coverage gap, not a bad query - say "not processed yet"
   and offer the nearest thing (national, neighbouring states, other decades).
3. **`must_have_keywords` is AND, `should_have_keywords` is OR.** The one or two words every
   relevant document must contain go in must; period spellings and synonyms go in should,
   never in must. `semantic_text` widens the match and reaches only narrative genres indexed
   for meaning; runaways, auctions, listings and the like are found by keywords and
   structured fields only. The response's `mode` says what matched.
4. **Discover the vocabulary before you filter on it.** A word like "slavery" is often a
   metaphor before 1800: `research_vocabulary` or facets on types, themes and keywords within
   the period give the real sub-labels and terms.
5. **Place names collide** (York VA, York Upper Canada, New York): add a state filter or a
   phrase like "york, upper canada".
6. **Skim with `hit_shape: "compact"`**, open the few that matter; full text is the expensive
   move (3 tokens a component, once). A search stops at page 10 - narrow with facets; only
   issue browse (`filters.issue_uuid`, no text, `sort: pages:asc`) pages a whole paper.
7. **Keep a hit's `event_id` to open it.** A multi-event component (a notice listing eight
   deaths) is one uuid with several events; `expand_events` shows each.
8. **Read the data's own flags.** Only `green` and `yellow` quality tiers are served (`red`,
   ~0.3%, never appears); `chain_members > 1` is a story merged across pages; `resolved:
   false` means something indicated it is incomplete - check coverage before hunting the
   rest (caveats.md).
9. **Ask once about caution content, at the start.** For research the better experience is
   `guarded: false` on every call; keep the default only if your own content rules cannot
   handle historical news that is offensive by modern standards.
10. **Cite in place** from the component's `citation` object: paper, date and label on every
    hit with the site link; the Library of Congress PDF only with full text; quote only from
    full text you fetched, never from a summary.

For a prolonged deep dive - the researcher is going to come back to a topic over days -
and when you can write to a local folder or a cloud drive, offer the research folder once:
the structure and the files to keep are in `references/research-folder.md`.

## What the corpus is, and is not

- **Source:** Library of Congress Chronicling America page scans, re-read into
  article-shaped components. snewpapers is working towards full coverage of
  Chronicling America, with the index growing by tens of thousands of components
  daily (live status: https://snewpapers.com/ca-progress); like Chronicling
  America itself, it is **weighted to the 1800s**, and some regions x decades are
  still thin or empty. `research_corpus` gives the live size, span, decade
  histogram and the honest coverage fraction; `research_titles` says which papers
  exist, which are processed and how much. Treat a gap as "not processed yet",
  never as a reason to distrust what is there.
- Every component carries its snewpapers.com page (`site_url`). Always give it
  when you cite a component: on a full text and on a summary block alike.

## The procedure

1. **What exists:** `research_corpus` (free): size, span, decade histogram and the
   coverage fraction, national only.
2. **Place x era:** `research_facets` with `filters.regions` (or a `states` term filter)
   and `flat_facets: ["decade_histogram"]`; for every state at once, no text and
   `nested_facets: {"states": ["decade_histogram"]}` - a states x decades table of what
   is processed.
3. **Vocabulary:** `research_labels` (free) for the genres and their structured fields;
   `research_vocabulary` (free) for a label's types, themes and keywords, optionally within
   a period or a paper; `research_facets` on those fields when text or semantic
   constraints apply. Filter on the values these return.
4. **Hotspots:** `research_facets` (2 tokens) anchored with `must_have_phrase` or
   `must_have_keywords` plus filters. Facets count matching documents; `should_have_*`
   and `semantic_text` only widen the match.
5. **Summaries:** `research_search` (1 token a page of 25), compact first, the full shape
   when the lists and structured fields decide relevance. Most questions are answered here.
6. **The few that matter:** `research_component`, or `research_components` for several:
   1 token a component, with `include_text` 3 the first time and 0 after. Add the text
   only when the researcher needs the words.
7. **Deliver:** the component's `citation` object (paper, date, page, label, site link;
   `formatted` is ready to paste), or the research folder for a long dive.

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

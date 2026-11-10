# Caveats and nuances

**Coverage.** A small fraction of Chronicling America is processed - already an enormous
corpus, growing daily by tens of thousands of components - and, like Chronicling America
itself, it is weighted to the 1800s; some regions x decades are still thin or empty (in
2026, the Midwest in the 1910s). `research_corpus`
has the honest fraction; `research_titles` and `research_title` show, per paper, "exists at
the Library of Congress but not processed here". Say so to the researcher instead of
re-querying five ways, and offer what the corpus does hold (`research_facets` with
`decade_histogram` and `states`).

**Never-embed genres.** runaway, auction, cost_of_goods, reward, personal_ad, errata,
epigraph, puzzles, schedules and listings are never indexed for meaning, so `semantic_text`
cannot see them (a handful carry `embed_worthy: true`; it changes nothing for them). Reach
them with labels, keywords and their structured fields (`run_*`, `auc_*`, ...). Runaway
notices are the richest primary source on enslaved people, by place, date, description and
destination - nobody searches them by name.

**Metaphor pollution.** Before 1800 "slavery", "tyranny", "chains" are mostly political
rhetoric about Britain. Do not search the word: run vocabulary discovery first
(`research_vocabulary` with the label and period) or aggregation queries on `types`, `themes`
and `keywords` with the same filters - and with text or semantic constraints too, when you
want them - to surface the real sub-labels, themes and keywords, then filter on those. For
this topic that surfaces things like the theme `slavery_abolition` and keywords `slave trade`,
`abolition`, `manumission`, `emancipation`.

**Period spellings, stems, synonyms.** The index does not fold spellings: `burnt/burned`,
`negro/negroe`, `gaol/goal`, `shew/show`, `to-day/today`, `connexion/connection`. There are
no synonyms (`flu` is not `influenza`) and stemming applies only to summaries, not to the
full text, so `epidemics` in a body matches `epidemic` only where the summary says it.
Put every variant - spelling, word form, synonym - in `should_have_keywords`. The full text was cleaned by the extractor, so most OCR errors are
gone while archaic spellings are kept on purpose; quote as given, and flag the rare
remaining glitch rather than silently fixing it.

**Place ambiguity.** York (Virginia, Upper Canada, New York), Washington (the city, the
county, the general), Portland, Springfield. Add `states`/`regions` filters or a
disambiguating phrase.

**Printing place is not subject place.** `states`, `cities`, `counties` (filters and facets)
are where the paper was printed. Faceting 1793 Philadelphia fever coverage by `states` shows
New Hampshire and West Virginia - papers reporting it - not Pennsylvania. The place an item
is ABOUT is `locations` (lightly normalised - case, honorifics, hyphens - but not
canonicalised: "washington" and "washington, d.c." are separate values; fold them yourself).

**The caution flag is the extractor's call**, set at extraction for slurs, graphic violence and
dehumanising content - not for every period-typical prejudice. An 1832 editorial urging masters'
vigilance over enslaved people carries `caution: false`. Handle pre-1865 slavery material, and
anything about race, with care whatever the flag says.

**Numbers in summaries.** A summary can carry an OCR-garbled figure ("2,877,867" where the
page said something else). Never quote a number from a summary; fetch the full text and
quote from that, and say when a figure looks implausible.

**Advertisements are not served.** No patent-medicine or remedy ads, no auction-house ads as
ads: `advertisement` is not a label the API returns, so do not search for them or report
their absence as a finding. (Ad-like genres that ARE served: auction, runaway, reward,
personal_ad, cost_of_goods, commercial.)

**`mcp-remote` disappears when the npx cache is wiped** (a client-side thing): install it
globally or pin its path in the host's MCP config so the connector survives a cache clean.

**Some hosts cache the tool list across restarts** (Grok Bot does, with nothing on the
user's side to flush). The tool descriptions you see may be older than the server's; this
file and the API reference are the current word, and a changed rule always shows in the
response or the 422 hint, never only in a description. If a description and a response
disagree, trust the response.

**Quality tiers.** `green` and `yellow` are served, both by default; `quality_tiers:
["green"]` narrows to clean text. `red` (the extraction had trouble: poor scan, damaged text,
layout slips) is never served - not in search, facets, issue browse or a component fetch -
and `research_corpus` reports how many docs that withholds. Sending `red` is a 422.

**Chains and fragments.** `chain_members > 1`: the story was merged across pages; the
evidence numbers are the worst case over its fragments. `resolved: false`: something
indicated the component is incomplete. Often innocuous - it continues from or in another
issue; sometimes a decorative drop-cap confused line discovery; sometimes a genuine gap. To
find a continuation: first check coverage (`research_title` with the year shows which issues
of that paper are processed - the next issue may simply not be here yet), then search the
same `lccns` with `sort: issue_date:asc` from that date with a few distinctive words in
`should_have_keywords`. A "stories like this" call is planned and will make this one step.

**Multi-event components.** A notice listing eight deaths is one uuid with eight events. A
search collapses to the best event per component unless `expand_events: true`; the
component call returns every event. `event_count` tells you.

**Caution.** `caution: true` means the extractor judged the text offensive by modern standards
(racialized language, graphic cruelty, and the like), not that it is unimportant - much of
the best primary material on slavery, violence and prejudice carries it. Handle it by the
guardrail rule in SKILL.md, never by silently dropping it. `caution_description` is always
returned and is safe to show.

**Facets count documents, hits are components.** `total_docs` counts event documents;
`total_components` distinct components. Multi-event notices make them differ.

**Coverage checks are cheap, topic searches are not.** When a coverage facet shows only a
handful of documents for a place x era (tens, not hundreds), say so and skip the topic
search there - a keyword hit in a tiny slice is usually a metaphor or a stray, and it
still costs a token.

**Issue browse is for reading a paper, not for discovery.** A dense front page is 25
components a token. Find things with facets and search; browse an issue when the researcher
wants that edition.

**expand_events floods.** One fourteen-deserter notice can fill a page with its own events.
After expanding, use facets or `exclude_uuids` if you need breadth rather than depth.

**Paging.** Page 2+ needs the cursor from page 1; it expires ~10 minutes after its last use.
A search stops at page 10 - if you want more, narrow (facets, filters, dates), do not grind.
Issue browse is the one place paging deep is right.

**Names and lists.** `newspaper` names are lowercased; several papers share a name across
runs and rivals (five "Virginia Gazette" lccns in the 1770s alone) - when names collide,
pick by `lccn` and the masthead's date range from `research_titles`, never by the first
short name. `county` and `city` can be lists (Library of Congress
data). Persons and locations are lightly normalised (case, honorifics, hyphens), not
canonicalised - filter with the exact values a facet returned.

**Tokens.** Prices in SKILL.md. A 402 is a refusal before any work; report
`tokens_remaining` and `price`, do not retry. Full text is charged once per component per
account - opening the same component again is free, so it is fine to re-open.

**Links.** Every component has a snewpapers.com page (`site_url`) and a Library of Congress
page link; the site link is the citation and goes on every component you show.

**Dates.** All dates are issue dates. A story about an event is usually printed days to
weeks after it, and reprinted across papers for months.

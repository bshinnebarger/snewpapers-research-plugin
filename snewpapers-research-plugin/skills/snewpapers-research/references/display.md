# Displaying results

## A hit or a component

When you are paging to see what exists rather than to answer, ask for `hit_shape: "compact"`:
the block below needs only what it returns, and a page costs half the context.

One block per component, in this order, so a researcher can scan a page of them:

```
**Norfolk Gazette and Publick Ledger** · 17 Sep 1814 · domestic_news · green
Commodore Tingey's report on the burning of the Washington Navy Yard: ordered to destroy
shipping and stores if the enemy succeeded; the yard fired about 8:20 pm; the Capitol
already burning as he left.
Persons: thomas tingey, gen. ross · Location: washington navy yard · Keywords: navy yard, burning, capitol
https://snewpapers.com/components/<uuid>_evt_0
```

Paper name in title case (the API lowercases), date as day month year, then label and tier.
The summary as given. The persons, the locations and a few keywords, plus the structured fields
that carry the answer (from `fields`), not all of them. Last, the `site_url` on its own line - the snewpapers.com page is the citation and
every block carries it; the LoC PDF link joins it on full text (below), where the researcher
will want to check the source. For a caution hit under guardrails: the paper, date, label and
`caution_description`, and one line saying the text is withheld under guardrails.

## Full text

Head it with the citation line, then **the structured fields** for its label (every
non-empty one from `fields`, as a short list: for an obituary the name, death date, age,
residence, survivors; for a runaway the name, age, description, reward, destination) - the
researcher asked for the text, and the fields are the extractor's reading of it. Then the
text. Print it as paragraphs. The `content` keeps the paragraph structure of the extraction;
do not reflow it into one block and do not "correct" it - the extractor already cleaned
the OCR and deliberately kept archaic spellings, so what you see is meant to be as printed.
Keep `[TABLE]` placeholders and the spliced tables where they appear. If a glitch remains,
quote it and add a note rather than editing it. Foot it with the site link and the LoC
PDF link, and give the `char_count` when it is long so the researcher knows what they are
reading.

## Counts and histograms

Default to an aligned text chart in a code block - it survives every host:

```
decade   docs
1790s    1,204  ████████████
1800s    3,981  ████████████████████████████████████████
1810s    2,455  ████████████████████████
1820s      612  ██████
```

Scale the longest bar to ~40 characters, right-align the numbers, keep the order the data
has (chronological for histograms, descending for term counts). Say what was counted
(documents matching the query, not the whole corpus) and the query in one line beneath.

Draw a real chart when the host can render one and the researcher will keep it: a
matplotlib PNG where you can run Python (Grok Bot's workspace, Claude Code, ChatGPT's code
interpreter), an HTML/SVG artifact on Claude, a canvas on ChatGPT. Bar charts for term
counts and decades, a line for year histograms, small multiples for `nested_facets`
(one panel per paper). Label axes with the unit (documents) and put the query in the title.
Never chart fewer than three points or counts under ten.

## Nested facets

`{lccns: [year_histogram]}` is a table of papers by year: rows are papers, columns years,
cells counts; render it as a table with the row totals, or as small multiples.

## Citations

Every component detail carries a `citation` object: `newspaper`, `lccn`, `issue_date`,
`pages`, `label`, `event_id`, `site_url`, `loc_issue_url` and `formatted` (`paper, day
month year, p. N, label. site link`), the same with or without text - cite from it rather
than assembling your own. For a hit you have not opened, the same fields are on the hit.
When you quote, quote from full text you fetched, never from a summary, and give the page.

## A research folder

When the researcher wants to keep digging, or the host cannot display caution text, offer
once: "Want a research folder for this topic?" Then:

Use `references/research-folder.md`: first check what you can actually reach (the
researcher's own machine; a storage connector loaded now; one you could enable; nothing),
name the real options in the offer, confirm the destination once before the first write,
and use the lite layout on connector storage. A sandbox that resets or that the researcher
cannot browse does not count as their filesystem. Never paste the key or the cursor into
the folder.

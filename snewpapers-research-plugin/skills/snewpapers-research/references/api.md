# The tools, exactly

REST base `https://api.snewpapers.com` (bearer key), MCP `https://mcp.snewpapers.com/mcp`.
MCP tool names are `research_*`; the REST paths are in brackets. `research_search`,
`research_facets` and `research_components` take their arguments under one `query` key.

| tool | cost | what |
|---|---|---|
| `research_corpus` [GET /corpus] | 0 | size, span, decade histogram, quality/caution/embed counts, the Chronicling America denominator and coverage fraction |
| `research_titles` [GET /titles] | 0 | papers: `state` (full name, "virginia"), `city`, `county`, `ethnicity` (values from the ethnicity facet, e.g. "African American"), `q` (name contains), `processed_only`, `english_only`, `limit` (default 100), `offset`; returns `total`, `refreshed_at`, `titles` |
| `research_title` [GET /titles/{lccn}] | 0 | one paper: LoC span vs processed years; with `year`, the processed issue dates |
| `research_labels` [GET /labels] | 0 | every label with `embed_rule`, `field_prefix`, `has_themes`, `fields` |
| `research_guide` [GET /guide] | 0 | this skill, served: `section` = `start` (default; lists the rest), `api`, `examples`, `caveats`, `display`, `research-folder`. A host that cannot hold a skill file reads it from here |
| `research_vocabulary` [GET /vocabulary] | 0 | `label`, `lccn`, `state`, `year_from`, `year_to`, `size`: the label's types and themes (whole) and top keywords |
| `research_facets` [POST /facets] | 2 | aggregations over the match, no hits |
| `research_search` [POST /search] | 1 per page | 25 summaries per page, one per component |
| `research_component` [GET /components/{id}] | 1 (+3 with text, once) | one component whole |
| `research_components` [POST /components] | same as single: 1 each, or with text 3 each the first time then 0 | up to 25 ids in one transaction |
| `research_account_tokens` [GET /account/tokens] | 0 | balance, grant, period, purchased, this period's spend by operation, the last 20 charges |

## Search / facets query

```json
{
  "filters": {
    "quality_tiers": ["green", "yellow"],          // default (both served tiers); ["green"] for clean text only
    "embed_worthy": true,                          // optional
    "caution": false,                              // optional
    "resolved": true,                              // optional
    "start_date": "1812-06-18", "end_date": "1815-02-18",
    "regions": ["south_atlantic"],                 // see regions below
    "labels": {"values": ["domestic_news", "foreign_news"], "mode": "include"},   // or "exclude"
    "term_filters": [{"field": "keywords", "values": ["navy yard", "capitol"]}],  // OR within, AND across
    "any_of": [{"field": "themes", "values": ["slavery_abolition"]},
               {"field": "keywords", "values": ["slave trade"]}],                  // at least one
    "issue_uuid": "2ff816a8-…",                    // issue browse
    "exclude_uuids": ["…"],                        // up to 100 already-seen components
    "created_after": "2026-09-01",                 // only components first visible since then (the corpus grows daily)
    "updated_after": "2026-09-28T10:00:00Z",       // only components whose extraction changed since then
    "fields_present": ["obi_cause_of_death"],      // structured fields that must be filled (AND); fields_absent = the complement
  },
  "text": {
    "must_have_phrase": "navy yard",
    "must_have_keywords": "british",               // AND of every word
    "should_have_keywords": "burnt burned destroyed conflagration",   // OR; spellings here
    "should_have_phrase": "public buildings",
    "must_not_have_keywords": "theatre",
    "semantic_text": "what the British burned in Washington in 1814"
  },
  // search only:
  "page": 1, "cursor": null, "sort": "relevance", "expand_events": false, "guarded": true,
  "hit_shape": "full",                              // or "compact": identity + summary only, half the bytes, same price
  // facets only:
  "flat_facets": ["labels", "lccns", "year_histogram", "field:obi_cause_of_death"],
  "nested_facets": {"decade_histogram": ["field:obi_cause_of_death"]},
  "facet_size": 500                                // values per term facet, named and field: (default 100 for field:, 25 for locations; max 1000)
}
```

## The flags on every component

| flag | values | meaning |
|---|---|---|
| `quality_tier` | `green` `yellow` | how faithful the text is to its OCR source, from the evidence recorded per component: similarity to the source, length against the source (shorter = lost text, longer = invented text), the share of characters the OCR was unsure of, and the extractor's own coherence score. Roughly 91% green / 8% yellow / 0.3% red, because damaged pages never reach the index. Green and yellow are served, both by default; red is never served (not a hit, a bucket or a fetch) - `research_corpus` reports its count. `quality_tier_why` on every hit names the deciding condition (e.g. `fuzz_lt_92`, `lt80_gt_0.05`, `unresolved_cohesion_lt_90`). An unresolved component is NOT yellow for that alone: completeness has its own `resolved` flag. |
| `embed_worthy` | true/false | the extractor judged the text narrative enough to be worth indexing for meaning (~16% of all components). Only embed-worthy components in the narrative genres can be found by `semantic_text`. |
| `caution` | true/false | the extractor flagged the text as offensive by modern standards; `caution_description` says why. Under `guarded: true` such hits keep metadata, description and links only - their `summary`, lists and `fields` are empty, which is the guard working, not a filter failing to apply. For research the better experience is `guarded: false` on every call, after asking the researcher once at the start (SKILL.md, caution section). |
| `resolved` | true/false | false = something indicated the component is incomplete: continued from or in another issue (innocuous), a lost opening, or a segmentation slip. |
| `chain_members` | int | how many page fragments were merged into this component; the evidence is the worst case over them. |
| `has_table` | true/false | the text carries a spliced table where the page had one. |

- Term fields: `lccns newspapers states counties cities types themes keywords persons locations ethnicity`.
- Facets: the term fields plus `labels quality_tier caution embed_worthy resolved year_histogram decade_histogram month_histogram week_histogram day_histogram`. At least one of `flat_facets` / `nested_facets` is required; nested is depth 2, and a nested result comes back under the key `{parent}_nested` (e.g. `lccns_nested`), flat ones under their own names.
- `facet_size` (1-1000) sets how many values a term facet returns - named ones too (`locations` is 25 by default). The listed counts are exact. Histogram keys: `year_histogram` `1853`, `decade_histogram` `1850`, `month_histogram` `1853-07`, `week_histogram` and `day_histogram` `1853-07-04`. Week buckets are calendar (ISO) weeks starting Monday, so the first key can fall before `start_date`; its count still holds only in-range docs.
- `states` / `cities` / `counties` are where the paper was PRINTED, not what the item is about: 1793 Philadelphia fever coverage faceted by `states` shows New Hampshire and West Virginia papers reporting it. The place a story is ABOUT is `locations`.
- `hit_shape: "compact"` returns hits with only uuid, event_id, event_idx/count, score, newspaper, lccn, issue_date, label, quality_tier, caution (+ description) and summary, site_url - about half the bytes of a page. Skim with compact, then `research_component` the few that matter; `full` (the default) adds the lists, structured fields, dates and tier reason. The `cursor` is a short token valid 10 minutes from its last use.
- Every search / facets response carries `corpus: {docs, components, newest_first_indexed_at, measured_at}` - the served corpus (unserved labels excluded), the same two numbers `research_corpus` gives: `docs` are event docs (what facets and `total_docs` count), `components` are distinct components (what `total_components` counts). The stamp is cached for up to 5 minutes, so `measured_at` can trail the response by that much. Stamp your numbers with it, and pass `newest_first_indexed_at` as `filters.created_after` on the next pass to see only what arrived since.
- `text.semantic_mode`: `widen` (default) ORs semantic matches with your `should_*` keywords - should is optional by definition, and meaning can reach docs the words miss. `rerank` confines `semantic_text` to docs that also match a `should_*` clause. **A `must_*` clause is always enforced on the semantic side in both modes**: to anchor a topic (1918 flu, not WWI letters) put the one word every hit needs in `must_have_keywords`, then let `semantic_text` rank within it.
- Unknown or misplaced keys are a **422 with a hint, uncharged** (`filters.indexed_at` -> `created_after`; `keywords` at the top -> `text.*`; a list where a string is expected). There is no `query` wrapper in the REST body (the MCP tool takes `{query: {...}}`).
- Presets: label counts = `flat_facets: ["labels"]`; coverage for a place x era = `filters.regions` (or a `states` term filter) + `flat_facets: ["decade_histogram"]`, with no text; hotspots = `nested_facets: {"lccns": ["year_histogram"]}` under an anchored text match; a census of a structured field = `filters.fields_present: ["obi_cause_of_death"]` + `flat_facets: ["field:obi_cause_of_death"]`, nested under `decade_histogram` for the trend.
- Field facets (a census of a structured field): `field:<prefix_name>` for any per-label field GET /labels lists, in `flat_facets` or as a nested parent / child, e.g. `"field:obi_cause_of_death"`, `"field:run_reward_amount"`, `"field:auc_sale_location"`. Prose fields (`*_notable_details`, `*_description`) are not facetable. The result is `{values: {value: count}, other, present, absent}`: `other` = matching docs whose value fell outside the list (raise `facet_size`, default 100, max 1000, until it is small), `present` / `absent` = docs with / without the field in the scope (the whole match, or the parent bucket when nested). Values are the extractor's strings, lowercased, NOT normalised - "consumption", "pulmonary consumption" and "decline" are separate buckets; group them yourself from the top list. Pair with `filters.fields_present` for a denominator-only count or to search within the filled ones. Same price as any facets call.
- Sort: `relevance` (default), `issue_date:asc`, `issue_date:desc`, `pages:asc` (issue browse).
- Regions are US CENSUS divisions and regions, not colloquial ones (`south_atlantic` runs from Delaware to Florida and includes West Virginia; "the Carolinas" is a `states` term filter): divisions `new_england mid_atlantic east_north_central west_north_central south_atlantic east_south_central west_south_central mountain pacific`; regions `northeast midwest south west`.
- Pages: a search stops at page 10 (250 hits); page 2+ needs the `cursor` from page 1 (a point in time, alive ~10 min from its last use; expired = 400, start again). Issue browse pages the whole issue.
- Dates are issue dates, `YYYY-MM-DD`, inclusive. **The corpus starts in 1736**: an earlier `start_date` is a 422, not an empty result - for "colonial" use 1736.
- `created_after` / `updated_after` are processing dates, not issue dates: every hit carries `first_indexed_at` (when it became visible in the API) and `updated_at` (when its extraction last changed). A researcher repeating a question passes the time of the last pass and gets only what is new; a merged or re-extracted component shows up under `updated_after`, a component that vanished shows up only as a 404 on its uuid.
- `persons` / `locations` (filters and facets) are LIGHTLY normalised name strings: lowercased, leading honorifics and ranks (`mr.`, `mrs.`, `miss`, `capt.`, `gen.`, `dr.`, `rev.`, `hon.` …) and a trailing `esq.` stripped, hyphens folded, so `Capt. John Smith`, `mr. john smith` and `john smith` are one bucket and one filter value. `jun.`/`sen.` and `estate of …` are kept apart on purpose. They are NOT canonicalised: `norfolk`, `norfolk, va.` and `norfolk, virginia` are three values - fold them yourself from a facet. There is NO entity resolution: two John Smiths in different papers share a bucket, and the paper/place/year facets separate them. Names are the extractor's per-component strings (persons named in the item; locations the item is ABOUT, not where the paper was printed - that is `states`/`cities`).

## A hit (search)

`uuid`, `event_id` (`{uuid}_evt_N` - keep this), `event_idx`, `event_count`, `score` (0.0 on every hit under any sort other than relevance - the engine does not score under a field sort; re-run with `sort: relevance` to triage), `newspaper`,
`lccn`, `state`, `issue_uuid`, `issue_date`, `year`, `pages`, `label`, `quality_tier`, `quality_tier_why`, `caution`,
`caution_description`, `embed_worthy`, `chain_members`, `resolved`, `summary`, `persons`,
`locations`, `keywords`, `themes`, `types`, `has_table`, `fields` (the per-label structured
fields, prefixed), `site_url`, `first_indexed_at`, `updated_at`. Plus `tokens_charged` /
`tokens_remaining` on the response, `issue_pages` (issue browse only: the issue's page count, so `total_components / issue_pages` sizes the read before you fetch; null otherwise), and `mode`: `keywords` (BM25 only), `semantic` (meaning only),
`hybrid` (both - semantic_text has widened the keyword match) or `none` (filters only). Facets
responses carry `mode` too; a histogram is of that match, not of the topic.

## A component

Everything a hit has (including `quality_tier_why`), plus every `event` (idx, id, summary, lists, fields, site_url),
`evidence` (the numbers behind the quality tier), `links` (`loc_issue_url`, `loc_pdf_pages`,
`site_issue_url`, `site_component_url`), `citation` (`newspaper`, `lccn`, `issue_date`, `pages`, `label`,
`event_id`, `site_url`, `loc_issue_url`, `formatted` - cite from it, with or without text), `thumbs` (`pages`: one shared image per page the component touches, `sm` 400 px / `lg` 1,200 px; `clip_sm` / `clip_lg`: the component's own clip per page), and with `include_text` the `content`
(tables spliced in where the page had them) and `char_count`. `issue_pages` is the whole issue's page count (the component's own pages are `pages`). `include_boxes=true` (free, also on `research_components` and `research_search`) adds `boxes: [{page, rects: [[x0, y0, x1, y1], ...]}]` - the component's rectangles per page as fractions of the page image (0-1), so they scale to the LoC scan, our `thumbs.pages` images or a PDF page; a story in two columns has two rectangles, a cross-page story an entry per page. Most research never needs it. `requested_event_idx` echoes the `requested_event_idx` echoes the
`_evt_N` you asked with.

## Labels and their structured fields

The field names below are the live ones, exactly as `research_labels` returns them and as
they appear in a hit's `fields`. (Generated from the API's label schema.)

| label | embeds | fields |
|---|---|---|
| domestic_news, foreign_news | conditional | `news_casualties_or_outcome`, `news_event_date`, `news_key_persons`, `news_primary_location` |
| local_news | conditional | `lcl_event_date`, `lcl_key_persons`, `lcl_primary_location` |
| editorial | conditional | `ed_key_arguments`, `ed_key_figures_or_entities`, `ed_primary_topic`, `ed_stance_or_tone` |
| letter_to_editor (themes) | conditional | `let_author_or_signatory`, `let_main_argument`, `let_notable_details`, `let_recipient` |
| obituary | conditional | `obi_age_at_death`, `obi_cause_of_death`, `obi_death_date`, `obi_death_location`, `obi_family_members`, `obi_funeral_date`, `obi_funeral_location`, `obi_funeral_notes`, `obi_honorifics_or_titles`, `obi_legacy_or_bequests`, `obi_name`, `obi_notable_accomplishments`, `obi_notable_details`, `obi_residence`, `obi_survivors_or_heirs` |
| notice | conditional | `not_call_to_action`, `not_consequences`, `not_date_mentioned`, `not_deadline_or_timeframe`, `not_description`, `not_items_or_property`, `not_key_organizations_or_estates`, `not_key_persons`, `not_notable_details`, `not_primary_location`, `not_reward_or_charges`, `not_signed_by` |
| runaway | **never** | `run_age`, `run_clothing_taken`, `run_complexion`, `run_hair_and_eyes`, `run_height`, `run_name`, `run_owner_location`, `run_owner_or_subscriber`, `run_physical_marks`, `run_reward_amount`, `run_reward_notes`, `run_runaway_date`, `run_skills_or_trade`, `run_speech_or_accent`, `run_status`, `run_suspected_destination`, `run_warnings` |
| story (themes) | conditional | `sto_event_date`, `sto_key_persons`, `sto_location` |
| poem (themes) | conditional | `poe_author_or_attribution`, `poe_form_or_style`, `poe_key_lines_or_stanzas`, `poe_occasion_or_subject`, `poe_poem_title` |
| literary (themes) | conditional | `lit_author_or_attribution`, `lit_form_or_style`, `lit_key_lines_or_stanzas`, `lit_occasion_or_subject`, `lit_segment_title` |
| auction | **never** | `auc_items_for_sale`, `auc_notable_details`, `auc_payment_terms`, `auc_quantity_or_details`, `auc_sale_date`, `auc_sale_location`, `auc_seller_or_authority` |
| cost_of_goods | **never** | `cog_currency`, `cog_market_location`, `cog_notes`, `cog_price_entries`, `cog_report_date` |
| reward | **never** | `rwd_contact_or_authority`, `rwd_description`, `rwd_location_lost`, `rwd_notable_details`, `rwd_primary_subject`, `rwd_reward_amount` |
| personal_ad | **never** | `pad_location`, `pad_notable_details`, `pad_person_or_item_sought`, `pad_person_seeking`, `pad_primary_topic`, `pad_terms_or_reward` |
| errata | **never** | `err_corrected_text`, `err_errata_details`, `err_original_text`, `err_reference` |
| epigraph | **never** | `epi_attributed_to`, `epi_original_language`, `epi_source_work`, `epi_theme`, `epi_translation` |
| crossword_puzzle | **never** | `puz_author_or_syndicate`, `puz_clue_count`, `puz_previous_answer`, `puz_puzzle_title`, `puz_subject_details` |
| train_schedules | **never** | `trn_agent_or_contact`, `trn_carrier_or_line`, `trn_effective_date`, `trn_service_notes`, `trn_stations_or_stops`, `trn_termini_or_routes`, `trn_ticket_office_locations` |
| theater_listings | **never** | `tht_additional_entertainments`, `tht_benefit_for`, `tht_cast_highlights`, `tht_main_play`, `tht_notable_details`, `tht_performance_date`, `tht_ticket_prices`, `tht_venue` |
| radio_listings, tv_listings | **never** | `bcast_channels_or_frequencies`, `bcast_days_or_dates`, `bcast_medium`, `bcast_networks_or_affiliations`, `bcast_notable_persons`, `bcast_notable_programs`, `bcast_program_count`, `bcast_stations`, `bcast_time_span` |
| birth_announcement | conditional | `bir_birth_date`, `bir_birth_location`, `bir_child_name`, `bir_child_sex`, `bir_notable_details`, `bir_parent_occupation_or_affiliation`, `bir_parents`, `bir_residence` |
| wedding | conditional | `wed_bride_family`, `wed_bride_fortune`, `wed_bride_name`, `wed_bride_titles`, `wed_groom_family`, `wed_groom_name`, `wed_groom_titles`, `wed_marriage_date`, `wed_marriage_location`, `wed_notable_details`, `wed_notable_praise` |
| society | conditional | `soc_event_date`, `soc_key_persons`, `soc_location`, `soc_notable_items`, `soc_society_details` |
| sports_report | conditional | `spr_event_date`, `spr_notable_details`, `spr_outcome`, `spr_primary_location`, `spr_stakes_or_purse`, `spr_teams_or_participants` |
| shipping | conditional | `shp_cargo`, `shp_cargo_notes`, `shp_persons`, `shp_ports_or_locations`, `shp_vessel_names`, `shp_vessel_types` |
| weather_report | conditional | `wth_event_date`, `wth_impact_or_damage`, `wth_primary_location`, `wth_weather_description`, `wth_weather_details` |
| recipe | conditional | `rcp_attributed_source`, `rcp_cooking_time`, `rcp_cuisine_or_origin`, `rcp_dish_name`, `rcp_equipment`, `rcp_ingredients`, `rcp_method_details`, `rcp_yield_or_servings` |
| review | conditional | `rev_author_or_subject`, `rev_main_critique`, `rev_notable_details`, `rev_reviewer`, `rev_work_title` |
| commercial | conditional | `com_event_date`, `com_key_commodities`, `com_key_figures_or_entities`, `com_notable_details`, `com_primary_location` |
| filler | conditional | `fil_key_persons`, `fil_location`, `fil_primary_topic` |

`advertisement` exists in the data but is not exposed for the time being. "conditional" = indexed for meaning when
the extractor judged the text narrative enough (`embed_worthy`); "never" = keyword and
structured search only, whatever `embed_worthy` says.

## What each label is

| label | the gist |
|---|---|
| domestic_news | recent American news reported to inform: elections, disasters, fires, crimes, courts, appointments |
| foreign_news | reports from outside the United States (European wars, colonial affairs); every paper is American |
| local_news | brief local items about the immediate community, often one person's ordinary movements |
| editorial | opinion in the paper's or a contributor's voice: partisan comment, the leader column |
| letter_to_editor | reader letters and debates |
| story | a narrative told for the tale itself: dramatic events, curiosities, crimes, shipwrecks, survival |
| literary | serialized fiction, essays, travel letters, sometimes in chapters |
| poem | verse |
| review | a critique of a book, play, performance |
| obituary | death notices, biographical, with dates and family |
| wedding | marriage announcements |
| birth_announcement | a child born to named parents |
| society | the social page: balls, receptions, dinners, visits of the social set |
| notice | formal announcements to the public: legal and government (court orders, proclamations), meetings, elections, estates, civic and commercial notices |
| runaway | notices of people who ran away - enslaved people, indentured servants, apprentices, deserters - descriptive and legal, with a reward |
| reward | rewards for lost or stolen items or for tasks |
| auction | auction announcements with dates and places |
| personal_ad | short classifieds: wanted, rooms, items for sale |
| commercial | business, trade and market news in prose: money, banking, tariffs, trade policy |
| cost_of_goods | price lists and market quotes; the numbers are the payload |
| shipping | marine news: arrivals, departures, cargoes, wrecks |
| sports_report | results and recaps |
| weather_report | forecasts and reports |
| recipe | ingredients and steps |
| theater_listings | showtimes, benefits, casts |
| train_schedules | railroad timetables |
| radio_listings, tv_listings | broadcast schedules |
| crossword_puzzle | grids and clue lists |
| filler | jokes, anecdotes, curiosities used to fill space |
| epigraph | a quotation at the head of a story or the paper |
| errata | corrections |

## Errors

400 bad cursor or page past the end (a hybrid page past the matches returns an empty page, not
an error); 401 bad or missing key; 402 insufficient tokens (`detail.tokens_remaining`,
`detail.price`); 403 `research:text` scope missing, or 503 while the revocation list is stale;
404 unknown component / issue / lccn; 422 invalid query (e.g. no facet kind, `exclude` inside
`any_of`, an unknown or misplaced key) - the body carries `problems` (one line each) and an `example`
of a valid request for that endpoint; nothing is charged.

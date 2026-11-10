# Demo recording for the OpenAI submission (about five minutes)

OpenAI requires a reviewer-accessible recording that shows the test cases and the app working.
Record a screen capture of ChatGPT with the SNEWPapers connector installed, signed in as
openai-review@snewpapers.com. Narration is optional; the prompts below are the test cases in
`openai-plugin/plugin.json`, in order, so the reviewer can match them. Upload as an unlisted
YouTube video or a shared Drive link anyone with the link can play, and put the URL in
`extensions.com.openai.review.demo_recording_url`.

| # | What to show | Prompt |
|---|---|---|
| 0 | Connecting: add the connector, sign in on snewpapers.com, approve the consent screen | — |
| 1 | The guide and the corpus summary, both free | What is in the SNEWPapers corpus, and how should I use it? |
| 2 | Coverage before topic: a facet call, the honest picture of a state x decade | Which Louisiana newspapers from the 1850s does SNEWPapers cover? |
| 3 | A search page: 25 cited summaries, tokens reported | Find reports of yellow fever in New Orleans in 1853 and show me a page of summaries. |
| 4 | Full text on request: citation, structured fields, LoC link, 3 tokens | Open the first of those in full and give me the citation. |
| 5 | A structured-field genre: runaways by keyword, tabulated with citations | Find runaway advertisements that name a blacksmith, with the reward offered and where the owner thought he was headed. |
| 6 | A caution hit under guardrails: withheld with a description and a link, then shown after the researcher opts in | Show me what papers printed about a lynching in the 1890s. / Yes, show me the caution content as printed. |
| 7 | The balance: the free account call | What is my token balance? |
| N1 | Out of period: declines, offers the nearest decades | What did American newspapers say about the moon landing in 1969? |
| N2 | Out of place: declines, explains the corpus boundary | Find me the Times of London's coverage of the Crimean War. |
| N3 | A write request: explains the tools are read-only, points to support | That obituary has a typo in the name - please fix it in the SNEWPapers database. |

Keep each exchange on screen long enough for the reviewer to read the citations and the
"tokens charged / remaining" lines. If the review account's balance runs low during rehearsal,
tell the API session and it will post a top-up period.

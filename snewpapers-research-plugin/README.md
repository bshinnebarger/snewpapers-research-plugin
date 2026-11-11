# SNEWPapers Research

Research historical US newspapers, 1736 to 1963, from a conversation with Claude. The archive holds
newspaper pages from the Library of Congress' Chronicling America collection, cut into components
(a story, an obituary, a runaway advertisement, a poem, a notice) with a summary, extracted people
and places, a genre label and structured fields, so Claude can search by keyword, phrase or meaning,
narrow with facets, and read the full text of what it finds, citing the paper, the date and the page.

## Use it

Connect the bundled **snewpapers** connector from the plugin's Connectors tab and sign in with your
snewpapers account (a subscription or trial is required; set one up at https://snewpapers.com). Then
ask about a person, a place, an event or a genre of the period: "what did Louisiana papers print
about yellow fever in 1853", "find runaway advertisements naming a blacksmith", "obituaries for a
Hartford shipwright in the 1840s". The skill teaches Claude the method: explore with facets first,
search in pages of 25 summaries, open full text only for the components that matter, and cite each
one with its link on snewpapers.com. Setup and troubleshooting: https://snewpapers.com/connect.

## Data

The plugin itself stores nothing and runs no code. Its skill is text that Claude reads. The connector
sends your search requests (keywords, filters, the components you open) to the snewpapers research
API at mcp.snewpapers.com over HTTPS with your OAuth token. snewpapers records each request against
your account for billing, abuse prevention, debugging and aggregate product analytics, as described
in its privacy policy: https://snewpapers.com/privacy. Semantic search text is sent to OpenAI to
compute an embedding. Nothing from your conversation reaches snewpapers except the requests Claude
makes through the connector. Each tool call spends research tokens from your account's monthly
allowance; the tools report the cost and your remaining balance.

## Content

The newspapers are reproduced as printed. About four percent of components carry a caution flag
(slurs, graphic violence, sexual content by the standards of their time); those return only a
description and a link unless the researcher turns the guard off for a call.

## Support

https://snewpapers.com/contact or support@snewpapers.com. Terms: https://snewpapers.com/terms.

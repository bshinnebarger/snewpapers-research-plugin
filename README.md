# snewpapers-research-plugin

The Claude plugin for snewpapers (https://snewpapers.com): the research skill and a reference to the
snewpapers MCP connector, packaged for Anthropic's directory. The plugin folder is
`snewpapers-research-plugin/`; its README describes what it does and what data it sends.

The skill text is maintained in the snewpapers API repository and copied here on each release.

## OpenAI (ChatGPT) package

`openai-plugin/` is the portable plugin OpenAI's portal takes as a ZIP: `plugin.json` (the listing,
review test cases and publication settings under `extensions.com.openai`), `mcp.json` (the same
MCP server URL, OAuth via ChatGPT's client metadata document with `private_key_jwt`), the same
skill, and the logo. Build the upload with `scripts/build_openai_zip.sh`; the demo recording the
review requires is scripted in `docs/openai-demo-script.md`.

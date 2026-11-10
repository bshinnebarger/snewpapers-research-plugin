#!/usr/bin/env bash
# Build the ZIP OpenAI's portal takes: the openai-plugin folder's CONTENTS at the zip root.
set -euo pipefail
cd "$(dirname "$0")/../openai-plugin"
out="../snewpapers-research-openai-$(python3 -c "import json;print(json.load(open('plugin.json'))['version'])").zip"
rm -f "$out"; zip -qr "$out" plugin.json mcp.json skills assets -x '*.DS_Store'
unzip -l "$out" | tail -n +2 | head -20; echo "wrote $out"

#!/usr/bin/env bash
# install.sh — Global install for IBM Pre-Sales Demo Builder (macOS/Linux)
# Merges mode, skills, rules, and MCP config into ~/.bob/
# Safe: merges rather than overwrites existing config. Idempotent.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOB_DIR="$HOME/.bob"
SOURCE_BOB="$SCRIPT_DIR/.bob"
SLUG="ibm-presales-demo-builder"

echo ""
echo "IBM Pre-Sales Demo Builder — Global Install"
echo "============================================"
echo ""

# 1. Create required directories
echo "→ Creating Bob directories..."
mkdir -p "$BOB_DIR/skills"
mkdir -p "$BOB_DIR/rules"

# 2. Merge custom_modes.yaml
echo "→ Merging custom_modes.yaml..."
MODES_SRC="$SOURCE_BOB/custom_modes.yaml"
MODES_DEST="$BOB_DIR/custom_modes.yaml"

if [ ! -f "$MODES_DEST" ]; then
  # No global file yet — copy directly
  cp "$MODES_SRC" "$MODES_DEST"
  echo "  ✓ custom_modes.yaml created."
elif grep -q "$SLUG" "$MODES_DEST" 2>/dev/null; then
  echo "  ℹ Mode '$SLUG' already present — skipping."
else
  # Append the mode entries, stripping the top-level 'customModes:' key
  # to avoid a duplicate YAML key in the merged file
  echo "" >> "$MODES_DEST"
  grep -v "^customModes:" "$MODES_SRC" >> "$MODES_DEST"
  echo "  ✓ Mode appended to existing custom_modes.yaml."
fi

# 3. Merge mcp_settings.json
echo "→ Merging mcp_settings.json..."
MCP_SRC="$SOURCE_BOB/mcp.json"
MCP_DEST="$BOB_DIR/mcp_settings.json"

python3 - <<EOF
import json, os

src_path  = "$MCP_SRC"
dest_path = "$MCP_DEST"

# Load source servers from the package's mcp.json
with open(src_path, "r") as f:
    src = json.load(f)
src_servers = src.get("mcpServers", {})

# Load existing global mcp_settings.json (or start empty)
if os.path.exists(dest_path):
    with open(dest_path, "r") as f:
        dest = json.load(f)
else:
    dest = {}

existing_servers = dest.get("mcpServers", {})

# Merge: existing entries take precedence on key conflict
merged = {**src_servers, **existing_servers}
dest["mcpServers"] = merged

with open(dest_path, "w") as f:
    json.dump(dest, f, indent=2)
    f.write("\n")
EOF

echo "  ✓ mcp_settings.json merged."

# 4. Copy skills (overwrite — package is authoritative for its own skills)
echo "→ Copying skills..."
cp -r "$SOURCE_BOB/skills/"* "$BOB_DIR/skills/"
echo "  ✓ Skills copied."

# 5. Copy rules
echo "→ Copying rules..."
cp -r "$SOURCE_BOB/rules/"* "$BOB_DIR/rules/"
echo "  ✓ Rules copied."

echo ""
echo "✅ Done — restart Bob to activate the IBM Pre-Sales Demo Builder mode."
echo ""

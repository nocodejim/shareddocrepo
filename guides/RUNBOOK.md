# Photo/Measurements → 3D Print Runbook

Pipeline: **Claude Code → Blender (via MCP) → STL → OrcaSlicer → gcode → Ender 3 S1**

## Start a modeling session

```bash
blender-mcp-start          # opens Blender; MCP bridge auto-starts on port 9876
cd ~/blender-projects && claude
```

That's it. The `blender` MCP server is registered user-wide in Claude Code, so any
session can use it once Blender is running. Everything you model shows up live in
the Blender window — you can watch, or grab the viewport yourself between commands.

**Known quirk (upstream):** the very first MCP command in a session sometimes
fails. Just tell Claude "try again" — it works from then on.

## Workflow A — Measurements → model

Tell Claude what you want with dimensions. Template:

> Using the blender MCP, model a [part] for 3D printing. Dimensions in mm:
> [list them]. It must be watertight/manifold, sit flat on Z=0, walls at least
> 1.2mm, and use ≥0.2mm clearance anywhere it mates with another part.
> Export to ~/blender-projects/[name].stl and verify the bounding box.

Example: *"a wall bracket for a 32mm diameter curtain rod, two M4 screw holes
60mm apart, 4mm thick"*.

## Workflow B — Photo + measurements → model

Drag the photo into the Claude Code prompt (or give its path) and anchor the
scale with at least one real measurement:

> Here's a photo of [thing]. The [feature] is exactly [X]mm. Estimate the other
> dimensions from proportions, list them for my confirmation, then model it.

Claude reads proportions off the image, you confirm/correct the numbers, then it
builds the part. **Confirm the numbers before it models** — proportions from a
photo are estimates; the anchor measurement is what makes it printable.

For organic/sculptural shapes (figurines, replicas): with the Hyper3D key set,
say "generate this with Hyper3D from the photo, then scale it so [dimension] is
[X]mm." AI meshes need that explicit rescale — they come in at arbitrary size.

## Workflow C — Known product from the internet

> Find or recreate a [product name]. If Sketchfab has a good model, import and
> scale it; otherwise research its published dimensions and model it from scratch.

Sketchfab route needs the API key set (below). Watch licenses — many Sketchfab
models are non-commercial. For functional replacement parts, scratch-modeling
from researched dimensions usually beats a downloaded visual mesh.

## Before every export — the checklist Claude runs

1. **Units**: scene is mm (1 Blender unit = 1mm — set automatically at launch).
2. **Manifold**: no non-manifold edges (bmesh check or 3D-Print Toolbox, which is installed).
3. **Orientation**: largest flat face on Z=0; overhangs >50° get chamfers, reorientation, or a note that supports are needed.
4. **Export**: `bpy.ops.wm.stl_export(filepath=...)`, then verify the STL bounding box matches spec.

## Slice it

```bash
slice-for-ender ~/blender-projects/part.stl
# → ~/blender-projects/gcode-part/plate_1.gcode  — copy to SD card / printer
```

Uses the Ender 3 S1 0.4-nozzle profile, 0.20mm layers, generic PLA (200°C / bed 60°C
— matches your Inland matte white PLA). For parts needing supports, finer layers, or
different infill, open the GUI instead: `orca-slicer part.stl` (first run: pick
Creality → Ender-3 S1 in the setup wizard).

Quality guide: 0.20mm Standard for functional parts; 0.12–0.16mm for visual detail;
add brim for tall/thin parts; 15% infill default, 40–60% for load-bearing.

## API keys (one-time)

Edit `~/.config/blender-mcp/keys.env`:

- **Hyper3D Rodin** (AI photo→3D): sign up at https://hyper3d.ai → API key → `HYPER3D_API_KEY=...`
  (or in Blender's sidebar panel, button "Set Free Trial API Key" for the shared trial key)
- **Sketchfab** (model downloads): https://sketchfab.com/settings/password → API token → `SKETCHFAB_API_KEY=...`

Keys are injected on every Blender launch; restart Blender after editing.
PolyHaven (free textures/HDRIs) is already on, no key needed.

## Troubleshooting

| Symptom | Fix |
|---|---|
| First MCP command fails | Known upstream quirk — retry once |
| "Connection refused" on port 9876 | Blender isn't running or bridge stopped: relaunch `blender-mcp-start`; check sidebar (N key) → BlenderMCP panel |
| MCP tools missing in Claude | `claude mcp list` should show `blender ✔`; restart the Claude session after starting Blender |
| Port 9876 already in use | A zombie Blender holds it: `pkill -f blender` then relaunch |
| Model imports tiny/huge in slicer | Scene units drifted — relaunch via `blender-mcp-start` (resets mm units), or scale ×1000/÷1000 |
| Slicer CLI errors on a part | Use the GUI (`orca-slicer part.stl`) — CLI validation is stricter than the GUI |

## What's installed where

| Thing | Location |
|---|---|
| Blender 4.5.11 LTS | `~/opt/blender-4.5/` (`blender` on PATH) |
| OrcaSlicer 2.4.1 | `~/opt/orcaslicer/` (`orca-slicer` on PATH) |
| blender-mcp addon | Blender user addons (`blender_mcp_addon`) + auto-start |
| Launcher | `~/.local/bin/blender-mcp-start` |
| Slicer helper + profiles | `~/.local/bin/slice-for-ender`, `~/.config/blender-mcp/profiles/` |
| API keys | `~/.config/blender-mcp/keys.env` (chmod 600) |
| MCP registration | `claude mcp` user scope: `uvx blender-mcp` |
| Startup config (mm units, keys) | `~/.config/blender-mcp/startup.py` |

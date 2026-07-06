# Jim's Studio Runbook

Machine: Ubuntu 24.04 · PipeWire @ 48kHz · REAPER 7 (`reaper`) · AudioBox USB96 · Akai MPK Mini
Everything below assumes REAPER is your hub. Claude can drive REAPER through the `reaper` MCP server — **REAPER must be open** for that to work.

---

## 0. Every-session startup (30 seconds)

1. Plug in the **AudioBox USB96** *before* launching REAPER (it's driverless — appears instantly). Guitar → Input 1, turn the input **Gain** knob until the blue signal LED flickers on loud playing and the red clip LED never lights.
2. Headphones: either into the **USB96 headphone jack** (hear what you record, zero latency via its Mixer knob) or the **motherboard front panel** (system default output).
3. Launch **REAPER**. First time only: Options → Preferences → Audio → Device → confirm the JACK/PipeWire device is active; pick the AudioBox for inputs/outputs.
4. Optional AI copilot: open a terminal, run `claude`, and talk to it — it sees and controls the open REAPER project.

**If audio crackles:** buffer is too tight. `pw-metadata -n settings 0 clock.force-quantum 512` (0 = back to auto). Bigger = safer, more latency.
**If the USB96 vanishes:** replug it, then check `wpctl status`.

---

## 1. If you want to record guitar licks / parts

1. **Track:** Ctrl+T for a new track, name it ("Lead lick").
2. **Input:** click the track's red **arm** button; set input to **Mono → Input 1** (USB96). Click the little speaker icon next to arm = **input monitoring on**.
3. **Tone — pick one:**
   - **Proteus** (amp captures): FX button → add `Proteus` → LOAD MODEL → pick a `.json` from `~/Music/GuitarTones/Proteus/` (6505Plus = metal, DumbleKit = smooth lead, BluesJrAmp = clean/edge, BossMT2/GoatPedal = pedals). Add `Dragonfly Room Reverb` after it.
   - **Neural Amp Modeler**: FX → `Neural Amp Modeler`; load `.nam` captures (get free ones at tone3000.com).
   - **Guitarix** (full rig with cabs/pedals): run it standalone, then in qpwgraph wire USB96 → Guitarix → REAPER track input.
   - Always put **ReaTune** (built-in) first in FX chain when practicing — free tuner.
4. **Record:** set BPM in the transport, enable metronome (Options → Metronome). **Ctrl+R** starts/stops recording.
5. **Loop takes:** drag a time selection, toggle **R**epeat on the transport, record — each pass stacks a *take*. Stop, then **T** cycles takes; slice the best bits together (comping).
6. **Keep it:** Ctrl+S saves the project to `~/Music/Studio/Projects/`.

**Ask Claude:** "add a dual-tracked rhythm guitar setup — two armed tracks panned L/R with a 6505 tone" or "trim silence and normalize my last take".

---

## 2. If you want to remix or replace a piece of a completed song

**Formats in:** REAPER imports WAV, FLAC, MP3, AIFF, OGG. Prefer **WAV or FLAC**; MP3 is fine for sketching.
- **Suno:** download **WAV** (your sub includes it — avoid MP3 for remixing) → drop in `~/Music/Studio/Imports/Suno/`. Suno WAVs are 44.1kHz stereo — that's fine, REAPER/PipeWire resample transparently.
- **Moises:** upload the song, let it split, export **stems as WAV** (not M4A/MP3) → `~/Music/Studio/Imports/Moises-Stems/`. Note the **BPM and key** Moises detects — you'll want them.

**The workflow:**
1. Any *finished* song you want to alter → run it through **Moises first** to get separated stems (vocals / drums / bass / guitar / other). A flat stereo file can't be surgically edited; stems can.
2. In REAPER: File → Project Settings → set **project BPM** to what Moises reported. Then drag all stem WAVs in — one track each, they start at 0 and stay aligned.
3. **Replace a part:** mute or delete the stem section you hate (split items with **S** at the cursor), record your own guitar/keys over it (Section 1), and blend with a matching reverb.
4. **Remix only:** keep all stems and rebalance — LSP Compressor / ReaEQ per track, `Dragonfly Reverb` on a send, LSP Limiter on the master.
5. **Small surgical fixes** on a single audio file (remove a click, fade an ending, trim, normalize): open the WAV in **ocenaudio** instead — edit, save, done, no project needed.

**Formats out (File → Render, Ctrl+Alt+R):**
| Destination | Format |
|---|---|
| Master keeper / further editing | WAV 24-bit, 48kHz |
| Upload to Moises/Suno/collaborators | WAV 24-bit (they accept MP3, but send WAV) |
| Sharing / phone / demo | MP3 320kbps or FLAC |
| Streaming-style loudness | aim ~ -14 LUFS integrated (check with `Loudness Meter` in the render window or LSP meter) |

**Ask Claude:** "import the stems from Imports/Moises-Stems, set the project to 92bpm, mute the guitar stem from bar 17–25, and set up an armed track for me to replay it."

---

## 3. If you want to record a beat

**Option A — finger-drum it on the Akai pads (most fun):**
1. Ctrl+T new track, arm it, input = **MIDI → Akai MPK Mini** (all channels).
2. FX → add **a-fluidsynth** → load soundfont `/usr/share/sounds/sf2/FluidR3_GM.sf2` → set the MIDI **channel to 10** (GM channel 10 = drum kit; kick=C1/36, snare=D1/38, hats=F#1/42 on the pads — the MPK's PROG CHANGE/pad bank gets you there).
3. Set BPM, metronome on, enable loop over 2–4 bars, Ctrl+R and play. Loop-recording **merges** MIDI passes by default, so layer kick first, then snare, then hats.
4. Sloppy timing? Double-click the item → MIDI editor → select all → **Q** → quantize to 1/16 at ~80% strength (keeps groove).

**Option B — program it in Hydrogen (classic drum machine):**
Launch **Hydrogen**, pick a kit (GMRockKit), click steps into the pattern grid, chain patterns into a song → File → Export Song as **WAV 48kHz** → drag into REAPER.

**Option C — let Claude write it:**
With REAPER open: "create a drum track with a 90bpm boom-bap pattern for 8 bars, then add a bass line in E minor." The MCP server has dedicated drum-pattern and chord-progression tools; it writes real MIDI items you can edit afterward.

**Then bass/keys:** new MIDI track → FX → **Surge XT** (synth bass: init patch → filter down) or ZynAddSubFX — play it from the Akai keys.

---

## Cheat sheet

| Thing | Where |
|---|---|
| Projects / renders | `~/Music/Studio/Projects` · `~/Music/Studio/Renders` |
| Suno / Moises imports | `~/Music/Studio/Imports/{Suno, Moises-Stems}` |
| Amp captures (Proteus) | `~/Music/GuitarTones/Proteus/*.json` |
| NAM captures | `~/.lv2/…` plugin; models: tone3000.com → any folder |
| GM drums soundfont | `/usr/share/sounds/sf2/FluidR3_GM.sf2` |
| Patchbay (visual cables) | `qpwgraph` |
| Wave editor (Sound-Forge style) | `ocenaudio` |
| Reinstall log / this file | `~/Music/Studio/` |
| REAPER keys | Ctrl+T track · Ctrl+R record · S split · T next take · Q quantize (MIDI editor) · Ctrl+Alt+R render |

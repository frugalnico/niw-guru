# Installing niw-guru

niw-guru does **not** ship a ready-to-run binary. You build the `niw-guru` command from source
in three short steps: **get the code → install dependencies → build the command.** "Building" here
just renders a bash script and (optionally) links it onto your PATH — there is nothing to compile.

- [Prerequisites](#prerequisites)
- [Quick path (with make)](#quick-path-with-make)
- [Manual build (no make)](#manual-build-no-make)
- [Putting niw-guru on your PATH](#putting-niw-guru-on-your-path)
- [Verify](#verify)
- [Update / rebuild / uninstall](#update--rebuild--uninstall)
- [Troubleshooting](#troubleshooting)

## Prerequisites

| Tool | Why | Install |
|---|---|---|
| **Claude Code** (`claude`) | the engine that runs the pipeline | https://docs.anthropic.com/en/docs/claude-code · `npm i -g @anthropic-ai/claude-code` |
| **git** | clones the immigration skills during setup | system package manager |
| **poppler** (`pdftotext`, `pdfinfo`) | extract text and locate quote pages in PDFs | macOS: `brew install poppler` · Debian/Ubuntu: `sudo apt-get install poppler-utils` |
| **Chrome/Chromium** *or* **wkhtmltopdf** | render HTML sources to PDF (direct PDF links don't need this) | install Chrome, or `brew install --cask wkhtmltopdf` / `sudo apt-get install wkhtmltopdf` |
| **make** (optional) | one-command build/install | preinstalled on macOS (Xcode CLT) and most Linux |

`./setup.sh` installs poppler and the skills for you and checks for a renderer — see below.

## Quick path (with make)

```bash
# 1. Get the code
git clone https://github.com/<your-username>/niw-guru.git
cd niw-guru

# 2. Install dependencies + the immigration skills
./setup.sh                 # (or: make setup)

# 3. Build the command  ->  bin/niw-guru
make build

# 4. (optional) put it on your PATH
sudo make install          # symlinks into /usr/local/bin
#   …or install without sudo into your user bin:
make install PREFIX="$HOME/.local"     # ensure ~/.local/bin is on your PATH
```

Run `make` (or `make help`) any time to see all targets.

Then use it:

```bash
niw-guru -s ~/my_niw_materials          # if installed on PATH
./bin/niw-guru -s ~/my_niw_materials    # or run the built script directly
```

## Manual build (no make)

The build does exactly two things: substitute this project's absolute path into the source
template, and mark the result executable.

```bash
cd niw-guru

# Render src/niw-guru.in -> bin/niw-guru, baking in the project path:
mkdir -p bin
sed "s|@NIW_GURU_HOME@|$(pwd)|g" src/niw-guru.in > bin/niw-guru
chmod +x bin/niw-guru
```

That's it — `bin/niw-guru` is now runnable. (The script also falls back to resolving its own
location if the baked path is ever missing, and you can always override it with the
`NIW_GURU_HOME` environment variable.)

Don't forget the dependencies and skills, which the manual build does **not** do for you:

```bash
./setup.sh        # installs poppler, checks for a renderer, installs the immigration skills
```

## Putting niw-guru on your PATH

Pick whichever you prefer (all equivalent to typing `niw-guru` from anywhere):

```bash
# A) symlink into a system bin (may need sudo)
sudo ln -sf "$(pwd)/bin/niw-guru" /usr/local/bin/niw-guru

# B) symlink into your user bin
mkdir -p "$HOME/.local/bin"
ln -sf "$(pwd)/bin/niw-guru" "$HOME/.local/bin/niw-guru"      # ensure ~/.local/bin is on PATH

# C) add the repo's bin/ to PATH in your shell profile
echo "export PATH=\"$(pwd)/bin:\$PATH\"" >> ~/.zshrc && source ~/.zshrc
```

Or skip PATH entirely and just run `./bin/niw-guru` from the project folder.

## Verify

```bash
./bin/niw-guru -h                                   # prints usage
./bin/niw-guru -s ./examples/sample-run/input --dry-run   # resolves paths, makes no Claude call
make test                                           # offline test suite (or: bash tests/run-tests.sh)
```

A full live run (web research + downloads) on the bundled synthetic example:

```bash
./bin/niw-guru -s ./examples/sample-run/input -o /tmp/niw-smoke --yes
```

## Update / rebuild / uninstall

```bash
git pull                 # get updates
./setup.sh               # refresh skills/deps if needed
make build               # rebuild bin/niw-guru   (or re-run the manual sed step)

make uninstall           # remove the PATH symlink (respects PREFIX)
make clean               # remove the built bin/niw-guru
```

`bin/niw-guru` is a build artifact and is git-ignored — rebuild it after pulling changes.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `niw-guru: command not found` | You haven't built/installed it. Run `make build` (and `make install`), or call `./bin/niw-guru`. |
| `the 'claude' CLI was not found` | Install Claude Code and ensure `claude` is on PATH. |
| `missing tools: pdftotext` | Run `./setup.sh`, or install `poppler` / `poppler-utils`. |
| HTML sources saved as `.txt` instead of PDF | No renderer found — install Chrome/Chromium or `wkhtmltopdf`, then re-run. |
| Intake/research stage seems to skip | `setup.sh` couldn't clone the immigration skills (offline?). Re-run it online. |
| Command runs but uses the wrong folder | The baked `NIW_GURU_HOME` is stale (you moved the repo). Re-run `make build`, or set `NIW_GURU_HOME=/path/to/niw-guru`. |
| `make: command not found` | Use the [manual build](#manual-build-no-make). |

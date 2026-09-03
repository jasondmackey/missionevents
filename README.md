# missionevents

_Formerly `me_dedup`. Maintained by jama2218._

Profile-driven command-line runner for LASP's `mission_events` tool, with automatic
orbit deduplication: when an orbit has both an `AscendingNode` and a `StationContact`
event, only the `StationContact` is shown.

Works across missions (IXPE, MMS, IMAP, TSIS, TSIS-2, CPRS, ...) via per-mission
profiles. An interactive builder walks you through creating each profile and
explains every setting before you save it.

## How it works

`mission_events` only exists on each mission's operations host. `missionevents` SSHes
there, sources the mission environment (the non-interactive equivalent of typing
the mission name after login), runs `mission_events` with your arguments, and
post-processes the output locally.

Nothing mission-specific is installed on your machine.

**Requirements:** `zsh`, `awk`, `ssh`, and an account on the mission's host.
Password auth works — ssh keys just skip the prompt.

## Install

```sh
git clone https://github.com/jasondmackey/missionevents.git
cd missionevents
sh install_missionevents.sh
```

The installer copies the executable to `~/.local/bin` (override with
`MISSIONEVENTS_BINDIR=/some/dir`) and adds it to `PATH` in your `~/.zshrc` if needed.
Open a new terminal afterwards. Pass `--no-path` to install without touching
`~/.zshrc` (e.g. for custom install locations you manage yourself).

Without git:

```sh
curl -O https://raw.githubusercontent.com/jasondmackey/missionevents/main/missionevents
curl -O https://raw.githubusercontent.com/jasondmackey/missionevents/main/install_missionevents.sh
sh install_missionevents.sh
```

## Quick start

```zsh
missionevents --build     # guided profile creation: explains each setting, then tests it
missionevents             # interactive menu of saved profiles (no names to memorize)
missionevents --list      # list saved profiles
missionevents --help      # quick reference card
```

Once a profile exists:

```zsh
missionevents ixpe                                                 # profile defaults
missionevents ixpe -n 0:7 --type-names AscendingNode StationContact
missionevents -n -2:3 --type-names AscendingNode StationContact    # default profile
missionevents -n 0:1 --contacts                                    # contact schedule
```

All arguments after the profile name pass straight through to `mission_events`.

## Profiles

Profiles are plain KEY=VALUE files in `~/.missionevents/profiles/<name>` — hand-editable:

- `HOST` — remote machine where `mission_events` runs (hostname or ssh config alias)
- `REMOTE_USER` — only if your remote username differs from your local one
- `SOURCE_CMD` — mission environment setup, e.g. `source /lasp/<mission>/setup.bourne`
- `DEDUP` — `y` suppresses AscendingNode when the orbit has a StationContact; `n` passes everything through
- `TYPE_NAMES` — default `--type-names` applied when you don't pass any
- `DEFAULT_N` — default time range (e.g. `0:1`) applied when you don't pass `-n`
- `SSH_OPTS` — extra ssh options for unusual network paths
- `NOTES` — one-line description shown by `missionevents --list`

A working `ixpe` profile is seeded automatically on first run.

## Uninstall

```sh
rm ~/.local/bin/missionevents
```

(Profiles in `~/.missionevents/` are kept; delete that directory too if unwanted.)

# Contributing to Nebula

Thanks for wanting to help. Nebula is a personal desktop, so the rules are short.

For anything bigger than a small fix, open an issue or ask first, so you don't spend time on
something that doesn't fit the design.

## Reporting bugs and requesting features

Use [GitHub Issues](https://github.com/LilaccFlowerr/Nebula/issues/new). For a bug, include:

- what you did, what you expected and what happened instead
- your distro, Hyprland and Quickshell versions, and how you installed Nebula
- the log: `qs log -c nebula`
- a screenshot or short recording for anything visual

## AI policy

You may use AI tools, but you are the author of what you submit.

- **You must understand it.** If you can't explain what a change does and why, don't submit it.
  Reviewers will ask, and "the AI wrote it" is not an answer.
- **Review it yourself first.** Run it, read the diff, remove what doesn't belong. Unreviewed AI
  output wastes the maintainer's time and will be closed.
- **Write your own words.** Commit messages, PR descriptions, issue text and review comments
  must be written by you, not generated. This includes `Co-Authored-By` trailers from AI tools.
- **Say so in the PR** if a meaningful part of the code came from an AI tool, so reviewers know
  to look closely.

If a PR looks like it was submitted without reading it, it will be closed without a review.

## Setting up

Nebula is made on Arch. Follow the install steps in the [README](README.md) (m3shapes has to be
built), then link the repo into `~/.config` so the shell loads straight from your checkout.
Changes to the shell reload by themselves. Singletons (`Theme`, services) and new files often
don't, so restart the shell when something looks stuck:

```bash
qs kill -c nebula; hyprctl dispatch 'hl.dsp.exec_cmd("qs -c nebula -d")'
```

Test a risky change in a throwaway config first: copy `quickshell/nebula` somewhere else and
run it with `qs -p <dir>`.

## Making a change

1. Fork the repo and branch off `main`. Name the branch after what it does: `feat/lockscreen`,
   `fix/dock-preview`, `chore/readme`.
2. Keep a PR to one thing. Two unrelated fixes are two PRs.
3. Run it for real before you push, and check `qs log -c nebula` for errors.
4. Follow the style of the code around your change: naming, structure, spacing.
5. Open the PR against `main`. Say what changed and why, and link the issue if there is one.
   For anything visual, add a screenshot or recording.
6. Be ready for feedback. Review is about the change, not about you.

### Commit messages

Short, in the imperative, with a prefix like the existing history:

```
feat: add missed notifications galaxy
fix: dock preview closes when the pointer leaves
chore: update the readme
docs: explain the hypr overrides
```

## Project layout

```
Nebula/
├── hypr/                  Hyprland config (Lua), hypridle, hyprlock
│   ├── hyprland.lua       entry point, requires the modules
│   ├── variables.lua      shared variables and every keybind
│   └── hyprland/          env, general, input, animations, decoration, execs, rules, keybinds
├── quickshell/nebula/     the shell
│   ├── shell.qml          entry point, loads every window
│   ├── theme/             Theme (tokens) and Colors (live from matugen)
│   ├── services/          data and logic, no UI
│   ├── components/        small reusable pieces
│   ├── widgets/           everything you see
│   ├── shaders/           GLSL shaders and their compiled .qsb
│   └── assets/            default wallpaper, equalizer config, sounds
├── matugen/               color templates
├── ghostty/               terminal config
├── fastfetch/             fetch config
└── install.sh             the guided installer
```

### What goes where

**`services/`** holds behaviour: MPRIS, notifications, Hyprland state, the equalizer, the lock.
A service never draws anything, so the logic stays reusable. Each is a singleton.

**`widgets/`** holds presentation: the bar, launcher, settings, lockscreen and so on, one folder
per part. Widgets read from services and render. They don't hold logic.

**`components/`** holds pieces used in more than one place. If you copy a piece of QML into a
second widget, move it here.

**`theme/`** is the single source of style. Take colors, radii, spacing, fonts and animation
timings from `Theme` and `Colors`. Never write a hex color or a magic number in a widget; add a
token instead.

## Code style

- Everything in the repo is English: UI strings, logs, identifiers and comments.
- No explanatory comments in QML. Name things so they don't need one.
- Don't stack two animations on one value. Let a follower follow directly.
- Don't use inline components in files that need to hot reload. Make them their own file.
- Call functions with `()`. Property names starting with `on` and a capital are signal handlers.
- Keep a bar or widget fix small. Plumbing that can break the whole shell (window sizes, masks,
  services) deserves extra care and a test in a throwaway config.

## License

Nebula is licensed under the AGPL-3.0. By contributing you agree that your contribution is licensed under the
same terms (see [LICENSE](LICENSE)).

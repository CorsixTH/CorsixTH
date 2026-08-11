# CorsixTH Contribution

A personal fork of CorsixTH, the open source reimplementation of the 1997
Bullfrog game Theme Hospital, used to learn open source contribution from a VPS.
The goal is a first real pull request to the upstream project.

The game logic is mostly Lua on a C++ engine, which makes it a good place to
learn the whole loop: read code, reproduce a bug, write a fix, run the tests,
and survive maintainer review.

## The project record

- `devlog/journal.md` — personal journal, one entry per day, newest on top
- `devlog/summary.md` — master plan: context, roadmap, status, tooling
- `devlog/project-conception-log.md` — every decision, chosen or rejected, and why
- `devlog/plan.md` — tick-box roadmap for the first contribution
- `devlog/achievements.md` — running record of GitHub achievements earned by this account
- `devlog/scripts/` — the Rust time tracker and the achievements checker

The journal and the decision log live inside the fork so the code and the story
of writing it stay together.

## Status

| Step | Status |
|---|---|
| Dev environment on the VPS (SDL3 in `/opt/SDL3`) | done |
| Dev build boots headless with the demo data | done |
| Lua tests, lint and syntax checks green | done |
| First issue picked: broken Lua docs links on GitHub Pages (#1793) | done |
| Root-cause the issue and write the fix | next |
| Pull request to upstream | pending |

## Machine split

- **The VPS** is the workspace. It holds the fork, the build, the tests and the
  legal Theme Hospital demo data.
- **The computer** only SSHes into the VPS. It runs no CorsixTH install, no
  demo, no clone.

## Philosophy

- **VPS-only** — one environment for reproducing bugs, matching CI as close as
  the distro allows
- **Legal demo data only** — the free demo from the CorsixTH site, never
  pirated game files
- **PR hygiene** — code branches cut from `upstream/master`, the devlog never
  leaks into a pull request
- **Publish everything** — the docs are public, the private logs stay local

## License

The code is [MIT](LICENSE.txt), same as upstream. This is a personal fork of
[CorsixTH/CorsixTH](https://github.com/CorsixTH/CorsixTH), so the upstream game
README follows below.

---
<picture>![image](https://github.com/CorsixTH/CorsixTH/assets/20030128/923883d1-cd2b-48a9-8506-6ee03e2745dc)</picture>

### Latest Release <a href="https://github.com/CorsixTh/CorsixTH/releases/latest"><img src="https://img.shields.io/github/v/release/CorsixTH/CorsixTH?style=for-the-badge&color=green" align="top"></a>
[![Linux and Tests](https://github.com/CorsixTH/CorsixTH/actions/workflows/Linux.yml/badge.svg?branch=master)](https://github.com/CorsixTH/CorsixTH/actions/workflows/Linux.yml) [![Windows](https://github.com/CorsixTH/CorsixTH/actions/workflows/Windows.yml/badge.svg?branch=master&event=push)](https://github.com/CorsixTH/CorsixTH/actions/workflows/Windows.yml) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/CorsixTH/CorsixTH?branch=master&svg=true&passingText=Windows%20-%20OK&failingText=Windows%20-%20Failing)](https://ci.appveyor.com/project/TheCycoONE/corsixth)
##### [Matrix Space](https://matrix.to/#/#CorsixTH:matrix.org) | [Matrix Chat](https://matrix.to/#/#corsixth-general:matrix.org) | [Discord](https://discord.gg/Mxeztvh) | [Report Issue](https://github.com/CorsixTH/CorsixTH/issues/new) | [Reddit](https://www.reddit.com/r/corsixth) | [Twitter/X](https://twitter.com/CorsixTH) | [Facebook](https://facebook.com/CorsixTH)
----

A reimplementation of the 1997 Bullfrog business sim Theme Hospital. As well as faithfully recreating the original, CorsixTH adds support for modern operating systems (Windows, macOS, Linux and BSD), high resolutions and much more.

<picture>![image](https://github.com/CorsixTH/CorsixTH/assets/20030128/71a42d5f-d486-4309-ba85-77e114880bcb)</picture>


## Getting Started ##

You will need the following:

- Grab the latest installer for your system:
   - Windows and macOS builds, and an AppImage for Linux can be downloaded directly from [releases](https://github.com/CorsixTH/CorsixTH/releases).
   - Linux and BSD repositories use either corsixth or corsix-th names [packaged versions](https://repology.org/metapackage/corsixth).
   - A Flatpak for Linux users is available on [Flathub](https://flathub.org/apps/details/com.corsixth.corsixth).
   - A Snap for Linux users is available on [Snapcraft](https://snapcraft.io/corsixth) [(support page)](https://github.com/snapcrafters/corsixth).
   - An unofficial Anylinux AppImage is available from [Pkgforge](https://github.com/pkgforge-dev/CorsixTH-AppImage-Enhanced).
- We use graphics, sound and other data from the original game so one of the following is required:
   - Original game CD from eBay etc. or your dusty bookshelf :smile:
   - A download from [GOG.com](https://www.gog.com/game/theme_hospital) or [EA](https://www.ea.com/games/theme/theme-hospital)

 Head over to our [getting started](https://github.com/CorsixTH/CorsixTH/wiki/Getting-Started) page for more detail.

### What's Working? ###
Most features of the game are available -- and we're at a state where you can complete the full campaign without issue.
##### Original Features #####
- Single player campaign
- All diseases, objects, rooms are available
- All events (emergencies, earthquakes, epidemics, VIP visits)
- Management windows (managing staff, patients, policies etc.)
- Music/Jukebox
- Gameplay videos
- Cheats (naughty!)
  
##### New Features #####
- Custom levels and campaigns
- Full HD and 4K support
- Zooming
- UI scaling
- Subtitles
- More than 20 different languages
- Make your own maps and levels with built-in map editor
- Unlimited save files
- Play your own music!
- Option to build rooms while paused
- Option to remove destroyed rooms for a fee
- Improved game logic
- Full control over all hotkeys
- Machine menu
- Adviser messages history 

### What's missing/needs improvement? ###
There are some areas of the game still missing, and while we work to get them integrated any additional help from the community is always appreciated!
- Multiplayer/LAN
- AI Hospitals (and the components associated with it)
- Rats (but rat holes are present) and the bonus rat level
- Vomit waves
- Win level video/letter
- The original graphics do not have a complete set for Pregnancy, Alien DNA, and female Fractured Bones patients -- these may cause anomalies if you enable regular spawning in settings
- Some objects in the game may glitch with walls

## Developers
### Coders and non-coders we want you!

We are always looking for help with improving CorsixTH. The code base is made up of Lua and C++. Most of the game logic is written in Lua, we love Lua and its approachable and easy to pick up nature, so hit fork and get started! But don't worry if you don't code as we can always use your help in other areas and if you have ideas for the project please contact us or open a new issue! We could also use help updating the documentation in the wiki and keeping the issue list up to date.\
You can also [click here](https://github.com/CorsixTH/CorsixTH/issues?q=is%3Aissue+is%3Aopen+label%3A%22Good+First+Issue%22) to find issues that would suit a first-time contributor to take on!

###### Features & Bugfixes ######
We still have features to add and bugs to fix, check out the issue tracker [here](https://github.com/CorsixTH/CorsixTH/issues). Want to talk about adding a feature? post on our Google group or [contact us](#Contact).

###### Translation ######
CorsixTH has translations for more than 20 different languages, some of which need updating. Read our [wiki](https://github.com/CorsixTH/CorsixTH/wiki/Localization) for more information.

## More

Our [wiki](https://github.com/CorsixTH/CorsixTH/wiki) is a good place to start, if you can't find what you are looking for feel free to contact us using one of the methods below.

## Contact

- Follow us on [Reddit](https://www.reddit.com/r/corsixth), Twitter/X ([**@CorsixTH**](https://twitter.com/CorsixTH)), and on [Facebook](https://facebook.com/CorsixTH)
- <details>
  <summary>Hit us up on Matrix! (Discord bridged) [click to expand]</summary>
  
  - **CorsixTH Space** (includes all rooms below, if your client supports it) [#CorsixTH:matrix.org](https://matrix.to/#/#CorsixTH:matrix.org)
  - **General Chat** [#corsixth-general:matrix.org](https://matrix.to/#/#corsixth-general:matrix.org)
  - **Announcements** [#corsixth-announcements:matrix.org](https://matrix.to/#/#corsixth-announcements:matrix.org)
  - **Technical Discussion** (DevOps) [#corsixth-technical:matrix.org](https://matrix.to/#/#corsixth-technical:matrix.org)
  - **Help!** [#corsixth-help:matrix.org](https://matrix.to/#/#corsixth-help:matrix.org)
  - **Community Content** [#corsixth-usercontent:matrix.org](https://matrix.to/#/#corsixth-usercontent:matrix.org)
  
</details>

- Join the server on [Discord](https://discord.gg/Mxeztvh)
- Subscribe to our [Google Developer group](https://groups.google.com/g/corsix-th-dev)

# gldnrmz-rat

Bug a stranger enough and he calls the cops on you. Pay or bring the right item, argue with him, and he snitches - then runs. Get it wrong and you may have a dead body to search.

Works on Qbox, QBCore and ESX with any target, inventory, notify, progress bar and dispatch supported by [community_bridge](https://github.com/TheOrderFivem/community_bridge).

## Requirements

- [community_bridge](https://github.com/TheOrderFivem/community_bridge) **0.13.6 or newer** (Qbox, QBCore or ESX)
- [bl_dialog](https://github.com/Byte-Labs-Studio/bl_dialog)

## Installation

1. Start `community_bridge` and `bl_dialog` before this resource, then add `ensure gldnrmz-rat` to `server.cfg`.
2. Add `Config.NeedItem` (`phone` by default) and every item in `Config.GiveItems` / `Config.RewardItems` to your inventory's item list. On ESX, use your money item instead of `cash`.
3. Set the stranger's spawn points (`Config.StartCoordsList`) and models (`Config.StartModels`) in `config.lua`.

## Configuration

Everything is in `config.lua`.

| Option | What it does |
| --- | --- |
| `Config.MinimumMethJobPolice` / `Config.PoliceJobs` | On-duty police needed, and which jobs count as police |
| `Config.AlertChance` | Chance (%) the police get an alert |
| `Config.Dispatch.Function` | Which dispatch the alert uses. community_bridge by default; a tk_dispatch version is included as a commented example |
| `Config.NeedCash` / `Config.RunCost` | Charge cash to start |
| `Config.NeedItem` / `Config.RemoveItem` | Item needed to talk to him, and whether it's taken |
| `Config.GiveItems` / `Config.RewardItems` | What you get |
| `Config.SearchBody` | Allow searching his body if he dies |
| `Config.ProgressArgue` / `Config.ProgressLoot` | Progress bar times (ms) |
| `Config.RatDialog` | bl_dialog conversation |

The "Talk to Stranger" option is always shown; without `Config.NeedItem` the player is told what's missing.

## Changes in 1.1.0

- Runs on Qbox, QBCore and ESX through community_bridge (no qb-core requirement).
- The police alert is a config function, defaulting to community_bridge instead of tk_dispatch.
- The talk option is always shown and says when you're missing the item.
- The server counts police and checks a search token before loot is given.

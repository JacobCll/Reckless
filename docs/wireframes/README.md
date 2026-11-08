# Reckless: Screen Wireframes

Grayscale, low-fidelity wireframes of each main screen. They're drawn at the game's 1024×768 viewport, and element positions follow the Godot scenes.

- `svg/`: source wireframes (scalable)
- `png/`: rendered images (1104×912, including caption)

## Screens

| # | Screen | Scene |
|---|--------|-------|
| 01 | Intro Cutscene | `cutscene/intro_cutscene.tscn` |
| 02 | Main Menu | `scenes/main_menu.tscn` |
| 03 | Settings (overlay) | `settings/settings_menu.tscn` |
| 04 | Notification Inbox | `notification/notificationscreen.tscn` |
| 05 | View Message | `notification/viewmessage.tscn` |
| 06 | Level Select | `scenes/level_menu/level_menu.tscn` |
| 07 | Power-up Select (modal) | `scenes/level_menu/powerup_modal.tscn` |
| 08 | Shop | `shop/shop.tscn` |
| 09 | Loading Screen | `loading_screen/loading_screen.tscn` |
| 10 | Gameplay (HUD) | `scenes/levels/base_level/base_level.tscn` |
| 11 | Pause (overlay) | `base_level.tscn` → `PauseScreen` |
| 12 | Game Over (overlay) | `base_level.tscn` → `GameoverScreen` |
| 13 | Level Complete (overlay) | `base_level.tscn` → `WinLevelScreen` |
| 14 | Tutorial | `scenes/levels/tutorial_level/tutorial_level.tscn` |

## Screen flow

```
Intro Cutscene → Main Menu ─┬─ Play ──→ Level Select → Power-up Select → Loading → Gameplay
                            ├─ Shop                                                 ├─ Pause → Settings / Main Menu
                            ├─ Settings                                             ├─ Game Over → Retry / Main Menu
                            └─ Inbox → View Message                                 └─ Level Complete → Next / Again / Menu
```

## Legend

- Box with an X: image or artwork placeholder
- Dark filled button: primary action
- In gameplay, entity colors are shown by shape: **filled circle** = blue (slash), **square** = red (smash), **dashed circle** = green (avoid)

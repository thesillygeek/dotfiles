My terminal setup — Ghostty + Fish + Starship + Volta

## stack

| Tool | Role |
|---|---|
| Ghostty | Terminal emulator |
| Fish | Shell |
| Starship | Prompt renderer |
| Volta | Node version manager |

## theme system

Automatically rotates through all 463 built-in Ghostty themes,
split by luminance into light and dark lists.

- 7am–7pm → shuffled light themes (78 total)
- 7pm–7am → shuffled dark themes (385 total)
- Type `theme-next` anywhere to skip to the next theme
- Full list cycles then reshuffles automatically
- State persists across sessions in `~/.config/ghostty/theme_state`

## files
```
fish/config.fish              — Fish shell config + theme rotation logic
ghostty/config                — Ghostty terminal config
ghostty_theme_builder.fish    — One-time script to auto-discover and
                                categorise all themes from your Ghostty
                                installation by background luminance
```

## setup on a new machine

1. Install Ghostty, Fish, Starship, Volta
2. Set Fish as default shell: `chsh -s /usr/local/bin/fish`
3. Copy files to their locations:
```fish
cp fish/config.fish ~/.config/fish/config.fish
cp ghostty/config   ~/.config/ghostty/config
```

4. Run the theme builder to regenerate theme lists from your local install:
```fish
fish ghostty_theme_builder.fish
```

5. Open a new terminal window — themes apply automatically


# dotfiles

My terminal setup — Ghostty + Fish + Starship + Volta

## what's in here
- `fish/config.fish` — Fish shell config with auto theme rotation
- `ghostty/config` — Ghostty terminal config

## theme system
- dark themes, light themes, shuffled automatically
- 7am–7pm = light themes, 7pm–7am = dark themes
- `theme-next` command to manually advance

spent a weekend going from "why does my terminal have purple icons" to building a fully automated terminal setup from scratch. here's everything i did 🧵

🖥️ the stack
ghostty (terminal) + fish shell + starship (prompt) + volta (node version manager)

four separate programs, all wired together via one config file that runs every time i open a terminal

🎨 the theme system i built
— 10 dark themes, 5 light themes, all shuffled
— automatically switches between light/dark lists based on time of day (7am–7pm light, 7pm–7am dark)
— type theme-next anywhere to skip to the next theme
— state persists across sessions, reshuffles when the full list cycles through

🦀 what i learned
— the difference between a terminal emulator, a shell, and a prompt renderer
— what PATH actually is and why order matters
— why Rust keeps showing up everywhere (spoiler: it solved a 50-year-old memory safety problem)
— how Fish's config.fish boots your entire dev environment before you type a single character

full config on github 👇

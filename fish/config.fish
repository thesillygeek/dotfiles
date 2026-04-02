function rotate_ghostty_theme
    # Edit this list to your preferred themes
    set themes \
        "nord" \
        "Gruvbox Dark" \
        "ayu" \
        "rose-pine" \
        "One Dark" \
        "nightfox" \
        "Catppuccin Mocha" \
        "Github Dark" \
        "Monokai Pro" \
        "rose-pine-moon"

    set day (date +%j)              # day of year: 1–365
    set count (count $themes)       # how many themes you have
    set index (math "$day % $count + 1")   # picks a slot, cycles forever
    set selected $themes[$index]

    set config ~/.config/ghostty/config

    if grep -q "^theme" $config
        # theme line exists — replace it
        sed -i '' "s|^theme = .*|theme = $selected|" $config
    else
        # theme line doesn't exist — add it
        echo "theme = $selected" >> $config
    end
end

rotate_ghostty_theme   # call it every startup

starship init fish | source
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
set -gx PATH "$HOME/.local/bin" $PATH

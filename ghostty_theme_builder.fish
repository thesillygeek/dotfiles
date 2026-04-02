set theme_dir "/Applications/Ghostty.app/Contents/Resources/ghostty/themes"
set light_themes
set dark_themes

for theme_file in $theme_dir/*
    set name (basename $theme_file)
    if not test -f $theme_file
        continue
    end
    set bg_line (grep -i "^background" $theme_file 2>/dev/null | head -1)
    if test -z "$bg_line"
        continue
    end
    set hex (echo $bg_line | sed 's/.*#//' | sed 's/.*= *//' | string trim | string lower)
    if not string match -rq '^[0-9a-f]{6}$' $hex
        continue
    end
    set r (math "0x"(string sub -s 1 -l 2 $hex))
    set g (math "0x"(string sub -s 3 -l 2 $hex))
    set b (math "0x"(string sub -s 5 -l 2 $hex))
    set luminance (math "$r * 299 + $g * 587 + $b * 114")
    if test $luminance -gt 140000
        set light_themes $light_themes $name
    else
        set dark_themes $dark_themes $name
    end
end

echo "Light: "(count $light_themes)" | Dark: "(count $dark_themes)

set tmp (mktemp /tmp/config_fish_XXXXXX)

echo '# GHOSTTY THEME ROTATOR' >> $tmp
echo 'set -g __GHOSTTY_CONFIG ~/.config/ghostty/config' >> $tmp
echo 'set -g __THEME_STATE    ~/.config/ghostty/theme_state' >> $tmp
echo '' >> $tmp
echo 'set -g __LIGHT_THEMES' >> $tmp
for t in $light_themes
    echo "set -a __LIGHT_THEMES \"$t\"" >> $tmp
end
echo '' >> $tmp
echo 'set -g __DARK_THEMES' >> $tmp
for t in $dark_themes
    echo "set -a __DARK_THEMES \"$t\"" >> $tmp
end
echo '' >> $tmp
echo 'function __is_daytime' >> $tmp
echo '    set hour (math (date +%H))' >> $tmp
echo '    test $hour -ge 7; and test $hour -lt 19' >> $tmp
echo 'end' >> $tmp
echo '' >> $tmp
echo 'function __shuffle_indices' >> $tmp
echo '    set total $argv[1]' >> $tmp
echo '    set indices' >> $tmp
echo '    for i in (seq 1 $total)' >> $tmp
echo '        set indices $indices $i' >> $tmp
echo '    end' >> $tmp
echo '    set result' >> $tmp
echo '    while test (count $indices) -gt 0' >> $tmp
echo '        set pos (math "($RANDOM % (count $indices)) + 1")' >> $tmp
echo '        set result $result $indices[$pos]' >> $tmp
echo '        set -e indices[$pos]' >> $tmp
echo '    end' >> $tmp
echo '    string join " " $result' >> $tmp
echo 'end' >> $tmp
echo '' >> $tmp
echo 'function __read_state' >> $tmp
echo '    set key $argv[1]' >> $tmp
echo '    if test -f $__THEME_STATE' >> $tmp
echo '        grep "^$key=" $__THEME_STATE | sed '"'"'s/^[^=]*=//'"'"'' >> $tmp
echo '    end' >> $tmp
echo 'end' >> $tmp
echo '' >> $tmp
echo 'function __write_state' >> $tmp
echo '    set key $argv[1]' >> $tmp
echo '    set value $argv[2]' >> $tmp
echo '    touch $__THEME_STATE' >> $tmp
echo '    if grep -q "^$key=" $__THEME_STATE' >> $tmp
echo '        sed -i '"'"''"'"' "s|^$key=.*|$key=$value|" $__THEME_STATE' >> $tmp
echo '    else' >> $tmp
echo '        echo "$key=$value" >> $__THEME_STATE' >> $tmp
echo '    end' >> $tmp
echo 'end' >> $tmp
echo '' >> $tmp
echo 'function __apply_theme' >> $tmp
echo '    set theme $argv[1]' >> $tmp
echo '    touch $__GHOSTTY_CONFIG' >> $tmp
echo '    if grep -q "^theme" $__GHOSTTY_CONFIG 2>/dev/null' >> $tmp
echo '        sed -i '"'"''"'"' "s|^theme = .*|theme = $theme|" $__GHOSTTY_CONFIG' >> $tmp
echo '    else' >> $tmp
echo '        echo "theme = $theme" >> $__GHOSTTY_CONFIG' >> $tmp
echo '    end' >> $tmp
echo '    echo "🎨  $theme — reload with Cmd+Shift+,"' >> $tmp
echo 'end' >> $tmp
echo '' >> $tmp
echo 'function __current_theme' >> $tmp
echo '    if __is_daytime' >> $tmp
echo '        set pos   (__read_state light_pos)' >> $tmp
echo '        set order (string split " " (__read_state light_order))' >> $tmp
echo '        echo $__LIGHT_THEMES[$order[$pos]]' >> $tmp
echo '    else' >> $tmp
echo '        set pos   (__read_state dark_pos)' >> $tmp
echo '        set order (string split " " (__read_state dark_order))' >> $tmp
echo '        echo $__DARK_THEMES[$order[$pos]]' >> $tmp
echo '    end' >> $tmp
echo 'end' >> $tmp
echo '' >> $tmp
echo 'function __init_state' >> $tmp
echo '    if test -z "(__read_state light_order)"' >> $tmp
echo '        __write_state light_order (__shuffle_indices (count $__LIGHT_THEMES))' >> $tmp
echo '        __write_state light_pos 1' >> $tmp
echo '    end' >> $tmp
echo '    if test -z "(__read_state dark_order)"' >> $tmp
echo '        __write_state dark_order (__shuffle_indices (count $__DARK_THEMES))' >> $tmp
echo '        __write_state dark_pos 1' >> $tmp
echo '    end' >> $tmp
echo 'end' >> $tmp
echo '' >> $tmp
echo 'function theme-next' >> $tmp
echo '    __init_state' >> $tmp
echo '    if __is_daytime' >> $tmp
echo '        set pos   (__read_state light_pos)' >> $tmp
echo '        set order (string split " " (__read_state light_order))' >> $tmp
echo '        set total (count $order)' >> $tmp
echo '        set next  (math "$pos % $total + 1")' >> $tmp
echo '        if test $next -eq 1' >> $tmp
echo '            __write_state light_order (__shuffle_indices (count $__LIGHT_THEMES))' >> $tmp
echo '        end' >> $tmp
echo '        __write_state light_pos $next' >> $tmp
echo '    else' >> $tmp
echo '        set pos   (__read_state dark_pos)' >> $tmp
echo '        set order (string split " " (__read_state dark_order))' >> $tmp
echo '        set total (count $order)' >> $tmp
echo '        set next  (math "$pos % $total + 1")' >> $tmp
echo '        if test $next -eq 1' >> $tmp
echo '            __write_state dark_order (__shuffle_indices (count $__DARK_THEMES))' >> $tmp
echo '        end' >> $tmp
echo '        __write_state dark_pos $next' >> $tmp
echo '    end' >> $tmp
echo '    __apply_theme (__current_theme)' >> $tmp
echo 'end' >> $tmp
echo '' >> $tmp
echo '# EXISTING CONFIG' >> $tmp
echo 'starship init fish | source' >> $tmp
echo 'set -gx VOLTA_HOME "$HOME/.volta"' >> $tmp
echo 'set -gx PATH "$VOLTA_HOME/bin" $PATH' >> $tmp
echo 'set -gx PATH "$HOME/.local/bin" $PATH' >> $tmp
echo '' >> $tmp
echo '__init_state' >> $tmp
echo '__apply_theme (__current_theme)' >> $tmp

cp ~/.config/fish/config.fish ~/.config/fish/config.fish.bak
cp $tmp ~/.config/fish/config.fish
rm $tmp
echo "✅ Done — Light: "(count $light_themes)" | Dark: "(count $dark_themes)

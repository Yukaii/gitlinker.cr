define-command -hidden gitlinker-perform -params 1..1 -docstring "Gitlinker helper" %{
    evaluate-commands %sh{
        action_raw="%arg{1}"
        action=$(printf '%s' "$action_raw" | tr '[:upper:]' '[:lower:]' | tr -d '\r\n')
        selection_desc=$kak_selection_desc
        IFS=',' read -r start_pos end_pos <<< "$selection_desc"
        IFS='.' read -r start_line start_col <<< "$start_pos"
        IFS='.' read -r end_line end_col <<< "$end_pos"

        if [ "$start_line" -gt "$end_line" ]; then
            temp=$start_line
            start_line=$end_line
            end_line=$temp
        fi

        permalink=$(gitlinker run -f "$kak_buffile" -s "$start_line" -e "$end_line")

        if [[ $permalink == http* ]]; then
            case "$action" in
            copy)
                if command -v pbcopy >/dev/null 2>&1; then
                    printf '%s' "$permalink" | pbcopy
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                elif command -v xsel >/dev/null 2>&1; then
                    printf '%s' "$permalink" | xsel --input --clipboard
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                elif command -v xclip >/dev/null 2>&1; then
                    printf '%s' "$permalink" | xclip -in -selection clipboard >&- 2>&-
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                elif command -v wl-copy >/dev/null 2>&1; then
                    printf '%s' "$permalink" | wl-copy > /dev/null 2>&1 &
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                elif command -v clip.exe >/dev/null 2>&1; then
                    printf '%s' "$permalink" | clip.exe
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                else
                    printf 'echo -markup '\''{Information}GitHub permalink: %s'\''\n' "$permalink"
                fi
                ;;
            open)
                opened=0
                if command -v open >/dev/null 2>&1; then
                    open "$permalink" >/dev/null 2>&1 &
                    opened=1
                elif command -v xdg-open >/dev/null 2>&1; then
                    xdg-open "$permalink" >/dev/null 2>&1 &
                    opened=1
                elif command -v wslview >/dev/null 2>&1; then
                    wslview "$permalink" >/dev/null 2>&1 &
                    opened=1
                elif command -v powershell.exe >/dev/null 2>&1; then
                    powershell.exe Start-Process "$permalink" >/dev/null 2>&1 &
                    opened=1
                elif command -v cmd.exe >/dev/null 2>&1; then
                    cmd.exe /C start "" "$permalink" >/dev/null 2>&1 &
                    opened=1
                fi

                if [ "$opened" -eq 1 ]; then
                    echo "echo -markup '{Information}GitHub permalink opened in browser'"
                elif command -v pbcopy >/dev/null 2>&1; then
                    printf '%s' "$permalink" | pbcopy
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                elif command -v xsel >/dev/null 2>&1; then
                    printf '%s' "$permalink" | xsel --input --clipboard
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                elif command -v xclip >/dev/null 2>&1; then
                    printf '%s' "$permalink" | xclip -in -selection clipboard >&- 2>&-
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                elif command -v wl-copy >/dev/null 2>&1; then
                    printf '%s' "$permalink" | wl-copy > /dev/null 2>&1 &
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                elif command -v clip.exe >/dev/null 2>&1; then
                    printf '%s' "$permalink" | clip.exe
                    echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
                else
                    printf 'echo -markup '\''{Error}Unable to open permalink: %s'\''\n' "$permalink"
                fi
                ;;
            *)
                echo "echo -markup '{Error}Unknown gitlinker action'"
                ;;
            esac
        else
            echo "echo -markup '{Error}Invalid file'"
        fi
    }
}

define-command gitlinker -docstring "Gitlinker" %{ gitlinker-perform copy }
define-command gitlinker-open -docstring "Gitlinker open" %{ gitlinker-perform open }

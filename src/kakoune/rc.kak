define-command gitlinker -docstring "Gitlinker" %{
    evaluate-commands %sh{
        selection_desc=$kak_selection_desc
        IFS=',' read -r start_pos end_pos <<< "$selection_desc"
        IFS='.' read -r start_line start_col <<< "$start_pos"
        IFS='.' read -r end_line end_col <<< "$end_pos"

        if [ $start_line -gt $end_line ]; then
            temp=$start_line
            start_line=$end_line
            end_line=$temp
        fi

        permalink=$(gitlinker run -f "$kak_buffile" -s $start_line -e $end_line)

        if [[ $permalink == http* ]]; then
            if command -v pbcopy >/dev/null 2>&1; then
                echo "$permalink" | pbcopy
            elif command -v xsel >/dev/null 2>&1; then
                echo "$permalink" | xsel --input --clipboard
            elif command -v xclip >/dev/null 2>&1; then
                echo "$permalink" | xclip -in -selection clipboard >&- 2>&-
            elif command -v wl-copy >/dev/null 2>&1; then
                echo "$permalink" | wl-copy > /dev/null 2>&1 &
            elif command -v clip.exe >/dev/null 2>&1; then
                echo "$permalink" | clip.exe
            fi

            echo "echo -markup '{Information}GitHub permalink copied to clipboard'"
        else
            echo "echo -markup '{Error}Invalid file'"
        fi
    }
}

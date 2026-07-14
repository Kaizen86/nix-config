# Pipe grep output to less, with colours enabled
grep --color=always -rn "$@" | less -R

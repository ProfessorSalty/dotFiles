function cdf() { # short for `cdfinder`
    cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')" || exit;
}

alias ls="gls -al --color=auto"

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Default ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alert alias for long-running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Load additional aliases if present
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Cargo
. "$HOME/.cargo/env"

# Kitty
export PATH="$HOME/.local/kitty.app/bin:$PATH"

# Starship
eval "$(starship init bash)"


# ─────────────────────────────────────
# Modern CLI aliases
# ─────────────────────────────────────

alias ls='eza --icons'
alias ll='eza -lah --icons'
alias la='eza -a --icons'

alias cat='batcat'


# ─────────────────────────────────────
# fzf
# ─────────────────────────────────────

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi


# ─────────────────────────────────────
# EZA COLORS
# ─────────────────────────────────────

export EZA_COLORS="di=1;38;2;70;220;255:ex=1;38;2;100;255;150:ln=1;38;2;210;140;255:fi=38;2;235;240;245:pi=1;38;2;255;210;80:so=1;38;2;255;120;210:bd=1;38;2;255;100;100:cd=1;38;2;255;100;100:da=38;2;150;160;175:sn=38;2;70;220;255:sb=38;2;150;160;175:ur=38;2;100;220;255:uw=38;2;255;210;100:ux=38;2;100;255;150:gr=38;2;100;220;255:gw=38;2;255;210;100:gx=38;2;100;255;150:tr=38;2;210;140;255:tw=38;2;210;140;255:tx=38;2;210;140;255:*.md=1;38;2;70;220;255:*.tsx=1;38;2;210;140;255:*.ts=1;38;2;100;170;255:*.js=1;38;2;255;210;80:*.jsx=1;38;2;210;140;255:*.json=1;38;2;255;210;80:*.css=1;38;2;255;120;210:*.html=1;38;2;255;100;100:*.yml=1;38;2;255;210;80:*.yaml=1;38;2;255;210;80"


# ─────────────────────────────────────
# Tree listing
# ─────────────────────────────────────

# Usage:
#   lt              → depth 2
#   lt 3            → depth 3
#   lt 3 -I foo     → depth 3, exclude foo
#   lt -I foo       → depth 2, exclude foo

lt() {
    local level=2
    local args=()

    # If the first argument is a number, use it as the tree depth
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        level="$1"
        shift
    fi

    # Pass all remaining arguments directly to eza
    args=("$@")

    eza --tree \
        --level="$level" \
        --icons \
        --group-directories-first \
        "${args[@]}"

    # Count visible directories and files at the selected depth
    local dirs files

    dirs=$(find . \
        -mindepth 1 \
        -maxdepth "$level" \
        ! -path '*/.*' \
        -type d \
        2>/dev/null | wc -l)

    files=$(find . \
        -mindepth 1 \
        -maxdepth "$level" \
        ! -path '*/.*' \
        ! -type d \
        2>/dev/null | wc -l)

    echo
    echo "$dirs directories, $files files"
}


# ─────────────────────────────────────
# Development tools
# ─────────────────────────────────────

# OpenCode
export PATH="$HOME/.opencode/bin:$PATH"

# Kilo
export PATH="$HOME/.kilo/bin:$PATH"


# ─────────────────────────────────────
# Git shortcuts
# ─────────────────────────────────────

alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'


# ─────────────────────────────────────
# Zoxide
# ─────────────────────────────────────

eval "$(zoxide init bash)"


# ─────────────────────────────────────
# Lazygit
# ─────────────────────────────────────

alias lg='lazygit'

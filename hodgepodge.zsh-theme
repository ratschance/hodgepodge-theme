#!/usr/bin/env zsh

RED_B="%{$fg_bold[red]%}"
YELLOW_B="%{$fg_bold[yellow]%}"
CYAN="%{$fg_no_bold[cyan]%}"
MAGENTA="%{$fg_no_bold[magenta]%}"

NEWLINE='
'

# Get the path to file this code is executing in; then
# get the absolute path and strip the filename.
# See https://stackoverflow.com/a/28336473/108857
HP_ROOT=${${(%):-%x}:A:h}

local PIPE="%(?,$CYAN|,$RED_B|)"
if [[ "${USER}" == "root" ]]; then USERCOLOR=${RED_B}; else USERCOLOR=${YELLOW_B}; fi

source "${HP_ROOT}/git_info.zsh"

function hp_setup() {
    autoload -Uz vcs_info
    autoload -Uz add-zsh-hook

    add-zsh-hook precmd hp_vcs_info_precmd_hook
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git*' formats '%b'

    PROMPT='$(get_left_prompt)'
    RPROMPT='$(get_right_prompt)'
}

function get_left_prompt() {
    echo -n "${PIPE}${USERCOLOR}%n${PIPE} "
    echo -n "${MAGENTA}[%3~] "
    if hp_is_git; then
        echo -n "$(hp_git_info)"
        echo -n "${NEWLINE}"
    fi
    echo -n "${CYAN}→ "
    echo -n "%{$reset_color%}"
}

function get_right_prompt() {
    echo -n ""
}

hp_setup

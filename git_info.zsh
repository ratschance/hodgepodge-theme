################################################################################
#
# Script to obtain git info to display on the prompt. Heavily derived from
# hp-prompt by Denys Dovhan [MIT License 2016-2018]:
#
# https://github.com/denysdovhan/hp-prompt
#
################################################################################

RED="%{$fg_no_bold[red]%}"
WHITE="%{$fg_no_bold[white]%}"
YELLOW="%{$fg_no_bold[yellow]%}"

HP_GIT_PREFIX="on "
HP_GIT_SUFFIX=""
HP_GIT_BRANCH_PREFIX=" "
HP_GIT_BRANCH_SUFFIX=""
HP_GIT_BRANCH_COLOR="${YELLOW}"
HP_GIT_STATUS_PREFIX=" ["
HP_GIT_STATUS_SUFFIX="]"
HP_GIT_STATUS_COLOR="${RED}"
HP_GIT_STATUS_UNTRACKED="?"
HP_GIT_STATUS_ADDED="+"
HP_GIT_STATUS_MODIFIED="!"
HP_GIT_STATUS_RENAMED="»"
HP_GIT_STATUS_DELETED="✘"
HP_GIT_STATUS_STASHED="$"
HP_GIT_STATUS_UNMERGED="="
HP_GIT_STATUS_AHEAD="↑"
HP_GIT_STATUS_BEHIND="↓"
HP_GIT_STATUS_DIVERGED="↕"

function hp_vcs_info_precmd_hook() {
    vcs_info
}

function hp_is_git() {
    command git rev-parse --is-inside-work-tree &> /dev/null
}

function hp_git_info() {
    local git_branch="$(hp_git_branch)" git_status="$(hp_git_status)"

    [[ -z $git_branch ]] && return

    echo -n "${WHITE}"
    echo -n "$HP_GIT_PREFIX"
    echo -n "${git_branch}${git_status}"
    echo -n "$HP_GIT_SUFFIX"
}

function hp_git_branch() {
    [[ $HP_GIT_BRANCH_SHOW == false ]] && return

    local git_current_branch="$vcs_info_msg_0_"
    [[ -z "$git_current_branch" ]] && return

    git_current_branch="${git_current_branch#heads/}"
    git_current_branch="${git_current_branch/.../}"

    echo -n "$HP_GIT_BRANCH_COLOR"
    echo -n "$HP_GIT_BRANCH_PREFIX${git_current_branch}$HP_GIT_BRANCH_SUFFIX"
}

function hp_git_status() {
    local INDEX git_status=""

    INDEX=$(command git status --porcelain -b 2> /dev/null)

    # Check for untracked files
    if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_UNTRACKED$git_status"
    fi

    # Check for staged files
    if $(echo "$INDEX" | command grep '^A[ MDAU] ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_ADDED$git_status"
    elif $(echo "$INDEX" | command grep '^M[ MD] ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_ADDED$git_status"
    elif $(echo "$INDEX" | command grep '^UA' &> /dev/null); then
        git_status="$HP_GIT_STATUS_ADDED$git_status"
    fi

    # Check for modified files
    if $(echo "$INDEX" | command grep '^[ MARC]M ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_MODIFIED$git_status"
    fi

    # Check for renamed files
    if $(echo "$INDEX" | command grep '^R[ MD] ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_RENAMED$git_status"
    fi

    # Check for deleted files
    if $(echo "$INDEX" | command grep '^[MARCDU ]D ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_DELETED$git_status"
    elif $(echo "$INDEX" | command grep '^D[ UM] ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_DELETED$git_status"
    fi

    # Check for stashes
    if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
        git_status="$HP_GIT_STATUS_STASHED$git_status"
    fi

    # Check for unmerged files
    if $(echo "$INDEX" | command grep '^U[UDA] ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_UNMERGED$git_status"
    elif $(echo "$INDEX" | command grep '^AA ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_UNMERGED$git_status"
    elif $(echo "$INDEX" | command grep '^DD ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_UNMERGED$git_status"
    elif $(echo "$INDEX" | command grep '^[DA]U ' &> /dev/null); then
        git_status="$HP_GIT_STATUS_UNMERGED$git_status"
    fi

    # Check whether branch is ahead
    local is_ahead=false
    if $(echo "$INDEX" | command grep '^## [^ ]\+ .*ahead' &> /dev/null); then
        is_ahead=true
    fi

    # Check whether branch is behind
    local is_behind=false
    if $(echo "$INDEX" | command grep '^## [^ ]\+ .*behind' &> /dev/null); then
        is_behind=true
    fi

    # Check wheather branch has diverged
    if [[ "$is_ahead" == true && "$is_behind" == true ]]; then
        git_status="$HP_GIT_STATUS_DIVERGED$git_status"
    else
        [[ "$is_ahead" == true ]] && git_status="$HP_GIT_STATUS_AHEAD$git_status"
        [[ "$is_behind" == true ]] && git_status="$HP_GIT_STATUS_BEHIND$git_status"
    fi

    if [[ -n $git_status ]]; then
        echo -n "$HP_GIT_STATUS_COLOR"
        echo -n "$HP_GIT_STATUS_PREFIX$git_status$HP_GIT_STATUS_SUFFIX"
    fi
}

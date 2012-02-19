# set PROMPT_ALWAYS=1 if you want the prompt topline to always print

function collapse_pwd {
    echo $(pwd | sed -e "s,^$HOME,~,")
}

function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    echo '○'
}

function vi_mode_prompt_info() {
  echo "${${KEYMAP/vicmd/"%{$fg[red]%}"}/(main|viins)/}"
}

function prompt_topline() {
    echo "%{$fg[blue]%}%n%{$reset_color%} at %{$fg[yellow]%}%m%{$reset_color%} in %{$fg_bold[green]%}$(collapse_pwd)%{$reset_color%}$(git_prompt_info)"
}

function precmd() {
    NEWPROMPT="$(prompt_topline)"
    if [[ $PROMPT_ALWAYS == 1 || $NEWPROMPT != $PREVPROMPT || -z $PREVPROMPT ]]; then
        TOPLINE="$NEWPROMPT
"
    else
        TOPLINE=""
    fi
    PREVPROMPT=$NEWPROMPT
}

# hack for making tmux maintain current directory properly
# $([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#I") $PWD)

PROMPT='${TOPLINE}$(vi_mode_prompt_info)$(prompt_char) %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

local return_status="%{$fg[red]%}%(?..✘)%{$reset_color%}"
#RPROMPT='${return_status}%{$reset_color%}'

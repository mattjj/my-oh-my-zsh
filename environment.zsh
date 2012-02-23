#
# Sets general shell options and defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Smart URLs
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# General
setopt RC_QUOTES          # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
unsetopt MAIL_WARNING     # Don't print a warning message if a mail file has been accessed

# Jobs
setopt LONG_LIST_JOBS     # List jobs in the long format by default.
setopt AUTO_RESUME        # Attempt to resume existing job before creating a new process.
setopt NOTIFY             # Report status of background jobs immediately.
unsetopt BG_NICE          # Don't run all background jobs at a lower priority.
unsetopt HUP              # Don't kill jobs on shell exit.
unsetopt CHECK_JOBS       # Don't report on jobs when shell exit.

# PATH
typeset -U cdpath fpath infopath manpath path

cdpath=(
  $HOME
  $HOME/Developer
)

infopath=(
  /usr/local/share/info
  /usr/share/info
)

manpath=(
  /usr/local/share/man
  /usr/share/man
)

for path_file in /etc/manpaths.d/*(.N); do
  manpath+=($(<$path_file))
done

path=(
  /usr/local/epd-7.2.2/bin
  /usr/local/{,s}bin
  ~/bin
  /usr/{,s}bin
  /{,s}bin
  /opt/local/Library/Frameworks/Python.framework/Versions/Current/bin
)

for path_file in /etc/paths.d/*(.N); do
  path+=($(<$path_file))
done

# Language
if [[ -z "$LANG" ]]; then
  eval "$(locale)"
fi

# Editors
export EDITOR="vim"
export VISUAL="vim"
export PAGER='less'

# Grep
if zstyle -t ':omz:environment:grep' color; then
  export GREP_COLOR='37;45'
  export GREP_OPTIONS='--color=auto'
fi

# Browser (Default)
if (( $+commands[xdg-open] )); then
  export BROWSER='xdg-open'
fi

if (( $+commands[open] )); then
  export BROWSER='open'
fi

# Less
export LESSCHARSET="UTF-8"
export LESSHISTFILE='-'
export LESSEDIT='vim ?lm+%lm. %f'
export LESS='-F -g -i -M -R -S -w -X -z-4'

if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

# Termcap
if zstyle -t ':omz:environment:termcap' color; then
  export LESS_TERMCAP_mb=$'\E[01;31m'      # begin blinking
  export LESS_TERMCAP_md=$'\E[01;31m'      # begin bold
  export LESS_TERMCAP_me=$'\E[0m'          # end mode
  export LESS_TERMCAP_se=$'\E[0m'          # end standout-mode
  export LESS_TERMCAP_so=$'\E[00;47;30m'   # begin standout-mode
  export LESS_TERMCAP_ue=$'\E[0m'          # end underline
  export LESS_TERMCAP_us=$'\E[01;32m'      # begin underline
fi

# Misc
alias pl='ipython --pylab'
alias plg='ipython qtconsole --pylab=qt'
alias pli='ipython qtconsole --pylab=inline'
alias pln='ipython notebook --pylab inline'
alias plk='ipython kernel'
alias plc='ipython console --existing'
alias gvim='mvim'
alias gv='mvim'
alias v='vim'
alias vv='vim -u NONE'

alias -s py=vim

alias matlab='cd ~matlab && sudo -u matlab /home/matlab/MATLAB/R2011b/bin/matlab -nodesktop -nosplash'

alias top='htop'

function mdown() # {{{
{
    (echo '
        <head>
            <style>
                body {
                    font-family: Georgia;
                    font-size: 17px;
                    line-height: 24px;
                    color: #222;
                    text-rendering: optimizeLegibility;
                    width: 670px;
                    margin: 20px auto;
                    padding-bottom: 80px;
                }
                h1, h2, h3, h4, h5, h6 {
                    font-weight: normal;
                    margin-top: 48px;
                }
                h1 { font-size: 48px; }
                h2 {
                    font-size: 36px;
                    border-bottom: 6px solid #ddd;
                    padding: 0 0 6px 0;
                }
                h3 {
                    font-size: 24px;
                    border-bottom: 6px solid #eee;
                    padding: 0 0 2px 0;
                }
                h4 { font-size: 20px; }
                pre {
                    background-color: #f5f5f5;
                    font: normal 15px Menlo;
                    line-height: 24px;
                    padding: 8px 10px;
                    overflow-x: scroll;
                }
            </style>
        </head>
    '; markdown $@)
}# }}}

function cl() # {{{
{
    if [ $# = 0 ]; then
        \cd && ls -G
    else
        \cd "$*" && ls -G
    fi
} # }}}

function findgrep() # {{{
{
    find . -iname "$1" -exec grep -Hn "$2" {} \;
} # }}}

function redecho # {{{
{
    echo -n "\033[1;31m"
    echo "$@"
    echo -n "\033[m"
} # }}}

### todo setup # {{{
export TODOFILE=~/.todo
export DONEFILE=~/.todone
export TODOHISTORY=~/.todo-history

function show_todo { cat $TODOFILE | gawk '{print NR". " $0}' }

function todo
{
    if [ $# -ne 0 ]
    then
        echo "$@" >> $TODOFILE
        (echo -n "+ " && echo "$*▸  $(date)") >> $TODOHISTORY
    fi
    show_todo
}

# TODO factor out match checking into its own function so that it's not
# repeated between todone and toskip
function todone
{
    if [[ "$*" =~ ^[0-9]+$ ]]
    then
        gsed -i "$1d" $TODOFILE
    elif [ -n "$*" ]
    then
        NUM_MATCHES=$(gsed -n "/$*/p" $TODOFILE | wc -l)
        if [ $NUM_MATCHES -eq 0 ]
        then
            redecho "!! no matches !!"
        elif [ $NUM_MATCHES -gt 1 ]
        then
            redecho "!! multiple matches !!"
            grep --color=always "$*" $TODOFILE | gawk '{print NR". " $0}'
            return
        else
            gsed -n "/$*/s/.*/- \0	$(date)/p" $TODOFILE >> $TODOHISTORY
            gsed -n "/$*/p" $TODOFILE >> $DONEFILE
            gsed -i "/$*/d" $TODOFILE
        fi
    fi
    show_todo
}

function toskip
{
    if [[ "$*" =~ ^[0-9]+$ ]]
    then
        MATCH=$(gsed -n "$1p" $TODOFILE)
        if [ $(gsed -n "/$MATCH/p" $TODOHISTORY | wc -l) -gt 1 ]
        then
            redecho "!! multiple matches in history; revise manually !!"
        else
            gsed -i "/$MATCH/d" $TODOHISTORY
        fi
        gsed -i "/$*/d" $TODOFILE
    elif [ -n "$*" ]
    then
        NUM_MATCHES=$(gsed -n "/$*/p" $TODOFILE | wc -l)
        if [ $NUM_MATCHES -eq 0 ]
        then
            redecho "!! no matches !!"
        elif [ $NUM_MATCHES -gt 1 ]
        then
            redecho "!! multiple matches !!"
            grep --color=always "$*" $TODOFILE | gawk '{print NR". " $0}'
            return
        else
            MATCH=$(gsed -n "/$*/p" $TODOFILE)
            if [ $(gsed -n "/$MATCH/p" $TODOHISTORY | wc -l) -gt 1 ]
            then
                redecho "!! multiple matches in history; revise manually !!"
            else
                gsed -i "/$MATCH/d" $TODOHISTORY
            fi
            gsed -i "/$*/d" $TODOFILE
        fi
    fi
    show_todo
}

function prune_donelist
{
    IFS=$'\n'
    DAYAGOFILE="/tmp/donelist_dayago"
    TESTFILE="/tmp/donelist_testtime"

    rm $DONEFILE

    gtouch -d "-1day" $DAYAGOFILE
    for l in $(tail -n 25 ~/.todo-history | grep '^-')
    do
        gtouch -d "$(echo $l | cut -f2)" $TESTFILE
        if [ $TESTFILE -nt $DAYAGOFILE ]
        then
            echo "$l" | cut -f1 | gsed 's/^- //' >>! $DONEFILE
        fi
    done
}

export PROJECTFILE=~/Documents/unsorted\ notes/projects.txt
function proj
{
    if [[ "$*" =~ ^[0-9]+$ ]]
    then
        gsed -i -e "s/^==>\(.*\)<==$/\1/" -e "$*s/\(.*\)/==>\1<==/" $PROJECTFILE
    elif [ -n "$*" ]
    then
        gsed -i -e "s/^==>\(.*\)<==$/\1/" -e "s/\(.*$*.*\)/==>\1<==/" $PROJECTFILE
    fi
    cat $PROJECTFILE | gawk '{print NR". " $0}'
}

alias ejectcd='drutil tray eject'

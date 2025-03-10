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
HISTCONTROL=ignoredupes:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
# bash theme - partly inspired by https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/robbyrussell.zsh-theme
__bash_prompt() {
    local userpart='`export XIT=$? \
        && [ ! -z "${GITHUB_USER:-}" ] && echo -n "\[\033[0;32m\]@${GITHUB_USER:-} " || echo -n "\[\033[0;32m\]\u " \
        && [ "$XIT" -ne "0" ] && echo -n "\[\033[1;31m\]➜" || echo -n "\[\033[0m\]➜"`'
    local gitbranch='`\
        if [ "$(git config --get devcontainers-theme.hide-status 2>/dev/null)" != 1 ] && [ "$(git config --get codespaces-theme.hide-status 2>/dev/null)" != 1 ]; then \
            export BRANCH="$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)"; \
            if [ "${BRANCH:-}" != "" ]; then \
                echo -n "\[\033[0;36m\](\[\033[1;31m\]${BRANCH:-}" \
                && if [ "$(git config --get devcontainers-theme.show-dirty 2>/dev/null)" = 1 ] && \
                    git --no-optional-locks ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                        echo -n " \[\033[1;33m\]✗"; \
                fi \
                && echo -n "\[\033[0;36m\]) "; \
            fi; \
        fi`'
    local lightblue='\[\033[1;34m\]'
    local removecolor='\[\033[0m\]'
    PS1="${userpart} ${lightblue}\w ${gitbranch}${removecolor}\$ "
    unset -f __bash_prompt
}
__bash_prompt
export PROMPT_DIRTRIM=4

# Check if the terminal is xterm
if [[ "$TERM" == "xterm" ]]; then
    # Function to set the terminal title to the current command
    preexec() {
        local cmd="${BASH_COMMAND}"
        echo -ne "\033]0;${USER}@${HOSTNAME}: ${cmd}\007"
    }

    # Function to reset the terminal title to the shell type after the command is executed
    precmd() {
        echo -ne "\033]0;${USER}@${HOSTNAME}: ${SHELL}\007"
    }

    # Trap DEBUG signal to call preexec before each command
    trap 'preexec' DEBUG

    # Append to PROMPT_COMMAND to call precmd before displaying the prompt
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }precmd"
fi

# User Aliases
# From old bash file
alias levelup='sudo apt-get clean && sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y'
alias pydf='pydf -ha'
alias himem='ps auxf | sort -nr -k 4 | head -10'
alias hicpu='ps auxf | sort -nr -k 3 | head -10'
alias get='sudo apt-get install'
# fix alias expansion with sudo
alias sudo='sudo '
function dif { colordiff -y "$1" "$2" | less -r; }

# Better directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Safer file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff --patch-with-stat'
alias gb='git branch'
alias gpo='git push origin'

# Navigation helpers
alias c='clear'
alias h='history'
alias prj='cd ~/Desktop/projects'

# Python venv
alias venv='source venv/bin/activate'

# my notepad
alias note='printf "\n\n---\n# %(%F)T %(%T)T\n" >> ~/notes/scratchpad.md; code ~/notes/scratchpad.md &'


# Function to initialize & work with my projects from a vscode devcontainer:
#  - When starting a new project, automatically initialize the github and clone it
#  - Build a fresh devcontainer to develop the project in, spin it up, and open bash inside
#  - Open VSCode in the project workspace with a prompt to connect to the newly created devontainer
# Uses central Dockerfile and devcontainer.json templates so I don't need to create or copy this junk into ever new project I create
# Assumes Dockerfile & decontainer.json templates are in ~/.dev
# Function to handle dev container operations
dev() {
    # If no parameters provided, just spin up devcontainer in current directory & open VSCode
    if [ -z "$1" ]; then
        echo "Opening VS Code and connecting to dev container in current directory..."
        
        # Start the container in the background
        devcontainer up --workspace-folder .
        
        # Open VS Code with the current folder (detached)
        code . >/dev/null 2>&1 &
        
        # Execute bash in the container
        devcontainer exec --workspace-folder bash
        
        return 0
    fi
    
    # If first parameter is "init", perform full initialization
    if [ "$1" = "init" ]; then
        # Check if project name is provided
        if [ -z "$2" ]; then
            echo "Error: Project name is required for initialization"
            echo "Usage: dev init <project_name>"
            return 1
        fi

        PROJECT_NAME="$2"
        
        # Check if the template files exist
        if [ ! -d ~/.dev/.devcontainer ] || [ ! -f ~/.dev/.devcontainer/Dockerfile ] || [ ! -f ~/.dev/.devcontainer/devcontainer.json ]; then
            echo "Error: Template files not found in ~/.dev/.devcontainer/"
            echo "Please ensure both Dockerfile and devcontainer.json exist in ~/.dev/.devcontainer/"
            return 1
        fi
        
        # Create GitHub repo and clone it
        echo "Creating GitHub repository: $PROJECT_NAME"
        if ! gh repo create "$PROJECT_NAME" --public --clone; then
            echo "Error: Failed to create GitHub repository"
            return 1
        fi
        
        # Move into the newly created project directory
        cd "$PROJECT_NAME" || return 1
        
        # Copy template files
        cp -r ~/.dev/.devcontainer .
        
        # Commit the initialized devcontainer
        git add .
        git commit -m "Initial commit: Set up development container"
        
        # Push changes with upstream tracking
        git push -u origin $(git symbolic-ref --short HEAD)
        
        # Build the devcontainer image and run the container
        echo "Spinning up fresh dev environment"
        devcontainer up --workspace-folder .

        # Open VS Code and attach to container
        echo "Opening VS Code, please attach to running container..."

        # Open VS Code with the project folder (detached and redirecting output)
        code . >/dev/null 2>&1 &
        
        echo "Project $PROJECT_NAME has been initialized successfully!"
        echo "Connecting to dev machine..."
        
        # Execute bash in the container
        devcontainer exec bash
        
        return 0
    fi
    
    # If we get here, invalid usage
    echo "Usage: dev [init <project_name>]"
    echo "  - With no arguments: Opens current directory in VS Code with devcontainer"
    echo "  - With 'init <project_name>': Initializes a new project with devcontainer setup"
    return 1
}

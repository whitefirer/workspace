# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
# export PATH=$HOME/.nh/bin:/usr/local/opt/go@1.16/bin:/Users/morty/go/bin:/usr/local/bin:$PATH
export PATH="${PATH}:${HOME}/.nh/bin"
export PATH="${PATH}:${HOME}/go/bin"
export PATH="${PATH}:${HOME}/.krew/bin"
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Path to your oh-my-zsh installation.
export ZSH="/Users/morty/.oh-my-zsh"
export EDITOR="vim"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  autojump
  kubectl
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-kubectl-prompt
)

[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#alias kubectl="kubecolor"
#alias k="kubectl"
alias k="kubecolor"
alias kubectl="kubectl"
alias ks="k safe"
alias kb="kubebuilder"
alias km="kustomize"
alias ctx="kubectl ctx"
alias ns="kubectl ns"
alias kail="kubectl tail"
alias fzfp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
alias rm="trash"
alias mkm="CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build main.go"

#compdef _kubectl k
compdef kubecolor=kubectl

export KUBECTL_SAFE_COMMANDS=version,-h,help
functions[_kubectl-og]=$functions[_kubectl]

_kubectl() {
    words[$words[(i)safe]]=()
    _kubectl-og "$words[*]"
}

autoload -U colors; colors
function right_prompt() {
  local color="blue"

  if [[ "$ZSH_KUBECTL_NAMESPACE" =~ "system" ]]; then
    color="yellow"
  fi

  if [[ "$ZSH_KUBECTL_CONTEXT" =~ "desktop" || "$ZSH_KUBECTL_CONTEXT" =~ "dev" ]]; then
    color="green"
  fi

  if [[ "$ZSH_KUBECTL_CONTEXT" =~ "prod" ]]; then
    color="red"
  fi

  echo "%{$terminfo[bold]$fg[$color]%}\u2638($ZSH_KUBECTL_PROMPT)%{$reset_color%}"
}
RPROMPT='$(right_prompt)'
#RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')
source $HOME/.oh-my-zsh/custom/plugins/zsh-histdb/sqlite-history.zsh
autoload -Uz add-zsh-hook

_zsh_autosuggest_strategy_histdb_top() {
    local query="
        select commands.argv from history
        left join commands on history.command_id = commands.rowid
        left join places on history.place_id = places.rowid
        where commands.argv LIKE '$(sql_escape $1)%'
        group by commands.argv, places.dir
        order by places.dir != '$(sql_escape $PWD)', count(*) desc
        limit 1
    "
    suggestion=$(_histdb_query "$query")
}

#ZSH_AUTOSUGGEST_STRATEGY=histdb_top

function help(){
  content="$terminfo[bold]$fg[blue]命令大全$reset_color
$terminfo[bold]glances$reset_color 资源监控"
  echo "$content"
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export PATH="/usr/local/opt/sqlite/bin:$PATH"

source /Users/morty/.config/broot/launcher/bash/br

export PATH=$PATH:/Users/morty/.fef/bin

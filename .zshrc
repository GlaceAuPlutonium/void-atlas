HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=2000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=rounded --prompt='❯ '"
export PATH="$HOME/.local/bin:$PATH"
bindkey -e
zstyle :compinstall filename '/home/gap/.zshrc'

eval "$(zoxide init zsh)"
source <(fzf --zsh)
eval "$(starship init zsh)"

source ~/.zsh_plugins.zsh

alias ff='fastfetch'
alias ffull='fastfetch --config ~/.config/fastfetch/config_full.jsonc'
alias localsend='~/.local/bin/LocalSend-1.17.0.AppImage'
alias rgh='rg --hidden'
alias cat='bat'
alias catr='bat --paging=never --style=plain'
alias ls='eza --icons=auto'
alias ll='eza -l --icons=auto'
alias la='eza -la --icons=auto'
alias tree='eza -T --icons=auto'

autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ============================================
# dotfiles zshrc — universal across machines
# machine-specific stuff goes in ~/.zshrc.local
# ============================================

# PATH for local binaries
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (macOS only — no-op elsewhere)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Starship prompt
eval "$(starship init zsh)"

# Better defaults
export CLICOLOR=1

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Modern CLI replacements
alias ls='lsd'
alias ll='lsd -lah'
alias la='lsd -A'
alias lt='lsd --tree'
alias cat='bat'
alias catplain='bat --style=plain'

# Handy git shortcut (carried over from old setup)
alias P='git pull'

# zsh plugins (cloned by install.sh — no oh-my-zsh needed)
PLUGINS="$HOME/.local/share/zsh-plugins"
[ -f "$PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# fzf key bindings + completion
[ -f ~/.local/share/fzf/key-bindings.zsh ] && source ~/.local/share/fzf/key-bindings.zsh
[ -f ~/.local/share/fzf/completion.zsh ] && source ~/.local/share/fzf/completion.zsh

# Machine-specific config (untracked — secrets, tool inits, extra PATHs)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
setopt interactive_comments

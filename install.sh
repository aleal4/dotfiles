#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# dotfiles installer — macOS (arm64) + Ubuntu (x86_64)
# Installs pinned binaries to ~/.local/bin, clones zsh plugins,
# and symlinks configs. Idempotent: safe to re-run.
# ---------------------------------------------------------------

LSD_VERSION="v1.1.5"
BAT_VERSION="v0.25.0"
FZF_VERSION="v0.62.0"

BIN="$HOME/.local/bin"
DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PLUGINS="$HOME/.local/share/zsh-plugins"
mkdir -p "$BIN" "$HOME/.config" "$HOME/.local/share/fzf" "$PLUGINS"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS-$ARCH" in
  Darwin-arm64)
    LSD_T="aarch64-apple-darwin"
    BAT_T="aarch64-apple-darwin"
    FZF_T="darwin_arm64"
    ;;
  Linux-x86_64)
    LSD_T="x86_64-unknown-linux-gnu"
    BAT_T="x86_64-unknown-linux-gnu"
    FZF_T="linux_amd64"
    ;;
  *)
    echo "unsupported platform: $OS-$ARCH" >&2
    exit 1
    ;;
esac

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> installing lsd ${LSD_VERSION}"
curl -sL "https://github.com/lsd-rs/lsd/releases/download/${LSD_VERSION}/lsd-${LSD_VERSION}-${LSD_T}.tar.gz" \
  | tar xz -C "$TMP"
mv "$TMP"/lsd-*/lsd "$BIN/"

echo "==> installing bat ${BAT_VERSION}"
curl -sL "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat-${BAT_VERSION}-${BAT_T}.tar.gz" \
  | tar xz -C "$TMP"
mv "$TMP"/bat-*/bat "$BIN/"

echo "==> installing fzf ${FZF_VERSION}"
curl -sL "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION#v}-${FZF_T}.tar.gz" \
  | tar xz -C "$BIN"

echo "==> fetching fzf shell integration"
for f in key-bindings.zsh completion.zsh; do
  curl -sL "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/$f" \
    -o "$HOME/.local/share/fzf/$f"
done

echo "==> installing starship (latest)"
curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$BIN"

echo "==> cloning zsh plugins"
clone_or_pull() {
  local repo="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --quiet
  else
    git clone --quiet --depth 1 "https://github.com/$repo" "$dest"
  fi
}
clone_or_pull "zsh-users/zsh-autosuggestions"     "$PLUGINS/zsh-autosuggestions"
clone_or_pull "zsh-users/zsh-syntax-highlighting" "$PLUGINS/zsh-syntax-highlighting"

link() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    echo "    backing up $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "    linked $dst -> $src"
}

echo "==> linking configs"
link "$DOTFILES/zshrc" "$HOME/.zshrc"
link "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
link "$DOTFILES/ssh_config" "$HOME/.ssh/config"

echo ""
echo "done — restart your shell:  exec zsh"

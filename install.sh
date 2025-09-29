#!/usr/bin/env bash

REPO_URL="https://github.com/danielpolov/simplewayshot.git"
TOOL_NAME="simplewayshot"
INSTALL_DIR="$HOME/.local/share/$TOOL_NAME"
BIN_DIR="$HOME/.local/bin"
DEPENDENCIES=("jq" "grim" "slurp" "zenity" "wlr-randr")


# Detect package manager
detect_pkg_manager() {
	if command -v pacman >/dev/null; then
		echo "pacman"
	elif command -v apt >/dev/null; then
		echo "apt"
	elif command -v dnf >/dev/null; then
		echo "dnf"
	elif command -v zypper >/dev/null; then
		echo "zypper"
	else
		echo "unknown"
	fi
}

# Install dependencies
install_deps() {
	local pkg_manager="$1"
	local missing=()
	
	for dep in "${DEPENDENCIES[@]}"; do
		if ! command -v "$dep" &>/dev/null; then
			missing+=("$dep")
		fi
	done
	
	if [ ${#missing[@]} -gt 0 ]; then
		echo "Installing missing dependencies: ${missing[*]}"
		case "$pkg_manager" in
			pacman) sudo pacman -Sy --noconfirm "${missing[@]}" ;;
			apt)    sudo apt update && sudo apt install -y "${missing[@]}" ;;
			dnf)    sudo dnf install -y "${missing[@]}" ;;
			zypper) sudo zypper install -y "${missing[@]}" ;;
			*)      echo "Manual install required for: ${missing[*]}" >&2 ;;
		esac
	fi
}

# Install the tool
install_tool() {
	# Clone repo
	echo "Downloading $TOOL_NAME..."
	git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" || \
		{ echo "Git failed! Using curl fallback..."; curl -L "$REPO_URL/archive/main.tar.gz" | tar xz -C /tmp && mv "/tmp/$TOOL_NAME-main" "$INSTALL_DIR"; }
	
	mkdir -p "$BIN_DIR"
	ln -sf "$INSTALL_DIR/$TOOL_NAME.sh" "$BIN_DIR/$TOOL_NAME"
	chmod +x "$INSTALL_DIR/$TOOL_NAME.sh"
	add_to_path
}

# Ensure ~/.local/bin in PATH
add_to_path() {
	local config_file=""
	local path_string='export PATH="$HOME/.local/bin:$PATH"'
	
	[[ -f ~/.bashrc ]] && config_file=~/.bashrc
	[[ -f ~/.zshrc ]] && config_file=~/.zshrc
	[[ -f ~/.profile ]] && config_file=~/.profile
	
	if [ -n "$config_file" ] && ! grep -q ".local/bin" "$config_file"; then
		echo "$path_string" >> "$config_file"
		echo "Added ~/.local/bin to $config_file"
	fi
	
	export PATH="$HOME/.local/bin:$PATH"
}

# Verify installation
verify_install() {
	if ! command -v "$TOOL_NAME" &>/dev/null; then
		echo "Installation failed! Try manual steps:"
		echo "  1. Run: source ~/.bashrc (or your shell config)"
		echo "  2. Check $BIN_DIR exists"
		exit 1
	fi
	echo "Success! Run '$TOOL_NAME' to start using."
}

main() {
	PKG_MGR=$(detect_pkg_manager)
	if [[ "$PKG_MGR" == "unknown" ]]; then
		echo "Unsupported system! Manual dependency install required."
	else
		install_deps "$PKG_MGR"
	fi
	
	install_tool
	verify_install
}

main

#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.config

echo -e "${BLUE}Processing configuration directories...${NC}"
for dir in "$SCRIPT_DIR"/.config/*; do
    dirname=$(basename "$dir")
    target_path=~/.config/"$dirname"
    echo -e "${BLUE}Setting up ${YELLOW}$dirname${BLUE} configuration...${NC}"

    if [[ ! -L "$target_path" ]]; then
        if [[ -e "$target_path" ]]; then
            echo -e "  ${YELLOW}Backing up existing $target_path to $target_path.bak${NC}"
            mv "$target_path" "$target_path.bak"
        fi
        echo -e "  ${GREEN}Using default link: ${YELLOW}$dir${GREEN} → ${YELLOW}$target_path${NC}"
        ln -s "$dir" "$target_path"
    fi
done

echo -e "${BLUE}Processing ~HOME/ files...${NC}"
find "$SCRIPT_DIR"/home -type f | while read -r file; do
    rel_path="${file#"$SCRIPT_DIR/home/"}"
    dir_part=$(dirname "$rel_path")

    echo -e "${BLUE}Setting up ${YELLOW}$rel_path${BLUE} file...${NC}"

    if [[ "$dir_part" != "." ]]; then
        mkdir -p ~/"$dir_part"
    fi

    target_path=~/"$rel_path"

    if [[ ! -L "$target_path" ]]; then
        if [[ -e "$target_path" ]]; then
            echo -e "  ${YELLOW}Backing up existing $target_path to $target_path.bak${NC}"
            mv "$target_path" "$target_path.bak"
        fi
        echo -e "  ${GREEN}Using default link: ${YELLOW}$file${GREEN} → ${YELLOW}$target_path${NC}"
        ln -s "$file" "$target_path"
    fi
done

if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$(uname -m)" == "arm64" ]]; then
        echo -e "${BLUE}Setting up Homebrew for Apple Silicon...${NC}"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    echo -e "${GREEN}Homebrew installed successfully!${NC}"
fi

if command -v brew &> /dev/null; then
    echo -e "${YELLOW}Installing packages from Brewfile...${NC}"
    brew bundle --file="$SCRIPT_DIR/tools/Brewfile"
    echo -e "${GREEN}Brewfile packages installed successfully!${NC}"
fi

if ! command -v mise &> /dev/null; then
    echo -e "${YELLOW}Installing mise...${NC}"
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

mise install

if command -v op &> /dev/null; then
    if op document get mise.config --out-file ~/.config/mise/config.local.toml --force &>/dev/null; then
        echo -e "${GREEN}Successfully retrieved local mise config from 1Password${NC}"
        mise install &> /dev/null
    else
        echo -e "${YELLOW}Could not find mise.config document in 1Password.${NC}"
    fi
fi

mkdir -p ~/Library/Fonts

if ! ls ~/Library/Fonts/SF-* &> /dev/null; then
    echo -e "${BLUE}Installing fonts...${NC}"
    mise exec gcloud -- gcloud components install gsutil --quiet &> /dev/null
    if mise exec gcloud -- gsutil cp gs://dev-pronin/fonts.tar.gz /tmp/fonts.tar.gz 2> /dev/null; then
        tar -xzf /tmp/fonts.tar.gz -C ~/Library/Fonts/
    else
        echo -e "${YELLOW}Could not download fonts (is gcloud authenticated?). Skipping.${NC}"
    fi
fi

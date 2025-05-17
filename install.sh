#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

mkdir -p ~/.config

echo -e "${BLUE}Processing configuration directories...${NC}"
for dir in "$(pwd)"/.config/*; do
    dirname=$(basename "$dir")
    echo -e "${BLUE}Setting up ${YELLOW}$dirname${BLUE} configuration...${NC}"

    if [[ ! -L ~/.config/"$dirname" ]]; then
        echo -e "  ${GREEN}Using default link: ${YELLOW}$dir${GREEN} → ${YELLOW}~/.config/$dirname${NC}"
        ln -sf "$dir" ~/.config/"$dirname"
    fi
done

echo -e "${BLUE}Processing ~HOME/ files...${NC}"
find "$(pwd)"/home -type f | while read -r file; do
    rel_path="${file#"$(pwd)/home/"}"
    dir_part=$(dirname "$rel_path")
    filename=$(basename "$file")

    echo -e "${BLUE}Setting up ${YELLOW}$rel_path${BLUE} file...${NC}"

    if [[ "$dir_part" != "." ]]; then
        mkdir -p ~/"$dir_part"
    fi

    target_path=~/"$rel_path"

    if [[ ! -L "$target_path" ]]; then
        echo -e "  ${GREEN}Using default link: ${YELLOW}$file${GREEN} → ${YELLOW}$target_path${NC}"
        ln -sf "$file" "$target_path"
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
    brew bundle --file="./tools/Brewfile"
    echo -e "${GREEN}Brewfile packages installed successfully!${NC}"
fi

if ! command -v mise &> /dev/null; then
    echo -e "${YELLOW}Installing mise...${NC}"
    curl https://mise.run | sh
fi

mise install

if command -v op &> /dev/null; then
    if op document get mise.config --out-file ~/.config/mise/config.local.toml --force &>/dev/null; then
        echo -e "${GREEN}Successfully retrieved local mise config from 1Password${NC}"
        mise install &> /dev/null
        mise config &> /dev/null
    else
        echo -e "${YELLOW}Could not find mise.config document in 1Password.${NC}"
    fi
fi

mkdir -p ~/Library/Fonts

if ! ls ~/Library/Fonts/SF-* &> /dev/null; then
    gcloud components install gsutil --quiet &> /dev/null
    echo -e "${BLUE}Installing fonts...${NC}"
    gsutil cp gs://dev-pronin/fonts.tar.gz /tmp/fonts.tar.gz 2> /dev/null
    tar -xzf /tmp/fonts.tar.gz -C ~/Library/Fonts/
fi

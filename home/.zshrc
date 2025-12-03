export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export STARSHIP_CONFIG=~/.config/starship/config.toml
export SSH_AUTH_SOCK=~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

for config_file in $HOME/.config/zsh/*.zsh; do
    source "$config_file"
done

eval "$(~/.local/bin/mise activate zsh)"
eval "$(starship init zsh)"

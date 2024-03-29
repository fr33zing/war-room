{
  programs.bash.interactiveShellInit = ''
    CONFIG_DIR="/etc/nixos"
    CONFIG_NAME="war-room"
    FLAKE="$CONFIG_DIR#$CONFIG_NAME"

    rebuild () {
      sudo nixos-rebuild switch --flake "$FLAKE"
    }

    update () (
      cd "$CONFIG_DIR"
      sudo git fetch
      sudo git reset --hard origin/main
      rebuild
    )
  '';
}

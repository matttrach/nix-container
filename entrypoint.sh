#!/bin/sh
set -x
# https://nixos.org/manual/nix/unstable/command-ref/nix-shell.html
# ignore the shell the user is attempting to exec, use nix
exec /root/.nix-profile/bin/nix-shell "$SHELL_PATH" --command "$3"

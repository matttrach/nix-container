{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell rec {
  name = "awesome";
  buildInputs = with pkgs; [
      bash
      niv
      coreutils
      curl
      findutils
      fzf
      git
      glibcLocales
      host
      jq
      man
      neovim
      nmap
      openssh
      ripgrep
      ssh-agents
      ssh-copy-id
      tree
      wget
  ];
  shellHook = ''
    source ~/.bashrc
  '';
}

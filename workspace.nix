let
  sources = import ./nix/sources.nix;
  pkgs = import sources.stable {};
  com = import sources.community {};
  awe-python = com.python3;
  openstack-cli = awe-python.withPackages (p: with p; [
    python-openstackclient
  ]);
  # Build older derivation from hash
  # https://lazamar.co.uk/nix-versions/?package=openssh&version=8.2p1&fullName=openssh-8.2p1&keyName=openssh&revision=c83e13315caadef275a5d074243c67503c558b3b&channel=nixpkgs-unstable#instructions
  sshpkg = import (builtins.fetchGit {
    name = "gitlabs-openssh";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixpkgs-unstable";
    rev = "c83e13315caadef275a5d074243c67503c558b3b";
  }) {};
  gitlabssh = sshpkg.openssh;
in
pkgs.mkShell {
  buildInputs = [
      gitlabssh
      openstack-cli
      com.age
      com.awscli
      com.bash
      com.borgbackup
      com.coreutils
      com.curl
      com.docker
      com.docker-compose
      com.doctl
      com.findutils
      com.fzf
      com.git
      com.glab
      com.glibcLocales
      com.gnupg
      com.go
      com.host
      com.jq
      com.man
      com.niv
      com.nix-linter
      com.nmap
      com.perl
      com.ping
      com.ripgrep
      com.shellcheck
      com.shfmt
      com.sops
      com.ssh-agents
      com.ssh-copy-id
      com.terraform
      com.terragrunt
      com.tree
      com.vault
      com.wget
  ];
  shellHook = ''
    source ~/.bashrc
  '';
}

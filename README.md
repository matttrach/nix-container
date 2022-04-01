# Nix Container

This is an Alpine container made to be used as a dev machine on a remote docker host.
The main idea is to build dependencies into nix shell files in a repo and only pull in those dependencies when developing products.

I develop in vscode, so I added a few small things to make that work better (notably "libstdc++").
I also formed a /workspaces directory where you can clone code.
The first time you load up vscode it takes a bit, because it is installing the vscode server, but subsequent times it loads acceptably (less than 20sec).


## Development Workflow

1. clone in your codebase to the /workspaces directory
2. cd to your codebase's '.env' directory
3. run 'nix-shell' to set up your environment (the shell should load a local .envrc as well)

- the first time you spin up the environment you will not have any way to clone code, load the workspaces nix file, then manually add your key to the agent.

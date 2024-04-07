{ pkgs, ... }: {
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    discord
    bat
    eza
    gnumake
    R
    ccls
    cloc
    coq
    ocaml
    procs
    hexyl
    ripgrep
    deno
    jq
    utm
    gimp
    drawio
    inkscape
    yq-go
    aws-sam-cli
    firebase-tools
    go
    lazygit
    bison
    terraform-lsp
    tmux
    tree
    alacritty
    imagemagick
    lua-language-server
    starship
    fzy
    terraform
    mattermost
    wireshark
    zoom-us
    marp-cli
    gtkwave
  ];

  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}

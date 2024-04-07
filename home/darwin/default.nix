{ pkgs, ... }: {
  home.stateVersion = "23.11";
  home.packages = with pkgs; [ discord bat eza ocaml ];

  programs = { home-manager.enable = true; };
}

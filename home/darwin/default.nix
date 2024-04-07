{ pkgs, ... }: {
  programs.home-manager.enable = true;
  home.stateVersion = "23.11";
  home.packages = with pkgs; [ discord ];
}

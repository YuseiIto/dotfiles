# Darwin common configurations
{ pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  services.nix-daemon.enable = true; # required by nix-darwin

  nix.settings.trusted-users = [ "yuseiito" ];

  environment.variables = { EDITOR = "nvim"; };

  fonts = {
    packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans noto-fonts-emoji ];
  };

  time.timeZone = "Asia/Tokyo";
}

{ pkgs, ... }: {
  home.stateVersion = "23.11";
  home.packages = with pkgs; [ discord bat eza gnumake R ccls cloc coq ocaml procs hexyl ripgrep deno jq
];

  programs = { home-manager.enable = true; };
}

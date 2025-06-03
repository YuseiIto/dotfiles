{ ... }:
let username = "yuseiito";
in {
  system.stateVersion = 5;
  imports = [ ../../modules/darwin ];
  users.users."${username}" = { home = "/Users/${username}"; };

  networking = { hostName = "belle"; };
}

{ ... }:
let username = "yuseiito";
in {
  imports = [ ../../modules/darwin ];

  users.users."${username}" = { home = "/Users/${username}"; };

  networking = { hostName = "belle"; };
}

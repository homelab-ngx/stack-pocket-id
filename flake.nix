{
  description = "Pocket ID, a passkey sign-in server, as a stack for homelab-ngx";

  # The homelab daemon builds nixosModules.default on its base module with
  # the nixpkgs homelab-stack.json recommends (manifest version 8).
  outputs = _: {
    nixosModules.default = ./stack.nix;
  };
}

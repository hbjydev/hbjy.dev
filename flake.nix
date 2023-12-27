{
  description = "Example kickstart Node.js backend project.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs) nodejs_21 corepack_21;
          name = "example";
          version = "0.1.0";
        in
        {
          devShells = {
            default = pkgs.mkShell {
              buildInputs = [ nodejs_21 corepack_21 ];
              inputsFrom = [];
            };
          };

          packages = {};
        };
    };
}

{
  description = "Example kickstart Node.js backend project.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs) nodejs_21 just python3 pkg-config vips buildNpmPackage;
          name = "hbjy.dev";
          version = "0.1.0";
        in
        {
          devShells = {
            default = pkgs.mkShell {
              buildInputs = [ just ];
              inputsFrom = [ self'.packages.default ];
            };
          };

          packages = {
            default = buildNpmPackage {
              pname = "${name}";
              inherit version;
              src = ./.;

              nodejs = nodejs_21;

              buildInputs = [ vips ];
              nativeBuildInputs = [
                python3
                pkg-config
                vips
              ];

              installPhase = ''
                cp -r dist $out
              '';

              npmDepsHash = "sha256-gEqAr0bK0gljjgvZZGZvWF4pk7wwGHNlI/1z5q36a8E=";
              npmPackFlags = [ "--ignore-scripts" ];
              NODE_OPTIONS = "--openssl-legacy-provider";
            };
          };
        };
    };
}

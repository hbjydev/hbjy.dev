{
  description = "Example kickstart Node.js backend project.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs)
            buildNpmPackage
            just
            nodejs_21
            pkg-config
            python3
            terraform
            vips
            ;
          name = "hbjy.dev";
          version = "0.1.0";
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          devShells = {
            default = pkgs.mkShell {
              buildInputs = [
                just
                (terraform.withPlugins (ps: [
                  ps.cloudflare
                ]))
              ];
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

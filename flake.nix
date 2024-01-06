{
  description = "Example kickstart Node.js backend project.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs) nodejs_21 python3 pkg-config vips buildNpmPackage;
          name = "hbjy.dev";
          version = "0.1.0";
        in
        {
          devShells = {
            default = pkgs.mkShell {
              buildInputs = [ nodejs_21 ];
              inputsFrom = [];
            };
          };

          packages = {
            default = buildNpmPackage {
              pname = "${name}";
              inherit version;
              src = ./.;

              buildInputs = [ vips ];
              nativeBuildInputs = [
                python3
                pkg-config
                vips
              ];

              installPhase = ''
                cp -r dist $out
              '';

              dontNpmInstall = true;
              makeCacheWritable = true;
              npmDepsHash = "sha256-Zu9R9+CsN9RY0EOs3uDTdvpsaTJywKugwp0e3sqfAyg=";
              npmPackFlags = [ "--ignore-scripts" ];
              NODE_OPTIONS = "--openssl-legacy-provider";
            };
          };
        };
    };
}

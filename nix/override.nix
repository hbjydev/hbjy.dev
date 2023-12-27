{ pkgs ? import <nixpkgs> { inherit system; }, system ? builtins.currentSystem }:

let
  name = "hbjy.dev";
  vipsVersion = "8.14.5";
  nodePackages = import ./default.nix { inherit pkgs system; };
  sharpVips = builtins.fetchurl {
    url = "https://github.com/lovell/sharp-libvips/releases/download/v${vipsVersion}/libvips-${vipsVersion}-linux-x64.tar.gz";
    sha256 = "0948jfql4ycnvp95906dsaszlklsxdahscia75wdf2lcjajmlq2n";
  };
in
nodePackages // {
  sharp = nodePackages.package.override {
    nativeBuildInputs = with pkgs; [ pkg-config ];
    propagatedBuildInputs = with pkgs; [ vips ];
    dontNpmInstall = true;
    preRebuild = ''
      mkdir -p $out/lib/node_modules/hbjy.dev/node_modules/sharp/vendor/${vipsVersion}
      tar -xvf ${sharpVips} -C $out/lib/node_modules/hbjy.dev/node_modules/sharp/vendor/${vipsVersion}
    '';
  };
}

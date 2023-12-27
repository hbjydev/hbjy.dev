run:
  pnpm run dev

update-npm:
  #!/usr/bin/env bash
  node2nix -18 \
    -c nix/default.nix \
    -o nix/node-packages.nix \
    -e nix/node-env.nix \
    -l package-lock.json

build package='default':
  #!/usr/bin/env bash
  DERIVATION=$(nix build --json)

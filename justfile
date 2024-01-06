run:
  npm start

build:
  #!/usr/bin/env bash
  DERIVATION=$(nix build --json --no-link --print-build-logs .)
  OUTPUT=$(echo $DERIVATION | jq -r .[0].outputs.out)
  cp -r $OUTPUT dist

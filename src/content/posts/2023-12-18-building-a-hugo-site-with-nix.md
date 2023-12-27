---
title: Building a Hugo site with Nix
date: 2023-12-18
description: How I learned to build up a Hugo site using Nix.
readingTime: true
---

So when the time came to rebuild this blog with [Hugo](https://gohugo.io), I
knew it was probably a good excuse to learn how to use Nix for more
general-purpose tasks, like generating a static site with a generator. There
were some bumps along the way, but for the most part, having my builds be
declarative & reproducible was a good idea, I think.

It all starts out with a Hugo site. If you've not got one, they have a
[great guide for that](https://gohugo.io/getting-started/quick-start/). Once
you have that, you can move on to configuring a Nix flake. All I did to start
with (while I figured my way around the Hugo CLI) was set up a dev shell.

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-23.11";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      perSystem = { self', pkgs, ... }:
        let
          inherit (pkgs) just hugo jq;
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [ just jq hugo ];
          };
        };
    };
}
```

This let me run `nix develop` to drop into a pre-configured shell with `just`,
`jq`, and `hugo` installed. Ignoring the other two packages, we're gonna be
using `hugo` here to quickly test out our site.

```bash
$ hugo serve
...
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

Cool, so our site works. Now, what I _could_ do is just blindly use GitHub's
template for building sites, but being the tinkerer I am, that wasn't the best
I could do. So what I did was dig into the way that Nixpkgs's `runCommand` util
worked. It seemed to do what I wanted, it lets you run a series of commands and
populate a path at the variable `$out` with a file or directory to be persisted
in the Nix store. So I set about doing that.

I knew that Hugo sets up some in-situ directories to track build state (things
like lockfiles, pre-compiled static assets, etc.), so I was going to need a
temporary working directory to run all this in. I also knew that I would need
to probably call it with the `--minify` flag to be relatively performant.

All said, here's what I landed on, putting it in my `perSystem` block in my
flake:

```nix
{ pkgs, ... }: {
    ...
    packages = {
      default = pkgs.runCommand "dist" {
        src = ./.;
        buildInputs = [ hugo ];
      } ''
        work=$(mktemp -d)
        cp -r $src/* $work
        (cd $work && hugo --minify)
        cp -r $work/public $out
        rm -rf $work
      '';
    };
}
```

So what we've got here is `runCommand`, creating an output in the store called
`dist`, taking the current directory (i.e. where both my flake and Hugo site
root are) as a source input, and configuring `hugo` to be available in the
build's `PATH`.

Then, we're giving it a multi-line string which is pretty much equivalent to a
bash script in this instance. We create a temporary working directory (which we
store the path to in a variable called `work`), make a copy of our sources
there, and then run `hugo --minify` from that folder to build our site fully.
With that done, we can finally copy the contents of the `public/` directory to
the `$out` path in the Nix store.

All this comes together to give us a path on the nix store
(`/nix/store/<hash>-dist/`) with our fully-built and ready-to-deploy website.

Nice. So we build this with `nix build .#default`, and we get the contents of
our would-be `public/` dir in a symlink to the Nix store path called `result`.

> **Note:** If you want to run this with symlinked themes in your `themes/` dir
> like me, you need to build `.?submodules=1#default`, not just `.#default`.
> This is because Nix ignores submodules in Flakes for some reason unless you
> explicitly tell it to use them.

```bash
$ ls -lah result
Permissions Size User Date Modified Name
.r--r--r--  3.0k root  1 Jan  1970   404.html
.r--r--r--   65k root  1 Jan  1970   android-chrome-192x192.png
.r--r--r--  336k root  1 Jan  1970   android-chrome-512x512.png
.r--r--r--   59k root  1 Jan  1970   apple-touch-icon.png
dr-xr-xr-x     - root  1 Jan  1970   categories
dr-xr-xr-x     - root  1 Jan  1970   css
.r--r--r--   987 root  1 Jan  1970   favicon-16x16.png
.r--r--r--  3.0k root  1 Jan  1970   favicon-32x32.png
.r--r--r--   15k root  1 Jan  1970   favicon.ico
dr-xr-xr-x     - root  1 Jan  1970   images
.r--r--r--  3.9k root  1 Jan  1970   index.html
.r--r--r--  1.9k root  1 Jan  1970  󰗀 index.xml
dr-xr-xr-x     - root  1 Jan  1970   posts
.r--r--r--   672 root  1 Jan  1970  󰗀 sitemap.xml
dr-xr-xr-x     - root  1 Jan  1970   tags
```

(I'm using [eza](https://eza.rocks) as an `ls` replacement, hence the weird
formatting)

Cool. So now, I can run a Nix build in GitHub actions and zip up the contents
of `public` using their `actions/upload-pages-artifact@v2` action, and deploy
it to Pages like it was any other tool :)

All in all, I'm not sure using Nix for this provides much _raw benefit_ over
just using a normal CD pipeline to do this (i.e. using their template), but it
was fun to set up and simplifies being able to run this on any machine I want
to work on it from.

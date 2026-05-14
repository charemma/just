# just

Reusable [just](https://github.com/casey/just) modules for personal use.

## What's in here

| Module | Purpose |
| --- | --- |
| `obsidian.just` | Find/extract notes from a local Obsidian vault by frontmatter id |
| `web.just` | Fetch URLs with a real-browser TLS fingerprint (curl-impersonate), passes Cloudflare JS challenges |

## How to consume (Nix flake)

Add as a flake input in your project's `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    just-modules = {
      url = "github:charemma/just";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, just-modules, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.just pkgs.curl-impersonate ];
        shellHook = ''
          ln -sfn ${just-modules} ./just-modules
        '';
      };
    };
}
```

Then in your project's `justfile`:

```just
mod obsidian 'just-modules/obsidian.just'
mod web 'just-modules/web.just'
```

Add `just-modules` to `.gitignore` -- the symlink is reproduced by `nix develop` on every host.

## Dependencies

- `web.just` needs `curl-impersonate` on `PATH` (Nix: `pkgs.curl-impersonate`)
- `obsidian.just` assumes notes live under `~/Documents/Notes/1 Projects/Bewerbung Projekt`. Override with `BEWERBUNG_NOTES_ROOT` env var.

## License

MIT

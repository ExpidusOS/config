{
  description = "Config loader";

  nixConfig = rec {
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    substituters = [ "https://cache.nixos.org" "https://cache.garnix.io" ];
    trusted-substituters = substituters;
    fallback = true;
    http2 = false;
  };

  inputs.expidus-sdk.url = github:ExpidusOS/sdk;
  inputs.zig-overlay.url = github:mitchellh/zig-overlay;

  outputs = { self, expidus-sdk, zig-overlay }:
    with expidus-sdk.lib;
    flake-utils.eachSystem flake-utils.allSystems (system:
      let
        pkgs = expidus-sdk.legacyPackages.${system}.appendOverlays [
          zig-overlay.overlays.default
          (final: prev: {
            zig = prev.zigpkgs.master;
          })
        ];
      in rec {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "expidus-config";
          version = "0.1.0-git+${self.shortRev or "dirty"}";

          src = cleanSource self;

          nativeBuildInputs = with pkgs; [ zig ];

          buildPhase = ''
            export HOME=$TMPDIR
            zig build --prefix $out
          '';
        };

        devShells.default = pkgs.mkShell {
          inherit (packages.default) pname version name;

          packages = packages.default.nativeBuildInputs;
        };
      });
}

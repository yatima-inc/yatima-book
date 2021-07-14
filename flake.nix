{
  inputs = {
    utils.url = "github:yatima-inc/nix-utils";
  };

  outputs =
    { self
    , utils
    }:
    utils.inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = utils.nixpkgs.${system};
      name = "yatima-book";
      root = ./.;
      project = pkgs.stdenv.mkDerivation {
        inherit name system;
        src = root;
        buildInputs = with pkgs; [ mdbook ];
        buildPhase = ''
          echo "Building with mdBook"
          mdbook build
        '';
        installPhase = ''
          echo "Copying mdBook output"
          cp -r ./book $out
        '';
      };
    in
    {
      packages.${name} = project;

      defaultPackage = self.packages.${system}.${name};

      # `nix develop`
      devShell = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.packages.${system};
        buildInputs = with pkgs; [
          mdbook
        ];
      };
    });
}

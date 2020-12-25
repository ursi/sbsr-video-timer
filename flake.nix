{
  inputs = {
    elm-install.url = "github:ursi/elm-install";
    node-packages.url = "github:ursi/nix-node-packages";
  };

  outputs = { self, nixpkgs, utils, elm-install, node-packages }:
    utils.mkShell
      ({ pkgs, ... }: with pkgs;
        {
          buildInputs = [
            electron_8
            elmPackages.elm
            node-packages.packages.${system}.elm-git-install
            nodePackages.gulp-cli
            nodePackages.node2nix
            elm-install.defaultPackage.${system}
            nodejs
          ];
        }
      )
      nixpkgs;
}

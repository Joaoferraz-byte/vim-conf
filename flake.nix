{
  description = "NixVim IDE para Java, Spring Boot, Angular e desenvolvimento web";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Sem `follows`: NixVim testa sua própria revisão compatível de nixpkgs.
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      nixvimModule = import ./config;
    in
    {
      lib = {
        nixvimModule = nixvimModule;
        nixvimModules.default = nixvimModule;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit pkgs;
            module = nixvimModule;
            extraSpecialArgs = { inherit self; };
          };
        }
      );

      checks = forAllSystems (system: {
        nixvim = self.packages.${system}.default;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}

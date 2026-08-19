{
  description = "NixVim IDE for Java, Spring Boot, Angular, and web development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
      # The configuration intentionally targets NixOS/Wayland. Filter the
      # NixVim systems by the platform family instead of promising Darwin
      # packages that cannot evaluate Linux-only tools such as wl-clipboard.
      systems = builtins.filter (system: nixpkgs.lib.hasSuffix "-linux" system) (
        builtins.attrNames nixvim.legacyPackages
      );
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

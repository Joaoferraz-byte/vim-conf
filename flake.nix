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

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          nixvim = self.packages.${system}.default;
          java-completion-contract = pkgs.runCommand "livara-java-completion-contract" { } ''
            config=${./config/languages/java.nix}
            grep -Fq 'capabilities = require("cmp_nvim_lsp").default_capabilities()' "$config"
            grep -Fq 'autocmd = false' "$config"
            grep -Fq 'enable = false' "$config"
            grep -Fq 'root_dir = function(bufnr, on_dir)' "$config"
            grep -Fq 'single_file_support = false' "$config"
            general=${./config/languages/general.nix}
            completion=${./config/plugins/completion.nix}
            grep -Fq 'vim.lsp.protocol.make_client_capabilities()' "$general"
            grep -Fq 'completion.autocomplete = [ "TextChanged" "InsertCharPre" ];' "$completion"
            touch "$out"
          '';
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}

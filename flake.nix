{
  description = "NixVim IDE for Java, Spring Boot, Angular, and web development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
            grep -Fq 'capabilities = vim.tbl_deep_extend(' "$config"
            grep -Fq 'require("cmp_nvim_lsp").default_capabilities()' "$config"
            grep -Fq 'autocmd = false' "$config"
            grep -Fq 'enable = false' "$config"
            grep -Fq 'root_dir = function(bufnr, on_dir)' "$config"
            grep -Fq 'single_file_support = false' "$config"
            grep -Fq 'saveActions = { organizeImports = true; };' "$config"
            keymaps=${./config/keymaps.nix}
            grep -Fq 'source.organizeImports' "$keymaps"
            general=${./config/languages/general.nix}
            completion=${./config/plugins/completion.nix}
            ui=${./config/plugins/ui.nix}
            grep -Fq 'vim.lsp.protocol.make_client_capabilities()' "$general"
            grep -Fq 'completion.autocomplete = [ "TextChanged" "InsertCharPre" ];' "$completion"
            grep -Fq 'cmp.get_selected_entry()' "$completion"
            grep -Fq 'cmp.get_entries()' "$completion"
            grep -Fq 'item.menu = string.format' "$completion"
            statusline=${./config/plugins/statusline.nix}
            grep -Fq 'local lsp = lsp_component()' "$statusline"
            grep -Fq '.. " " .. #clients' "$statusline"
            grep -Fq 'ui_select = true;' "$ui"
            touch "$out"
          '';
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}

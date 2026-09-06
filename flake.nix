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
            grep -Fq 'vim.lsp.config("jdtls", {' "$config"
            grep -Fq 'updateBuildConfiguration = "automatic";' "$config"
            grep -Fq 'project = {' "$config"
            grep -Fq 'importOnFirstTimeStartup = "automatic";' "$config"
            grep -Fq 'saveActions = { organizeImports = true; };' "$config"
            keymaps=${./config/keymaps.nix}
            grep -Fq 'source.organizeImports' "$keymaps"
            general=${./config/languages/general.nix}
            completion=${./config/plugins/completion.nix}
            ui=${./config/plugins/ui.nix}
            grep -Fq 'plugins.cmp-nvim-lsp.enable = true;' "$completion"
            grep -Fq 'publish diagnostics' "$ui"
            grep -Fq 'validate documents' "$ui"
            grep -Fq 'vim.lsp.protocol.make_client_capabilities()' "$general"
            grep -Fq 'completion.autocomplete = [ "InsertEnter" "TextChanged" ];' "$completion"
            grep -Fq 'autoEnableSources = true;' "$completion"
            grep -Fq 'cmp.get_selected_entry()' "$completion"
            if grep -Eq 'cmp\.get_entries|item\.menu = string\.format|InsertCharPre' "$completion"; then
              exit 1
            fi
            statusline=${./config/plugins/statusline.nix}
            grep -Fq 'local lsp = lsp_component()' "$statusline"
            grep -Fq '.. " " .. #clients' "$statusline"
            grep -Fq 'ui_select = true;' "$ui"
            ai=${./config/plugins/ai.nix}
            keymaps=${./config/keymaps.nix}
            project_creator=${./lua/project_creator.lua}
            grep -Fq 'plugins.copilot-lua' "$ai"
            grep -Fq 'auto_trigger = false;' "$ai"
            grep -Fq 'livara_copilot_enabled = false' "$ai"
            grep -Fq 'plugins.copilot-chat' "$ai"
            grep -Fq 'should_attach.__raw' "$ai"
            grep -Fq 'key = "<leader>at";' "$keymaps"
            grep -Fq 'key = "<leader>ac";' "$keymaps"
            grep -Fq 'key = "<leader>ar";' "$keymaps"
            grep -Fq 'group = "AI"' "$ui"
            grep -Fq 'Choose an option to continue' "$project_creator"
            grep -Fq 'Create project · ' "$project_creator"
            touch "$out"
          '';
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}

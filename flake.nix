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
            grep -Fq 'jdtlsRoot' "$config"
            grep -Fq 'jdtlsRuntime' "$config"
            grep -Fq 'lombokJar' "$config"
            grep -Fq 'javaTestExtension' "$config"
            grep -Fq 'javaDebugExtension' "$config"
            grep -Fq 'spring_boot_tools = {' "$config"
            grep -Fq 'auto_install = false' "$config"
            grep -Fq 'enable = false' "$config"
            grep -Fq 'vim.lsp.config("jdtls", {' "$config"
            grep -Fq 'updateBuildConfiguration = "automatic";' "$config"
            grep -Fq 'project = {' "$config"
            grep -Fq 'importOnFirstTimeStartup = "automatic";' "$config"
            grep -Fq 'enabled = true;' "$config"
            grep -Fq 'lazyResolveTextEdit = {' "$config"
            if grep -Fq 'importOnCompletion' "$config"; then
              exit 1
            fi
            grep -Fq 'saveActions = { organizeImports = true; };' "$config"
            keymaps=${./config/keymaps.nix}
            grep -Fq 'source.organizeImports' "$keymaps"
            grep -Fq 'source.generate.accessors' "$keymaps"
            grep -Fq 'source.generate.constructors' "$keymaps"
            grep -Fq 'source.generate.toString' "$keymaps"
            grep -Fq 'source.generate.hashCodeEquals' "$keymaps"
            general=${./config/languages/general.nix}
            completion=${./config/plugins/completion.nix}
            ui=${./config/plugins/ui.nix}
            grep -Fq 'plugins.cmp-nvim-lsp.enable = true;' "$completion"
            grep -Fq 'completion.autocomplete' "$completion"
            grep -Fq "require('cmp.types').cmp.TriggerEvent.TextChanged" "$completion"
            if grep -Eq 'livara_cmp_auto_completion|vim.defer_fn|cmp_auto_delay_ms|cmp.complete\(' "$completion"; then
              exit 1
            fi
            grep -Fq 'luasnip.add_snippets("java"' "$completion"
            grep -Fq 'snippet("psvm"' "$completion"
            grep -Fq 'main(String[] args) {{\n\t{}\n}}' "$completion"
            if grep -Fq 'main(String[] args) {\n\t{}\n}' "$completion"; then
              exit 1
            fi
            grep -Fq 'snippet("sout"' "$completion"
            grep -Fq 'snippet("sysout"' "$completion"
            if grep -Eq 'S-Right|S-Left' "$completion"; then
              exit 1
            fi
            grep -Fq 'publish diagnostics' "$ui"
            grep -Fq 'validate documents' "$ui"
            grep -Fq 'vim.lsp.protocol.make_client_capabilities()' "$general"
            grep -Fq 'autoEnableSources = true;' "$completion"
            grep -Fq 'cmp.select_next_item' "$completion"
            grep -Fq 'vim.api.nvim_buf_call(buf' "$completion"
            grep -Fq 'vim.api.nvim_exec_autocmds("InsertEnter"' "$completion"
            grep -Fq 'group = "cmp_nvim_lsp"' "$completion"
            grep -Fq 'buf = buf,' "$completion"
            grep -Fq 'additional_text_edits' "$completion"
            grep -Fq '"LspAttach", "LspDetach"' "$completion"
            if grep -Eq 'client_source_map|_on_insert_enter|cmp\.unregister_source|cmp\.get_entries|item\.menu = string\.format|InsertCharPre|BufEnter' "$completion"; then
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
            grep -Fq 'local function create_project' "$project_creator"
            grep -Fq 'Create project · language' "$project_creator"
            touch "$out"
          '';
          luasnip-fmt-contract = pkgs.runCommand "livara-luasnip-fmt-contract" {
            nativeBuildInputs = [ pkgs.neovim ];
          } ''
            export HOME="$TMPDIR"
            nvim --headless -u NONE --cmd "set rtp^=${pkgs.vimPlugins.luasnip}" -l ${./tests/luasnip_fmt_spec.lua}
            touch "$out"
          '';
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}

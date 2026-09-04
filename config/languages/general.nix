{ pkgs, ... }:
{
  plugins.lsp = {
    enable = true;
    # nvim-cmp adds snippet and completion-item capabilities that must be
    # advertised before every server configuration is materialized.
    capabilities = ''
      capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )
    '';
    servers = {
      nil_ls = {
        enable = true;
        settings.nil.formatting.command = [ "nixfmt" ];
      };
      lua_ls = {
        enable = true;
        settings.Lua = {
          diagnostics.globals = [ "vim" ];
          workspace.checkThirdParty = false;
          telemetry.enable = false;
        };
      };
      bashls = {
        enable = true;
        settings.bashIde.shellcheckPath = "shellcheck";
      };
      dockerls.enable = true;
      clangd.enable = true;
      pyright = {
        enable = true;
        settings.python.analysis = {
          autoSearchPaths = true;
          diagnosticMode = "workspace";
          typeCheckingMode = "basic";
          useLibraryCodeForTypes = true;
        };
      };
      marksman.enable = true;
    };
  };
  # Companion CLIs used by the language servers live in the same declarative
  # environment instead of being silently expected from the host.
  extraPackages = with pkgs; [
    shellcheck
  ];
}

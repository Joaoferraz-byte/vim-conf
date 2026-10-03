{ config, pkgs, ... }:
{
  plugins.treesitter = {
    enable = true;
    grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
      lua nix bash c cpp cmake python java javascript typescript tsx
      html css json yaml toml markdown markdown_inline xml php rust ron
      asm
    ];
    settings = {
      highlight.enable = true;
      indent.enable = true;
      incremental_selection.enable = true;
    };
  };

  plugins.conform-nvim = {
    enable = true;
    autoInstall.enable = false;
    settings = {
      formatters_by_ft = {
        c = [ "clang-format" ];
        cpp = [ "clang-format" ];
        python = [ "ruff_format" ];
        rust = [ "rustfmt" ];
        javascript = [ "prettier" ];
        javascriptreact = [ "prettier" ];
        typescript = [ "prettier" ];
        typescriptreact = [ "prettier" ];
        php = [ "php_cs_fixer" ];
        nix = [ "nixfmt" ];
        lua = [ "stylua" ];
        sh = [ "shfmt" ];
      };
      format_on_save = {
        timeout_ms = 2500;
        lsp_format = "fallback";
      };
      notify_on_error = true;
    };
  };

  plugins.neotest.enable = true;

  extraPackages = with pkgs; [
    clang-tools
    nixfmt
    rustfmt
    stylua
    shfmt
    ruff
    prettier
  ];
}

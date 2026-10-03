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

  # Project .clang-format files remain authoritative. When a project has no
  # style file, use the same policy as the editor: two spaces, spaces only,
  # and case labels indented inside switch blocks.
  extraConfigLua = ''
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.formatters["clang-format"] = {
        prepend_args = {
          "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 2, TabWidth: 2, UseTab: Never, IndentCaseLabels: true}",
        },
      }
    end
  '';

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

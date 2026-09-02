{ pkgs, ... }:
{
  plugins.conform-nvim = {
    enable = true;
    autoInstall.enable = false;
    settings = {
      formatters_by_ft = {
        # Java formatting falls back to JDTLS. Google Java Format also normalizes
        # imports, which can remove a manually added import before its symbol is used.
        c = [ "clang-format" ];
        cpp = [ "clang-format" ];
        javascript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        javascriptreact = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        typescript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        typescriptreact = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        html = [ "prettierd" ];
        css = [ "prettierd" ];
        scss = [ "prettierd" ];
        json = [ "prettierd" ];
        yaml = [ "prettierd" ];
        markdown = [ "prettierd" ];
        python = [ "ruff_format" ];
        nix = [ "nixfmt" ];
        lua = [ "stylua" ];
        sh = [ "shfmt" ];
      };
      format_on_save = {
        timeout_ms = 2500;
        lsp_format = "fallback";
      };
      notify_on_error = true;
      notify_no_formatters = false;
    };
  };

  extraPackages = with pkgs; [
    clang-tools
    prettierd
    prettier
    nixfmt
    stylua
    shfmt
    ruff
  ];
}

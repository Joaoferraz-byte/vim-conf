{ pkgs, ... }:
{
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "c", "cpp" },
      callback = function(args)
        vim.bo[args.buf].autoindent = true
        vim.bo[args.buf].smartindent = false
        vim.bo[args.buf].cindent = true
        vim.bo[args.buf].indentexpr = ""
        vim.bo[args.buf].cinoptions = ":1,=s"
      end,
    })
  '';

  plugins.conform-nvim = {
    enable = true;
    autoInstall.enable = false;
    settings = {
      formatters_by_ft = {
        java = { lsp_format = "never"; };
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
      formatters.clang_format = {
        append_args = [ "--style={BasedOnStyle: LLVM, IndentCaseLabels: true}" ];
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

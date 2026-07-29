{ ... }:
{
  plugins = {
    luasnip.enable = true;

    lspkind = {
      enable = true;
      cmp.enable = true;
    };

    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        completion.completeopt = "menu,menuone,noselect";
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        };
      };
    };
  };
}

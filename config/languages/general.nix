{ ... }:
{
  plugins.lsp = {
    enable = true;
    servers = {
      nil_ls.enable = true;
      lua_ls.enable = true;
      bashls.enable = true;
      dockerls.enable = true;
      clangd.enable = true;
      pyright.enable = true;
      marksman.enable = true;
    };
  };
}

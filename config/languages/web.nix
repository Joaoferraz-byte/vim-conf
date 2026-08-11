{ ... }:
{
  plugins.lsp = {
    enable = true;
    servers = {
      angularls.enable = true;
      ts_ls.enable = true;
      eslint.enable = true;
      html.enable = true;
      cssls.enable = true;
      jsonls.enable = true;
      yamlls.enable = true;
      emmet_language_server.enable = true;
      tailwindcss.enable = true;
    };
  };
}

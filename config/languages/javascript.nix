{ pkgs, ... }:
{
  plugins.lsp.servers.ts_ls = {
    enable = true;
    filetypes = [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
    rootMarkers = [ "package.json" "tsconfig.json" "jsconfig.json" "pnpm-workspace.yaml" "nx.json" "turbo.json" ".git" ];
  };
  plugins.lsp.servers.eslint.enable = true;

  extraPackages = with pkgs; [ nodejs pnpm typescript typescript-language-server prettier ];
}

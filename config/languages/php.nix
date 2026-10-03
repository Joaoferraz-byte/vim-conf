{ pkgs, ... }:
{
  plugins.lsp.servers.phpactor = {
    enable = true;
    filetypes = [ "php" ];
    rootMarkers = [ "composer.json" ".phpactor.json" ".phpactor.yml" ".git" ];
    extraOptions.workspace_required = true;
  };

  extraPackages = with pkgs; [ php phpPackages.composer phpPackages.php-cs-fixer ];
}

{
  plugins.lsp = {
    enable = true;
    servers = {
      # Angular is root-scoped so template completion is available in Angular/Nx
      # workspaces without attaching the service to unrelated HTML projects.
      ts_ls.enable = true;
      angularls = {
        enable = true;
        filetypes = [ "typescript" "html" "typescriptreact" "htmlangular" ];
        rootMarkers = [ "angular.json" "project.json" "nx.json" ];
      };
      eslint.enable = true;
      html.enable = true;
      cssls.enable = true;
      jsonls.enable = true;
      yamlls.enable = true;
      emmet_language_server = {
        enable = true;
        filetypes = [
          "html"
          "php"
          "css"
          "scss"
          "javascriptreact"
          "typescriptreact"
          "vue"
          "svelte"
        ];
        extraOptions = {
          init_options = {
            includeLanguages = { php = "html"; };
            showAbbreviationSuggestions = true;
            showExpandedAbbreviation = "always";
            showSuggestionsAsSnippets = true;
          };
        };
      };
      tailwindcss.enable = true;
    };
  };
}

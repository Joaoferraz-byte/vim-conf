{
  plugins.lsp = {
    enable = true;
    servers = {
      # Angular language service is intentionally not enabled globally: its
      # default filetypes overlap plain HTML and compete with html-language-server
      # for nvim-navic. Angular projects can opt in locally with :LspStart angularls.
      ts_ls.enable = true;
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

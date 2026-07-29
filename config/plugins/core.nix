{ config, pkgs, ... }:
{
  plugins = {
    web-devicons.enable = true;
    gitsigns.enable = true;
    comment.enable = true;
    todo-comments.enable = true;
    leap.enable = true;
    undotree.enable = true;
    which-key.enable = true;
    nvim-autopairs.enable = true;
    illuminate.enable = true;
    trouble.enable = true;

    treesitter = {
      enable = true;
      nixGrammars = true;
      grammarPackages =
        let
          grammars = config.plugins.treesitter.package;
          wanted = [
            "bash"
            "c"
            "css"
            "dockerfile"
            "html"
            "java"
            "javascript"
            "jsdoc"
            "json"
            "jsonc"
            "lua"
            "markdown"
            "markdown_inline"
            "nix"
            "python"
            "regex"
            "scss"
            "sql"
            "tsx"
            "typescript"
            "vim"
            "vimdoc"
            "xml"
            "yaml"
          ];
        in
        map (name: grammars.${name}) (builtins.filter (name: builtins.hasAttr name grammars) wanted);
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };
  };

  # Ferramentas que precisam estar no PATH do wrapper do Neovim.
  extraPackages = with pkgs; [
    git
    ripgrep
    fd
    gnumake
    nodejs
    jdk21
    maven
    gradle
  ];
}

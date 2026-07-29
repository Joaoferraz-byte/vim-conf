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

    # ─── Aerial (outline / symbol tree) ───
    aerial = {
      enable = true;
      settings = {
        layout = {
          default_direction = "right";
          resize_to_content = true;
        };
        attach_mode = "global";
        backends = [ "lsp" "treesitter" "markdown" "man" ];
        show_guides = true;
        filter_kind = true;
      };
    };

    # ─── Harpoon (acesso rápido a arquivos) ───
    harpoon = {
      enable = true;
      enableTelescope = true;
      settings = {
        settings = {
          save_on_toggle = true;
          sync_on_ui_close = true;
        };
      };
    };

    # ─── Project.nvim (gestão de projetos) ───
    project-nvim = {
      enable = true;
      enableTelescope = true;
      settings = {
        manual_mode = false;
        detection_methods = [ "pattern" "lsp" ];
        patterns = [ ".git" "_darcs" ".hg" ".bzr" ".svn" "Makefile" "package.json" "pom.xml" "build.gradle" "build.gradle.kts" ];
        show_hidden = false;
        silent_chdir = true;
        scope_chdir = "global";
        datapath.__raw = "vim.fn.stdpath(\"data\")";
      };
    };

    # ─── Flash (navegação rápida com rótulos) ───
    flash.enable = true;

    # ─── TS Autotag (auto close/rename HTML tags) ───
    ts-autotag.enable = true;

    # ─── Zen Mode (edição sem distrações) ───
    zen-mode = {
      enable = true;
    };

    # ─── Smart Splits (gerenciamento de splits) ───
    smart-splits = {
      enable = true;
      settings = {
        resize_mode = {
          quit_key = "<ESC>";
          resize_keys = [ "h" "j" "k" "l" ];
          silent = true;
        };
      };
    };

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
    chafa
  ];
}

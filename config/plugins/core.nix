{ config, pkgs, ... }:
{
  plugins = {
    web-devicons.enable = true;
    gitsigns.enable = true;
    comment.enable = true;
    todo-comments.enable = true;
    undotree.enable = true;
    which-key.enable = true;
    nvim-autopairs.enable = true;
    illuminate.enable = true;
    trouble.enable = true;

    # ─── Flash (Navegação moderna) ───
    flash.enable = true;

    # ─── Aerial (Outline) ───
    aerial = {
      enable = true;
      settings = {
        backends = [ "lsp" "treesitter" "markdown" ];
        show_guides = true;
      };
    };

    # ─── Harpoon ───
    harpoon = {
      enable = true;
      enableTelescope = true;
      settings.settings = {
        save_on_toggle = true;
      };
    };

    # ─── Project.nvim ───
    project-nvim = {
      enable = true;
      enableTelescope = true;
    };

    # ─── TS Autotag ───
    ts-autotag.enable = true;

    # ─── Zen Mode ───
    zen-mode.enable = true;

    # ─── Smart Splits ───
    smart-splits.enable = true;

    # ─── Treesitter ───
    treesitter = {
      enable = true;
      nixGrammars = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    # ─── Telescope ───
    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };
  };

  extraPackages = with pkgs; [
    git ripgrep fd gnumake nodejs jdk21 maven gradle chafa
  ];
}

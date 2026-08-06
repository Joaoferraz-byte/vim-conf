{ config, pkgs, lib, ... }:
let
  base46-plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "base46";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "AvengeMedia";
      repo = "base46";
      rev = "83522e02c6c3b4ea901c4bffd9e0a5e0371c1fe6";
      hash = "sha256-kwDMC6rYzJYECmGnwn8JiAbffUq7hAXcUH6gPSkk2uI=";
    };
    doCheck = false;
  };
in
{
  plugins = {
    web-devicons.enable = true;
    gitsigns.enable = true;
    neogit.enable = true;
    diffview.enable = true;
    comment.enable = true;
    todo-comments.enable = true;
    undotree.enable = true;
    which-key.enable = true;
    nvim-autopairs.enable = true;
    illuminate = {
      enable = true;
      settings = {
        filetypes_denylist = [ "dashboard" "alpha" "NvimTree" "help" ];
      };
    };
    trouble.enable = true;

    # Flash
    flash.enable = true;

    # Aerial
    aerial = {
      enable = true;
      settings = {
        backends = [ "lsp" "treesitter" "markdown" ];
        show_guides = true;
      };
    };

    # Harpoon
    harpoon = {
      enable = true;
      enableTelescope = true;
      settings.settings = {
        save_on_toggle = true;
      };
    };

    # Project.nvim
    project-nvim = {
      enable = true;
      enableTelescope = true;
      settings = {
        datapath.__raw = ''vim.fn.stdpath("data") .. "/project_nvim"'';
      };
    };

    # TS Autotag
    ts-autotag.enable = true;

    # Zen Mode
    zen-mode.enable = true;

    # Smart Splits
    smart-splits.enable = true;

    # Oil
    oil.enable = true;

    # Treesitter
    treesitter = {
      enable = true;
      nixGrammars = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    # Telescope
    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
      extensions.file-browser.enable = true;
    };
  };

  extraPlugins = [ base46-plugin ];

  extraPackages = with pkgs; [
    git ripgrep fd gnumake nodejs jdk21 maven gradle chafa
  ];

  extraConfigLua = ''
    -- DMS base46 theme initialization
    pcall(function()
      local base46 = require("base46")
      -- Habilita transparência nativa do base46 se suportado
      base46.load_theme("dms")
    end)
  '';
}

{ config, pkgs, ... }:
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
        # Disable illuminate on dashboard to prevent word highlights on startup
        filetypes_denylist = [ "dashboard" "alpha" "NvimTree" "help" ];
      };
    };
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
      settings = {
        # Enable manual mode to avoid automatic project detection on dashboard
        manual_mode = true;
        # Store history in a safe path
        datapath = "$HOME/.local/share/nvim/project_nvim";
      };
    };

    # ─── TS Autotag ───
    ts-autotag.enable = true;

    # ─── Zen Mode ───
    zen-mode.enable = true;

    # ─── Smart Splits ───
    smart-splits.enable = true;

    # ─── Oil (File explorer moderno) ───
    oil.enable = true;

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
      extensions.file-browser.enable = true;
    };
  };

  extraPackages = with pkgs; [
    git ripgrep fd gnumake nodejs jdk21 maven gradle chafa
  ];

  # Fix project.nvim corrupted history.json on startup
  extraConfigLua = ''
    -- Handle corrupted project.nvim history.json
    local history_path = vim.fn.stdpath("data") .. "/project_nvim/history.json"
    if vim.fn.filereadable(history_path) == 1 then
      local ok, data = pcall(vim.fn.json_decode, vim.fn.readfile(history_path))
      if not ok or type(data) ~= "table" then
        vim.fn.delete(history_path)
        vim.notify("project.nvim: corrupted history cleared", vim.log.levels.WARN)
      end
    end
  '';
}

{ pkgs, ... }:
{
  plugins = {
    # ─── Snacks.nvim (utilitários modernos) ───
    snacks = {
      enable = true;
      settings = {
        bigfile.enabled = true;
        notifier.enabled = true;
        quickfile.enabled = true;
        statuscolumn.enabled = true;
        words.enabled = true;
        indent.enabled = true;
        input.enabled = true;
        scope.enabled = true;
        scroll.enabled = true;
      };
    };

    # ─── Dashboard-nvim (Start Screen robusto e nativo) ───
    dashboard = {
      enable = true;
      settings = {
        theme = "hyper";
        config = {
          header = [
            "██╗     ██╗██╗   ██╗ █████╗ ██████╗  █████╗ "
            "██║     ██║██║   ██║██╔══██╗██╔══██╗██╔══██╗"
            "██║     ██║██║   ██║███████║██████╔╝███████║"
            "██║     ██║╚██╗ ██╔╝██╔══██║██╔══██╗██╔══██║"
            "███████╗██║ ╚████╔╝ ██║  ██║██║  ██║██║  ██║"
            "╚══════╝╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
            "                                            "
          ];
          shortcut = [
            {
              desc = "  Find File";
              group = "@variable";
              action = "Telescope find_files";
              key = "f";
            }
            {
              desc = "  New File";
              group = "@variable";
              action = "ene | startinsert";
              key = "n";
            }
            {
              desc = "  Find Text";
              group = "@variable";
              action = "Telescope live_grep";
              key = "g";
            }
            {
              desc = "  Recent Files";
              group = "@variable";
              action = "Telescope oldfiles";
              key = "r";
            }
            {
              desc = "  Config";
              group = "@variable";
              action = "Telescope find_files cwd=~/.config/nvim";
              key = "c";
            }
            {
              desc = "  Quit";
              group = "@variable";
              action = "qa";
              key = "q";
            }
          ];
          project = {
            enable = true;
            action = "Telescope projects";
          };
          mru = {
            limit = 10;
          };
        };
      };
    };

    # ─── Nvim-Tree (Explorador estável) ───
    nvim-tree = {
      enable = true;
      openOnSetup = false;
      filters.dotfiles = false;
    };

    # ─── Noice.nvim (UI moderna) ───
    noice = {
      enable = true;
    };

    # ─── Barbecue (breadcrumbs) ───
    barbecue = {
      enable = true;
      settings = {
        attach_navic = true;
        create_autocmd = true;
        winbar.enabled = true;
      };
    };

    # ─── Treesitter Context ───
    treesitter-context = {
      enable = true;
      settings = {
        max_lines = 3;
        separator = "-";
      };
    };

    # ─── Indent Blankline ───
    indent-blankline = {
      enable = true;
      settings = {
        indent.char = "│";
        scope.enabled = true;
        exclude = {
          filetypes = [
            "dashboard"
            "alpha"
            "nixvim"
            "NvimTree"
            "Trouble"
            "toggleterm"
            "help"
          ];
        };
      };
    };

    # ─── Fidget ───
    fidget.enable = true;

    # ─── Outros ───
    bufferline.enable = true;
    lualine = {
      enable = true;
      settings.options = {
        theme = "auto";
        globalstatus = true;
      };
    };
    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        open_mapping = "[[<c-\\>]]";
        float_opts.border = "curved";
      };
    };
  };

  # Desabilitar guias de indentação do Snacks no Dashboard via Autocmd
  autoCmd = [
    {
      event = "FileType";
      pattern = "dashboard";
      command = "lua require('snacks').indent.disable()";
    }
  ];
}

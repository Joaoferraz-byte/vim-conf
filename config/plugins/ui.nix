{ ... }:
{
  plugins = {
    # ─── Snacks.nvim (substitui nvim-tree, adiciona dashboard, statuscolumn, picker) ───
    snacks = {
      enable = true;
      settings = {
        bigfile = {
          enabled = true;
          notify = true;
        };

        dashboard = {
          enabled = true;
          width = 60;
          pane_gap = 4;
          preset = {
            header = ''
              ⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⠶⢶⡶⠶⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀
              ⠀⠀⠀⠀⢀⣤⣾⣿⣿⣿⣿⠀⡸⢇⠀⣿⣿⣿⣿⣷⣤⡀⠀⠀⠀⠀
              ⠀⠀⠀⣴⢏⡉⠻⢿⣿⣿⣿⠤⠧⠼⠤⣿⣿⣿⣿⠟⢩⠿⣦⠀⠀⠀
              ⠀⢀⣾⣅⠘⢡⠆⡴⠛⢉⣠⣤⣶⠀⠀⠀⠉⠛⢯⣠⠔⠠⠚⣷⡀⠀
              ⠀⣾⣿⣿⣷⣦⡞⢀⣴⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⢻⣤⣶⣿⣿⣷⠀
              ⢠⣿⣿⣿⣿⡟⠀⣾⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⡄
              ⢸⣿⣿⣿⣿⡇⠘⠛⠛⠛⠛⠛⠛⣤⣤⣤⣤⣤⣤⡄⢸⣿⣿⣿⣿⡇
              ⠘⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⡿⠀⣼⣿⣿⣿⣿⠃
              ⠀⢿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠟⠁⣼⣿⣿⣿⣿⡿⠀
              ⠀⠈⢿⣿⣿⣿⣿⣷⣤⣀⠀⠀⠀⠿⠛⠋⣁⣤⣾⣿⣿⣿⣿⡿⠁⠀
              ⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀
              ⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⠁⠀⠀⠀⠀
              ⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠿⠿⠿⠿⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀'';
            keys = [
              {
                icon = " ";
                key = "f";
                desc = "Find File";
                action = ":lua Snacks.dashboard.pick('files')";
              }
              {
                icon = " ";
                key = "n";
                desc = "New File";
                action = ":ene | startinsert";
              }
              {
                icon = " ";
                key = "g";
                desc = "Find Text";
                action = ":lua Snacks.dashboard.pick('live_grep')";
              }
              {
                icon = " ";
                key = "r";
                desc = "Recent Files";
                action = ":lua Snacks.dashboard.pick('oldfiles')";
              }
              {
                icon = " ";
                key = "c";
                desc = "Config";
                action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})";
              }
              {
                icon = " ";
                key = "s";
                desc = "Restore Session";
                section = "session";
              }
              {
                icon = "󰒲 ";
                key = "L";
                desc = "Lazy";
                action = ":Lazy";
              }
              {
                icon = " ";
                key = "q";
                desc = "Quit";
                action = ":qa";
              }
            ];
          };
          sections = [
            { section = "header"; }
            { section = "keys"; gap = 1; padding = 1; }
            {
              pane = 2;
              icon = " ";
              desc = "Browse Repo";
              padding = 1;
              key = "b";
              action.__raw = "function() Snacks.gitbrowse() end";
            }
            {
              pane = 2;
              icon = " ";
              title = "Projects";
              section = "projects";
              indent = 2;
              padding = 2;
            }
            {
              pane = 2;
              icon = " ";
              title = "Recent Files";
              section = "recent_files";
              indent = 2;
              padding = 1;
            }
            {
              pane = 2;
              icon = " ";
              title = "Git Status";
              section = "terminal";
              enabled.__raw = "function() return Snacks.git.get_root() ~= nil end";
              cmd = "git --no-pager diff --stat -B -M -C";
              height = 10;
              padding = 1;
              ttl = "5 * 60";
              indent = 3;
            }
            { section = "startup"; }
          ];
        };

        explorer = {
          enabled = true;
          replace = {
            netrw = true;
          };
        };

        indent = {
          enabled = true;
        };

        input = {
          enabled = true;
        };

        picker = {
          enabled = true;
        };

        quickfile = {
          enabled = true;
        };

        scope = {
          enabled = true;
        };

        statuscolumn = {
          enabled = true;
        };

        words = {
          enabled = true;
          debounce = 100;
        };
      };
    };

    # ─── Noice.nvim (UI moderna para comandos, cmdline, etc.) ───
    noice = {
      enable = true;
    };

    # ─── Barbecue (breadcrumbs / path navigation) ───
    barbecue = {
      enable = true;
      settings = {
        attach_navic = true;
        create_autocmd = true;
        dim_dirname = true;
        dirname_padding = 1;
        winbar = { enabled = true; };
      };
    };

    # ─── Treesitter Context (mostra contexto do código no topo) ───
    treesitter-context = {
      enable = true;
      settings = {
        enable = true;
        max_lines = 3;
        min_window_height = 0;
        line_numbers = true;
        multiline_threshold = 20;
        trim_scope = "outer";
        mode = "cursor";
        separator = "-";
      };
    };

    # ─── Indent Blankline (guias de indentação visuais) ───
    indent-blankline = {
      enable = true;
      settings = {
        indent = {
          char = "│";
        };
        scope = {
          enabled = false; # snacks indent cuida disso
        };
      };
    };

    # ─── Fidget (indicador de progresso LSP) ───
    fidget = {
      enable = true;
      settings = {
        notification = {
          window = {
            winblend = 0;
            border = "rounded";
          };
        };
        progress = {
          display = {
            render_limit = 5;
          };
        };
      };
    };

    # ─── Bufferline (continua como está) ───
    bufferline.enable = true;

    # ─── Lualine (statusline moderna) ───
    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "auto";
          globalstatus = true;
          component_separators = "";
          section_separators = "";
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "branch" "diff" "diagnostics" ];
          lualine_c = [ "filename" ];
          lualine_x = [ "encoding" "fileformat" "filetype" ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };

    # ─── Toggleterm (terminal flutuante) ───
    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        open_mapping = "[[<c-\\>]]";
        shade_terminals = true;
        start_in_insert = true;
        persist_size = true;
        close_on_exit = true;
        float_opts = {
          border = "curved";
          winblend = 0;
        };
      };
    };
  };
}

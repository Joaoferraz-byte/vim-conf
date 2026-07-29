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
        theme = "doom";
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
          center = [
            {
              icon = "  ";
              desc = "Find File";
              action = "Telescope find_files";
              key = "f";
            }
            {
              icon = "  ";
              desc = "New File (Advanced)";
              action = "lua _G.advanced_new_file()";
              key = "n";
            }
            {
              icon = "  ";
              desc = "Find Text";
              action = "Telescope live_grep";
              key = "g";
            }
            {
              icon = "  ";
              desc = "Projects";
              action = "Telescope projects";
              key = "p";
            }
            {
              icon = "  ";
              desc = "Config";
              action = "NvimTreeOpen ~/.config/nvim";
              key = "c";
            }
            {
              icon = "  ";
              desc = "Quit";
              action = "qa";
              key = "q";
            }
          ];
          footer = [ "" ];
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

  # Configurações extras de UI e funções customizadas
  extraConfigLua = ''
    -- Função avançada para criar novos arquivos com seleção de pasta
    _G.advanced_new_file = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local fb = telescope.extensions.file_browser

      fb.file_browser({
        path = vim.fn.getcwd(),
        cwd = vim.fn.getcwd(),
        respect_gitignore = false,
        hidden = true,
        grouped = true,
        initial_mode = "normal",
        prompt_title = "Selecionar Pasta (Enter para escolher)",
        attach_mappings = function(prompt_bufnr, map)
          local create_file = function()
            local selection = action_state.get_selected_entry()
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            local dir = current_picker.cwd

            if selection then
              if selection.is_dir then
                dir = selection.path
              else
                dir = vim.fn.fnamemodify(selection.path, ":h")
              end
            end

            actions.close(prompt_bufnr)

            vim.ui.input({ prompt = "Nome do novo arquivo: " }, function(input)
              if input and input ~= "" then
                local path = dir .. "/" .. input
                vim.cmd("edit " .. path)
                vim.cmd("write")
              end
            end)
          end

          map("n", "<CR>", create_file)
          map("i", "<CR>", create_file)
          return true
        end,
      })
    end
  '';

  # Desabilitar guias de indentação do Snacks no Dashboard via Autocmd
  autoCmd = [
    {
      event = "FileType";
      pattern = "dashboard";
      command = "lua require('snacks').indent.disable()";
    }
  ];
}

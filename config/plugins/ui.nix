{ ... }:
{
  plugins = {
    # Snacks.nvim
    snacks = {
      enable = true;
      settings = {
        bigfile.enabled = true;
        notifier.enabled = true;
        quickfile.enabled = true;
        statuscolumn.enabled = true;
        words.enabled = false;
        indent.enabled = true;
        input.enabled = true;
        scope.enabled = true;
        scroll.enabled = true;
      };
    };

    # Dashboard-nvim
    dashboard = {
      enable = true;
      settings = {
        theme = "doom";
        hide = {
          statusline = true;
          tabline = true;
        };
        config = {
          header = [
            ""
            ""
            ""
            ""
            "██╗     ██╗██╗   ██╗ █████╗ ██████╗  █████╗ "
            "██║     ██║██║   ██║██╔══██╗██╔══██╗██╔══██╗"
            "██║     ██║██║   ██║███████║██████╔╝███████║"
            "██║     ██║╚██╗ ██╔╝██╔══██║██╔══██╗██╔══██║"
            "███████╗██║ ╚████╔╝ ██║  ██║██║  ██║██║  ██║"
            "╚══════╝╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
            ""
            ""
          ];
          center = [
            {
              icon = " ";
              desc = "Find File";
              action = "Telescope find_files";
              key = "f";
              key_format = " %s";
            }
            {
              icon = " ";
              desc = "New File";
              action = "lua _G.advanced_new_file()";
              key = "n";
              key_format = " %s";
            }
            {
              icon = " ";
              desc = "Spring Boot";
              action = "lua _G.spring_boot_wizard()";
              key = "s";
              key_format = " %s";
            }
            {
              icon = " ";
              desc = "Find Text";
              action = "Telescope live_grep";
              key = "g";
              key_format = " %s";
            }
            {
              icon = "󰌢 ";
              desc = "Projects";
              action = "Telescope projects";
              key = "p";
              key_format = " %s";
            }
            {
              icon = " ";
              desc = "Config";
              action = "NvimTreeOpen ~/.config/nvim";
              key = "c";
              key_format = " %s";
            }
            {
              icon = "󰋜 ";
              desc = "Browse All Keymaps";
              action = "lua require('which-key').show({ global = true })";
              key = "?";
              key_format = " %s";
            }
            {
              icon = " ";
              desc = "Quit";
              action = "qa";
              key = "q";
              key_format = " %s";
            }
          ];
          footer.__raw = ''
            function()
              local stats = #vim.tbl_keys(package.loaded)
              local ver = vim.version()
              return {
                "",
                string.format(
                  "nvim v%d.%d.%d  •  %d módulos Lua carregados  •  %s",
                  ver.major, ver.minor, ver.patch,
                  stats,
                  os.date("%d/%m/%Y")
                ),
              }
            end
          '';
        };
      };
    };

    # Which-Key
    which-key = {
      enable = true;
      settings = {
        delay = 250;
        preset = "modern";
        show_help = true;
        show_keys = true;
        layout = {
          spacing = 6;
          align = "center";
        };
        win = {
          border = "rounded";
          title = true;
          title_pos = "center";
          padding = [
            1
            2
          ];
        };
        spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "Files";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "Configuration";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>l";
            group = "Language";
            icon = "󰘦 ";
          }
          {
            __unkeyed-1 = "<leader>n";
            group = "New";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>h";
            group = "Harpoon";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>d";
            desc = "Open Dashboard";
            icon = "󰋜 ";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "Debug";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Test";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>?";
            desc = "Browse All Keymaps";
            icon = "󰘦 ";
          }
          {
            __unkeyed-1 = "<leader><leader>";
            desc = "Show Leader Keymaps";
            icon = "󰋜 ";
          }
        ];
      };
    };

    # Mini
    mini = {
      enable = true;
      modules = {
        animate = {
          cursor.enable = false;
          scroll.enable = false;
          resize.enable = true;
          open.enable = true;
          close.enable = true;
        };
      };
    };

    # Nvim-Tree
    nvim-tree = {
      enable = true;
      openOnSetup = false;
      settings.filters.dotfiles = false;
    };

    # Noice
    noice = {
      enable = true;
      settings.presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
        lsp_doc_border = true;
      };
    };

    barbecue.enable = true;
    treesitter-context.enable = true;
    fidget.enable = true;
    bufferline.enable = true;

    lualine = {
      enable = true;
      settings.options = {
        theme = "auto";
        globalstatus = true;
      };
    };

    indent-blankline = {
      enable = true;
      settings = {
        indent.char = "│";
        exclude.filetypes = [
          "dashboard"
          "alpha"
          "NvimTree"
          "toggleterm"
          "help"
        ];
      };
    };
  };

  extraConfigLua = ''
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
            local dir = action_state.get_current_picker(prompt_bufnr).cwd
            if selection then
              dir = selection.is_dir and selection.path or vim.fn.fnamemodify(selection.path, ":h")
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

    _G.spring_boot_wizard = function()
      local java_versions = { "17", "21" }
      local boot_versions = { "3.2.0", "3.3.0" }
      vim.ui.select(java_versions, { prompt = "Versão do Java:" }, function(java_v)
        if not java_v then return end
        vim.ui.select(boot_versions, { prompt = "Versão do Spring Boot:" }, function(boot_v)
          if not boot_v then return end
          vim.ui.input({ prompt = "Group ID (ex: com.example): ", default = "com.example" }, function(group)
            if not group then return end
            vim.ui.input({ prompt = "Artifact ID (ex: demo): ", default = "demo" }, function(artifact)
              if not artifact then return end
              local telescope = require("telescope")
              local fb = telescope.extensions.file_browser
              fb.file_browser({
                prompt_title = "Selecionar Pasta Raiz do Projeto",
                cwd = vim.fn.getcwd(),
                attach_mappings = function(prompt_bufnr, map)
                  local select_dir = function()
                    local selection = require("telescope.actions.state").get_selected_entry()
                    local root_dir = selection and (selection.is_dir and selection.path or vim.fn.fnamemodify(selection.path, ":h")) or vim.fn.getcwd()
                    require("telescope.actions").close(prompt_bufnr)
                    local project_path = root_dir .. "/" .. artifact
                    vim.fn.mkdir(project_path, "p")
                    local curl_cmd = string.format(
                      "curl https://start.spring.io/starter.tgz " ..
                      "-d type=maven-project " ..
                      "-d language=java " ..
                      "-d bootVersion=%s " ..
                      "-d baseDir=%s " ..
                      "-d groupId=%s " ..
                      "-d artifactId=%s " ..
                      "-d javaVersion=%s " ..
                      "| tar -xzvf - -C %s",
                      boot_v, artifact, group, artifact, java_v, root_dir
                    )
                    vim.fn.jobstart(curl_cmd, {
                      on_exit = function()
                        vim.notify("Projeto Spring Boot criado em: " .. project_path)
                        vim.cmd("NvimTreeOpen " .. project_path)
                      end
                    })
                  end
                  map("n", "<CR>", select_dir)
                  return true
                end
              })
            end)
          end)
        end)
      end)
    end
  '';

  autoCmd = [
    # Dashboard: disable all visual noise
    {
      event = "FileType";
      pattern = "dashboard";
      command = ''lua
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.syntax = "off"
        vim.opt_local.scrolloff = 0
        vim.cmd("nohlsearch")
        require('snacks').indent.disable()
      '';
    }
    # Float windows: ensure transparency
    {
      event = "WinEnter";
      pattern = "*";
      command = ''lua
        if vim.bo.filetype == "dashboard" then return end
        if vim.api.nvim_win_get_config(0).zindex then
          vim.wo.winhl = "Normal:NormalFloat,FloatBorder:FloatBorder"
        end
      '';
    }
    # Prevent "press enter" prompt on startup
    {
      event = "VimEnter";
      command = ''lua
        vim.cmd("Dashboard")
      '';
      once = true;
      nested = true;
    }
  ];
}

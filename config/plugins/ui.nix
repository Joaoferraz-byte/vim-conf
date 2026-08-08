{ ... }:
{
  plugins = {
    # NixVim enables lazy.nvim's update checker by default in its plugin-manager
    # integration. Its startup update report can overflow the message area and
    # create the visible hit-enter widget on the dashboard.
    lazy.settings = {
      checker.enabled = false;
      change_detection.notify = false;
    };

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
        scroll.enabled = false; # Disable visual scrollbar to avoid | markers on the right edge
        dashboard.enabled = false; # Desabilitado para não conflitar com dashboard-nvim
      };
    };

    # Dashboard-nvim — Doom layout with Neo-tree integration
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
              icon = "󰉋 ";
              desc = "Projects";
              action = "lua _G.open_projects()";
              key = "p";
              key_format = " %s";
            }
            {
              icon = " ";
              desc = "Config";
              action = "Neotree ~/.config/nvim";
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
                  "nvim v%d.%d.%d  •  %d loaded Lua modules  •  %s",
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
            __unkeyed-1 = "<leader>m";
            group = "Mini Files";
            icon = "󰉋 ";
          }
          {
            __unkeyed-1 = "<leader>mf";
            desc = "Open Mini Files";
            icon = "󰈔 ";
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

    # Mini.nvim modules are configured in core.nix.

    # Nvim-Tree (kept for compatibility, but neo-tree is the primary explorer)
    nvim-tree = {
      enable = false;
      settings.filters.dotfiles = false;
    };

    # Noice
    noice = {
      enable = true;
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.set_formatting_params" = true;
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
        };
        routes = [
          {
            filter = {
              event = "msg_show";
              kind = "return_prompt";
            };
            opts.skip = true;
          }
        ];
      };
    };

    barbecue.enable = true;
    treesitter-context.enable = true;
    fidget.enable = true;
    bufferline.enable = true;

    lualine = {
      enable = true;
      settings.options = {
        theme = "dms";
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
          "Neotree"
          "toggleterm"
          "help"
        ];
      };
    };

    # Render Markdown (mermaid.nvim, packaged in core.nix, hooks into it).
    render-markdown = {
      enable = true;
      settings = {
        preset = "minimal";
      };
    };

  };

  extraConfigLua = ''
    -- Show images in telescope previews using chafa instead of raw bytes
    pcall(function()
      local previewers = require("telescope.previewers")
      local telescope_conf = require("telescope.config").values
      local image_exts = { png = true, jpg = true, jpeg = true, gif = true, webp = true, avif = true, svg = true }
      telescope_conf.file_previewer = function(opts)
        local ext = string.lower(vim.fn.fnamemodify(opts.filepath or "", ":e"))
        if image_exts[ext] then
          return previewers.new_termopen_previewer {
            title = "Image",
            get_command = function(entry)
              return { "chafa", "-s", "60x28", entry.value }
            end,
          }
        end
        return previewers.vim_buffer_cat.new(opts)
      end
    end)

    _G.advanced_new_file = function()
      local telescope = require("telescope")
      if not telescope.actions then
        pcall(telescope.setup, {})
      end
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
        prompt_title = "Select directory (press Enter to choose)",
        attach_mappings = function(prompt_bufnr, map)
          local create_file = function()
            local selection = action_state.get_selected_entry()
            local dir = action_state.get_current_picker(prompt_bufnr).cwd
            if selection then
              dir = selection.is_dir and selection.path or vim.fn.fnamemodify(selection.path, ":h")
            end
            actions.close(prompt_bufnr)
            vim.ui.input({ prompt = "New file name (use / for nested dirs): " }, function(input)
              if input and input ~= "" then
                local path = dir .. "/" .. input
                vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
                vim.cmd("edit " .. vim.fn.fnameescape(path))
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

    _G.open_projects = function()
      local telescope = require("telescope")
      -- Telescope may be loaded as a module without having been initialized
      -- yet; in that state `telescope.actions` is nil and indexing it throws
      -- "attempt to index field 'actions' (a nil value)". Initialize it
      -- before touching its modules (the setup call is idempotent).
      if not telescope.actions then
        pcall(telescope.setup, {})
      end
      local pickers = telescope.pickers
      local finders = telescope.finders
      local conf = telescope.config
      local actions = telescope.actions
      local action_state = telescope.actions.state
      local ok, history = pcall(require, "project_nvim.utils.history")
      local projects = (ok and history.get_recent_projects and history.get_recent_projects()) or {}
      if #projects == 0 then
        vim.notify("No projects indexed by project.nvim", vim.log.levels.WARN)
        return
      end
      pickers.new({}, {
        prompt_title = "Projects",
        finder = finders.new_table {
          results = projects,
          entry_maker = function(project_path)
            return {
              value = project_path,
              display = vim.fn.fnamemodify(project_path, ":t"),
              ordinal = project_path,
            }
          end,
        },
        sorter = conf.generic_sorter({}),
        previewer = false,
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              pcall(vim.cmd, "Neotree " .. vim.fn.fnameescape(selection.value))
            end
          end)
          return true
        end,
      }):find()
    end

    _G.spring_boot_wizard = function()
      local java_versions = { "17", "21" }
      local boot_versions = { "3.2.0", "3.3.0" }
      vim.ui.select(java_versions, { prompt = "Java version:" }, function(java_v)
        if not java_v then return end
        vim.ui.select(boot_versions, { prompt = "Spring Boot version:" }, function(boot_v)
          if not boot_v then return end
          vim.ui.input({ prompt = "Group ID (ex: com.example): ", default = "com.example" }, function(group)
            if not group then return end
            vim.ui.input({ prompt = "Artifact ID (ex: demo): ", default = "demo" }, function(artifact)
              if not artifact then return end
              local telescope = require("telescope")
              if not telescope.actions then
                pcall(telescope.setup, {})
              end
              local fb = telescope.extensions.file_browser
              fb.file_browser({
                prompt_title = "Select project root directory",
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
                        vim.notify("Spring Boot project created at: " .. project_path)
                        vim.cmd("Neotree " .. project_path)
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
    # Dashboard: suppress all visual noise — numbers, signs, highlights, scrollbars
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
        -- Disable all plugins that could highlight on dashboard
        pcall(function() require('snacks').indent.disable() end)
        pcall(function() require('snacks').scroll.disable() end)
        pcall(function() require('illuminate').pause() end)
        pcall(function() require('illuminate').toggle_buffer() end)
        -- Clear all search highlights and plugin highlights on dashboard
        pcall(function() vim.cmd("hi clear Search") end)
        pcall(function() vim.cmd("hi clear IncSearch") end)
      '';
    }
    # WinLeave: clear highlights when leaving dashboard (resume when returning)
    {
      event = "WinLeave";
      pattern = "*";
      command = ''lua
        -- Resume illuminate when leaving the dashboard window
        pcall(function()
          if vim.bo.filetype ~= "dashboard" then
            require('illuminate').resume()
          end
        end)
      '';
    }
    # Neo-tree: ensure transparency for file explorer windows
    {
      event = "FileType";
      pattern = "neo-tree";
      command = ''lua
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false
      '';
    }
  ];
}

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
              icon_hl = "DashboardIcon";
              desc = "Find File           ";
              desc_hl = "String";
              action = "Telescope find_files";
              key = "f";
              key_hl = "Number";
              key_format = " %s";
            }
            {
              icon = " ";
              icon_hl = "DashboardIcon";
              desc = "Recent Files        ";
              desc_hl = "String";
              action = "Telescope oldfiles";
              key = "r";
              key_hl = "Number";
              key_format = " %s";
            }
            {
              icon = "󰩈 ";
              icon_hl = "DashboardIcon";
              desc = "Projects            ";
              desc_hl = "String";
              action = "lua _G.open_projects()";
              key = "p";
              key_hl = "Number";
              key_format = " %s";
            }
            {
              icon = " ";
              icon_hl = "DashboardIcon";
              desc = "New File            ";
              desc_hl = "String";
              action = "lua _G.advanced_new_file()";
              key = "n";
              key_hl = "Number";
              key_format = " %s";
            }
            {
              icon = " ";
              icon_hl = "DashboardIcon";
              desc = "Find Text           ";
              desc_hl = "String";
              action = "Telescope live_grep";
              key = "g";
              key_hl = "Number";
              key_format = " %s";
            }
            {
              icon = " ";
              icon_hl = "DashboardIcon";
              desc = "Spring Boot         ";
              desc_hl = "String";
              action = "lua _G.spring_boot_wizard()";
              key = "s";
              key_hl = "Number";
              key_format = " %s";
            }
            {
              icon = " ";
              icon_hl = "DashboardIcon";
              desc = "Config              ";
              desc_hl = "String";
              action = "Neotree ~/.config/nvim";
              key = "c";
              key_hl = "Number";
              key_format = " %s";
            }
            {
              icon = "󰋤 ";
              icon_hl = "DashboardIcon";
              desc = "Browse Keymaps        ";
              desc_hl = "String";
              /* telescope.builtin.keymaps crashes on Lua 5.1 when a keymap
                 callback has no desc: make_entry calls debug.getinfo(cb)
                 without the "S" option, so info.source is nil and
                 telescope/actions/utils.lua blows up on path:new.
                 which-key shows categorized groups with icons natively,
                 so the logic lives in _G.browse_keymaps below. */
              action = "lua _G.browse_keymaps()";
              key = "?";
              key_hl = "Number";
              key_format = " %s";
            }
            {
              icon = " ";
              icon_hl = "DashboardIcon";
              desc = "Quit                ";
              desc_hl = "String";
              action = "qa";
              key = "q";
              key_hl = "Number";
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
            __unkeyed-1 = "<leader>b";
            group = "Buffers";
            icon = "󰓩 ";
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
            icon = "󰋤 ";
          }
          {
            __unkeyed-1 = "<leader>k";
            group = "Keymaps";
            icon = "󰌌 ";
          }
          {
            __unkeyed-1 = "<leader>kb";
            desc = "Browse Keymaps";
            icon = "󰋤 ";
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
    bufferline = {
      enable = true;
      settings = {
        options = {
          # Use thin separators between buffers (slant style is too heavy with transparency)
          separator_style = "thin";
          # Show diagnostics in the bufferline
          diagnostics = "nvim_lsp";
          diagnostics_indicator.__raw = ''
            function(count, level)
              local icon = level:match("error") and " " or " "
              return " " .. icon .. count
            end
          '';
          # Show ordinal numbers for BufferLineGoToBuffer navigation
          numbers = "ordinal";
          # Keep bufferline visible even with a single buffer
          always_show_bufferline = true;
          # Show close button
          show_buffer_close_icons = true;
          show_close_icon = true;
          # Offset for neo-tree sidebar
          offsets = [
            {
              filetype = "neo-tree";
              text = "File Explorer";
              text_align = "center";
              separator = true;
            }
          ];
        };
        # Transparent highlights — bg = "" means inherit from terminal background.
        # This keeps the bufferline visually consistent with the transparent theme.
        highlights = {
          fill.bg = "";
          background.bg = "";
          tab.bg = "";
          tab_selected.bg = "";
          tab_separator.bg = "";
          tab_separator_selected.bg = "";
          tab_close.bg = "";
          close_button.bg = "";
          close_button_visible.bg = "";
          close_button_selected.bg = "";
          buffer_visible.bg = "";
          buffer_selected.bg = "";
          numbers.bg = "";
          numbers_visible.bg = "";
          numbers_selected.bg = "";
          diagnostic.bg = "";
          diagnostic_visible.bg = "";
          diagnostic_selected.bg = "";
          hint.bg = "";
          hint_visible.bg = "";
          hint_selected.bg = "";
          hint_diagnostic.bg = "";
          hint_diagnostic_visible.bg = "";
          hint_diagnostic_selected.bg = "";
          info.bg = "";
          info_visible.bg = "";
          info_selected.bg = "";
          info_diagnostic.bg = "";
          info_diagnostic_visible.bg = "";
          info_diagnostic_selected.bg = "";
          warning.bg = "";
          warning_visible.bg = "";
          warning_selected.bg = "";
          warning_diagnostic.bg = "";
          warning_diagnostic_visible.bg = "";
          warning_diagnostic_selected.bg = "";
          error.bg = "";
          error_visible.bg = "";
          error_selected.bg = "";
          error_diagnostic.bg = "";
          error_diagnostic_visible.bg = "";
          error_diagnostic_selected.bg = "";
          modified.bg = "";
          modified_visible.bg = "";
          modified_selected.bg = "";
          duplicate_selected.bg = "";
          duplicate_visible.bg = "";
          duplicate.bg = "";
          separator.bg = "";
          separator_selected.bg = "";
          separator_visible.bg = "";
          indicator_visible.bg = "";
          indicator_selected.bg = "";
          pick_selected.bg = "";
          pick_visible.bg = "";
          pick.bg = "";
          offset_separator.bg = "";
          trunc_marker.bg = "";
        };
      };
    };

    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "dms";
          globalstatus = true;
          # Powerline-style separators for a clean look
          section_separators = {
            left = "";
            right = "";
          };
          component_separators = {
            left = "";
            right = "";
          };
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [
            "branch"
            {
              __unkeyed-1 = "diff";
              symbols = { added = " "; modified = " "; removed = " "; };
            }
            {
              __unkeyed-1 = "diagnostics";
              sources = [ "nvim_lsp" ];
            }
          ];
          lualine_c = [
            { __unkeyed-1 = "filename"; path = 1; }
          ];
          lualine_x = [
            "encoding"
            "fileformat"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
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

    -- Smart advanced new file: path-based creation with templates and compact folders.
    -- Compact folders: nested dirs with single child are grouped (java/com/seila -> seila).
    -- Tab = complete path, Enter = create file.
    _G.advanced_new_file = function()
      local ok = pcall(require, "telescope")
      if not ok then return end
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Templates for common file types
      local templates = {
        java = 'package %s;\n\npublic class %s {\n    public static void main(String[] args) {\n        // TODO\n    }\n}\n',
        py = '#!/usr/bin/env python3\n"""Module %s."""\n\n\ndef main():\n    pass\n\n\nif __name__ == "__main__":\n    main()\n',
        js = '// %s\n\nexport default function %s() {\n  return null;\n}\n',
        ts = '// %s\n\nexport function %s(): void {\n  // TODO\n}\n',
        tsx = "import React from 'react';\n\nexport const %s = () => {\n  return <div>%s</div>;\n};\n",
        nix = '{ lib, pkgs, ... }:\n{\n  options = {};\n  config = {};\n}\n',
        md = '# %s\n\n## Overview\n\nTODO\n',
        sh = '#!/bin/bash\nset -euo pipefail\n\n# %s\n\nmain() {\n  :\n}\n\nmain "$@"\n',
        json = '{\n  "name": "%s",\n  "version": "1.0.0"\n}\n',
        yaml = '---\n# %s\n\nversion: 1.0.0\n',
        c = '#include <stdio.h>\n\nint main(void) {\n    return 0;\n}\n',
        cpp = '#include <iostream>\n\nint main() {\n    return 0;\n}\n',
        rs = 'fn main() {\n    println!("Hello");\n}\n',
        go = 'package main\n\nimport "fmt"\n\nfunc main() {\n    fmt.Println("Hello")\n}\n',
      }

      local cwd = vim.fn.expand("%:p:h")
      if vim.fn.isdirectory(cwd) == 0 then
        cwd = vim.fn.getcwd()
      end

      local function create_file(path)
        local dir = vim.fn.fnamemodify(path, ":h")
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end
        local fname = vim.fn.fnamemodify(path, ":t")
        local ext = fname:match("%.([^.]+)$") or ""
        local tmpl = templates[ext]
        if tmpl then
          local name = fname:gsub("%.%w+$", ""):gsub("^.", string.upper)
          local content = tmpl:format(name, name):gsub("\\n", "\n")
          vim.cmd("edit " .. vim.fn.fnameescape(path))
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n", { plain = true }))
          vim.cmd("write")
          vim.notify("Created: " .. path, vim.log.levels.INFO)
        else
          vim.cmd("edit " .. vim.fn.fnameescape(path))
          vim.cmd("write")
          vim.notify("Created: " .. path, vim.log.levels.INFO)
        end
      end

      -- Get compact path: collapse single-child dir chains (java/com/seila -> java/com/seila)
      -- Returns { full_path, display_parts } where display_parts shows only the leaf names
      local function get_compact_candidates(prompt)
        local base, partial = prompt:match("^(.*/)([^/]*)$")
        if not base then
          base = ""
          partial = prompt
        end
        local scan_dir = cwd .. "/" .. base
        if vim.fn.isdirectory(scan_dir) == 0 then
          return {}
        end
        local results = {}
        -- Scan immediate children
        local handle = vim.loop.fs_scandir(scan_dir)
        if not handle then return results end
        local children = {}
        while true do
          local name, dtype = vim.loop.fs_scandir_next(handle)
          if not name then break end
          if name:sub(1, 1) == "." then goto skip end
          if name == ".git" then goto skip end
          if partial == "" or name:sub(1, #partial) == partial then
            children[#children + 1] = { name = name, type = dtype }
          end
          ::skip::
        end
        table.sort(children, function(a, b)
          if a.type ~= b.type then return a.type == 2 end
          return a.name < b.name
        end)
        for _, child in ipairs(children) do
          local full_path = base .. child.name
          local display_name = child.name
          if child.type == 2 then
            -- Compact folders: follow single-child dir chains
            local chain = child.name
            local deep = base .. child.name .. "/"
            local deep_handle = vim.loop.fs_scandir(deep)
            if deep_handle then
              -- Helper to get valid (non-hidden) children
              local function get_valid_children(h)
                local c = {}
                while true do
                  local n, t = vim.loop.fs_scandir_next(h)
                  if not n then break end
                  if n:sub(1, 1) ~= "." then
                    c[#c + 1] = {name = n, type = t}
                  end
                end
                return c
              end
              
              local deep_children = get_valid_children(deep_handle)
              while #deep_children == 1 and deep_children[1].type == 2 do
                local child_name = deep_children[1].name
                chain = chain .. "/" .. child_name
                deep = deep .. child_name .. "/"
                local h = vim.loop.fs_scandir(deep)
                if not h then break end
                deep_children = get_valid_children(h)
              end
            end
            results[#results + 1] = { value = full_path .. "/", display = chain .. "/ " }
          else
            results[#results + 1] = { value = full_path, display = display_name }
          end
        end
        return results
      end

      local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
      local entry_maker = function(cand)
        local icon, icon_hl
        if devicons_ok then
          if cand.value:match("/$") then
            icon, icon_hl = devicons.get_icon("folder", "folder", { default = true })
            icon = icon or ""
          else
            local ext = cand.value:match("%.([^.]+)$") or ""
            icon, icon_hl = devicons.get_icon(cand.value, ext, { default = true })
            icon = icon or ""
          end
        else
          icon = cand.value:match("/$") and "" or ""
          icon_hl = "Normal"
        end

        local display_str = string.format("%s %s", icon, cand.display)

        return {
          value = cand.value,
          display = display_str,
          ordinal = cand.value,
        }
      end

      local function make_finder(results)
        return finders.new_table { results = results, entry_maker = entry_maker }
      end

      pickers.new({}, {
        prompt_title = "New File (Tab=complete, Enter=create)",
        prompt_prefix = cwd .. "/ ",
        finder = make_finder(get_compact_candidates("")),
        sorter = conf.file_sorter({}),
        on_input_filter_cb = function(prompt)
          return { updated_finder = make_finder(get_compact_candidates(prompt)) }
        end,
        attach_mappings = function(prompt_bufnr, map)
          map("i", "<Tab>", function()
            local sel = action_state.get_selected_entry()
            if sel then
              local picker = action_state.get_current_picker(prompt_bufnr)
              if picker then
                -- set_prompt(text, true) substitui o prompt completamente.
                -- O '/' já está incluído em sel.value para diretórios.
                picker:set_prompt(sel.value, true)
                -- Atualiza o finder manualmente para listar os filhos do diretório selecionado,
                -- pois set_prompt não dispara on_input_filter_cb automaticamente.
                picker:refresh(make_finder(get_compact_candidates(sel.value)), {})
              end
            end
          end)
          map("i", "<CR>", function()
            local prompt = action_state.get_current_line()
            local sel = action_state.get_selected_entry()
            local path
            if prompt == "" and sel then
              path = sel.value
            else
              path = prompt
            end
            if path == "" or path == "/" then return end
            actions.close(prompt_bufnr)
            create_file(cwd .. "/" .. path)
          end)
          return true
        end,
      }):find()
    end

    -- Browse keymaps by category using the actual Neovim keymap registry.
    -- which-key only changes the displayed prefix; it does not filter maps
    -- returned by other providers. This picker filters before rendering.
    _G.browse_keymaps = function()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local categories = {
        { icon = "", name = "Files", key = "f", prefixes = { "<leader>f", "<leader>e" }, terms = { "file", "find", "explorer", "neo-tree", "replace", "grug" } },
        { icon = "󰘦", name = "Code/LSP", key = "c", prefixes = { "<leader>c", "<leader>l" }, terms = { "lsp", "code", "diagnostic", "format", "rename" } },
        { icon = "", name = "Git", key = "g", prefixes = { "<leader>g" }, terms = { "git", "commit", "diff", "hunk" } },
        { icon = "", name = "Test", key = "t", prefixes = { "<leader>t" }, terms = { "test", "spec" } },
        { icon = "", name = "Debug", key = "x", prefixes = { "<leader>x" }, terms = { "debug", "breakpoint", "dap" } },
        { icon = "", name = "New", key = "n", prefixes = { "<leader>n" }, terms = { "new", "create", "template" } },
        { icon = "", name = "Harpoon", key = "h", prefixes = { "<leader>h" }, terms = { "harpoon", "mark" } },
        { icon = "󰓩", name = "Buffers", key = "b", prefixes = { "<leader>b" }, terms = { "buffer", "close", "delete", "move" } },
        { icon = "󰉋", name = "Mini", key = "m", prefixes = { "<leader>m" }, terms = { "mini", "files" } },
      }

      local function normalize_lhs(lhs)
        lhs = lhs or ""
        local leader = vim.g.mapleader or "\\"
        if lhs:sub(1, #leader) == leader then
          return "<leader>" .. lhs:sub(#leader + 1)
        end
        return lhs:gsub("^<Space>", "<leader>")
      end

      local function matches(map, category)
        local lhs = normalize_lhs(map.lhs)
        local desc = (map.desc or ""):lower()
        for _, prefix in ipairs(category.prefixes) do
          if lhs == prefix or lhs:sub(1, #prefix + 1) == prefix .. " " or lhs:sub(1, #prefix) == prefix then
            return true
          end
        end
        for _, term in ipairs(category.terms) do
          if desc:find(term, 1, true) then return true end
        end
        return false
      end

      local function collect(category)
        local entries, seen = {}, {}
        for _, mode in ipairs({ "n", "v", "x", "o", "i", "c", "t" }) do
          for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
            if matches(map, category) then
              local lhs = normalize_lhs(map.lhs)
              local id = mode .. "\\0" .. lhs
              if not seen[id] then
                seen[id] = true
                local desc = map.desc or map.rhs or "(no description)"
                entries[#entries + 1] = {
                  value = map,
                  ordinal = category.name .. " " .. mode .. " " .. lhs .. " " .. desc,
                  display = string.format("%-2s %-22s %s", mode, lhs, desc),
                }
              end
            end
          end
        end
        table.sort(entries, function(a, b) return a.ordinal < b.ordinal end)
        return entries
      end

      local function show_category(category)
        local entries = collect(category)
        if #entries == 0 then
          vim.notify("No keymaps found for " .. category.name, vim.log.levels.WARN)
          return
        end
        pickers.new({}, {
          prompt_title = category.icon .. " " .. category.name .. " Keymaps (" .. #entries .. ")",
          finder = finders.new_table { results = entries, entry_maker = function(entry) return entry end },
          sorter = conf.generic_sorter({}),
          previewer = false,
        }):find()
      end

      local items = {}
      for _, category in ipairs(categories) do
        items[#items + 1] = string.format("%s  %s  (%s)", category.icon, category.name, category.key)
      end
      vim.ui.select(items, { prompt = "Select keymap category: " }, function(_, index)
        if index then show_category(categories[index]) end
      end)
    end

    -- Browse ~/Projects and open the selected folder in Neo-tree.
    -- No recursive search: every immediate subfolder of ~/Projects is a
    -- project; <CR> cd's into it and focuses the Neo-tree file tree.
    _G.open_projects = function()
      local projects_dir = vim.fn.expand("$HOME") .. "/Projects"
      if vim.fn.isdirectory(projects_dir) == 0 then
        vim.notify("Projects directory not found: " .. projects_dir, vim.log.levels.WARN)
        return
      end
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local builtin_opts = { prompt_title = "Projects", cwd = projects_dir }
      -- List immediate subfolders (depth 1), skipping hidden ones.
      local results = {}
      local handle = vim.loop.fs_scandir(projects_dir)
      if handle then
        while true do
          local name, dtype = vim.loop.fs_scandir_next(handle)
          if not name then
            break
          end
          if dtype == "directory" and name:sub(1, 1) ~= "." then
            results[#results + 1] = name
          elseif dtype == nil then
            if vim.fn.isdirectory(projects_dir .. "/" .. name) == 1 and
               name:sub(1, 1) ~= "." then
              results[#results + 1] = name
            end
          end
        end
      end
      table.sort(results)
      if #results == 0 then
        vim.notify(
          "No project folders found in " .. projects_dir ..
          " (only first-level folders count as projects)",
          vim.log.levels.WARN
        )
        return
      end
      pickers.new(builtin_opts, {
        prompt_title = "Projects",
        finder = finders.new_table {
          results = results,
          entry_maker = function(name)
            return {
              value = name,
              display = name,
              ordinal = name,
            }
          end,
        },
        sorter = conf.generic_sorter(builtin_opts),
        previewer = false,
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection and selection.value then
              local project = projects_dir .. "/" .. selection.value
              vim.cmd("cd " .. vim.fn.fnameescape(project))
              -- Close the dashboard window itself before switching to Neo-tree.
              pcall(vim.cmd, "close")
              -- Open the file tree of the selected folder and focus it.
              require("neo-tree.command").execute({
                action = "focus",
                dir = project,
                position = "left",
                reveal = true,
                toggle = true,
              })
              vim.notify("Opened project: " .. project, vim.log.levels.INFO)
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
    # Improve float window borders globally
    {
      event = "VimEnter";
      pattern = "*";
      command = ''lua
        -- Override default LSP float borders to rounded style
        local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
          opts = opts or {}
          opts.border = opts.border or "rounded"
          return orig_util_open_floating_preview(contents, syntax, opts, ...)
        end
        -- Override vim.diagnostic float borders
        vim.diagnostic.config({
          float = {
            border = "rounded",
            source = true,
            header = "",
            prefix = "",
          },
          virtual_text = {
            prefix = "●",
            spacing = 4,
          },
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })
        -- Set diagnostic signs with icons
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
      '';
    }
  ];
}

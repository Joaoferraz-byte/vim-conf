{ ... }:
{
  plugins = {
    lazy.settings = {
      checker.enabled = false;
      change_detection.notify = false;
    };

    # Snacks is the canonical UI foundation. Specialized plugins such as DAP,
    # Aerial, Git and render-markdown remain independent because Snacks does
    # not provide equivalent workflows for them.
    snacks = {
      enable = true;
      settings = {
        bigfile.enabled = true;
        dashboard = {
          enabled = true;
          preset = {
            header = ''
              ██╗     ██╗██╗   ██╗ █████╗ ██████╗  █████╗
              ██║     ██║██║   ██║██╔══██╗██╔══██╗██╔══██╗
              ██║     ██║██║   ██║███████║██████╔╝███████║
              ██║     ██║╚██╗ ██╔╝██╔══██║██╔══██╗██╔══██║
              ███████╗██║ ╚████╔╝ ██║  ██║██║  ██║██║  ██║
              ╚══════╝╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
            '';
            keys = [
              {
                icon = " ";
                key = "f";
                desc = "Find File";
                action = ":lua Snacks.picker.files()";
              }
              {
                icon = " ";
                key = "r";
                desc = "Recent Files";
                action = ":lua Snacks.picker.recent()";
              }
              {
                icon = "󰩈 ";
                key = "p";
                desc = "Projects";
                action = ":lua _G.open_projects()";
              }
              {
                icon = " ";
                key = "n";
                desc = "New File";
                action = ":lua _G.advanced_new_file()";
              }
              {
                icon = " ";
                key = "g";
                desc = "Find Text";
                action = ":lua Snacks.picker.grep()";
              }
              {
                icon = " ";
                key = "s";
                desc = "Spring Boot";
                action = ":lua _G.spring_boot_wizard()";
              }
              {
                icon = " ";
                key = "c";
                desc = "Config";
                action = ":Oil ~/.config/nixos";
              }
              {
                icon = "󰈙 ";
                key = "v";
                desc = "Sync and Open Vault";
                action = ":lua _G.open_livara_vault()";
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
            {
              section = "keys";
              gap = 1;
              padding = 1;
            }
          ];
        };
        explorer = {
          enabled = true;
          replace_netrw = true;
          trash = true;
        };
        image = {
          enabled = true;
          formats = [
            "png"
            "jpg"
            "jpeg"
            "gif"
            "bmp"
            "webp"
            "tiff"
            "avif"
            "pdf"
          ];
          convert.magick.default = [ "{src}[0]" "-scale" "1920x1080>" ];
        };
        indent.enabled = true;
        input.enabled = true;
        notifier.enabled = true;
        picker = {
          enabled = true;
          ui_select = true;
          sources.explorer = {
            tree = true;
            watch = true;
            git_status = true;
            git_untracked = true;
            follow_file = true;
            auto_close = false;
            layout.preset = "sidebar";
          };
          previewers.file.max_size = 1024 * 1024;
        };
        quickfile.enabled = true;
        scope.enabled = true;
        statuscolumn.enabled = true;
        terminal.enabled = true;
        words.enabled = false;
        zen.enabled = true;
      };
    };

    oil = {
      enable = true;
      settings = {
        default_file_explorer = true;
        columns = [ "icon" ];
        delete_to_trash = true;
        constrain_cursor = "editable";
        view_options = {
          # Keep dotfiles available through Oil's `g.` toggle, but do not
          # expose repository plumbing in the normal Vault workflow.
          show_hidden = true;
          is_always_hidden.__raw = ''function(name, bufnr)
            return name == ".git" or name == ".gitignore"
          end'';
          natural_order = "fast";
          case_insensitive = false;
        };
      };
    };

    which-key = {
      enable = true;
      settings = {
        delay = 250;
        preset = "modern";
        show_help = true;
        show_keys = true;
        icons = {
          mappings = true;
          rules = false;
          group = "";
          separator = " ";
        };
        layout = {
          spacing = 6;
          align = "center";
        };
        win = {
          border = "rounded";
          title = true;
          title_pos = "center";
          padding = [ 1 2 ];
        };
        spec = [
          { __unkeyed-1 = "<leader>f"; group = "Files"; icon = " "; }
          { __unkeyed-1 = "<leader>c"; group = "Configuration"; icon = " "; }
          { __unkeyed-1 = "<leader>l"; group = "Language"; icon = "󰘦 "; }
          { __unkeyed-1 = "<leader>j"; group = "Java"; icon = " "; }
          { __unkeyed-1 = "<leader>n"; group = "New"; icon = " "; }
          { __unkeyed-1 = "<leader>v"; group = "Vault"; icon = "󰈙 "; }
          { __unkeyed-1 = "<leader>b"; group = "Buffers"; icon = "󰓩 "; }
          { __unkeyed-1 = "<leader>g"; group = "Git"; icon = " "; }
          { __unkeyed-1 = "<leader>h"; group = "Harpoon"; icon = "󰛢 "; }
          { __unkeyed-1 = "<leader>k"; group = "Keymaps"; icon = "󰌌 "; }
          { __unkeyed-1 = "<leader>e"; desc = "Toggle File Explorer"; icon = "󰙅 "; }
          { __unkeyed-1 = "<leader>m"; group = "Explorer Actions"; icon = "󰙅 "; }
          { __unkeyed-1 = "<leader>o"; desc = "Toggle Symbol Outline"; icon = "󰆧 "; }
          { __unkeyed-1 = "<leader>d"; desc = "Open Dashboard"; icon = "󰋜 "; }
          { __unkeyed-1 = "<leader>x"; group = "Debug"; icon = " "; }
          { __unkeyed-1 = "<leader>z"; desc = "Toggle Zen Mode"; icon = "󰒲 "; }
          { __unkeyed-1 = "<leader>?"; desc = "Browse All Keymaps"; icon = "󰋤 "; }
          { __unkeyed-1 = "<leader>t"; group = "Test"; icon = " "; }
        ];
      };
    };

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

    barbecue = {
      enable = true;
      settings = {
        # nvim-navic supports one LSP client per buffer; attach it from the
        # guarded LspAttach callback in extraConfigLua instead of letting the
        # archived plugin attach every overlapping web server.
        attach_navic = false;
      };
    };
    treesitter-context.enable = true;
    fidget = {
      enable = true;
      settings = {
        # Keep LSP progress handling enabled but do not render every progress
        # update while typing. This avoids the bottom-right notification spam.
        progress = {
          poll_rate = false;
          suppress_on_insert = true;
        };
        notification = {
          override_vim_notify = false;
        };
      };
    };

    bufferline = {
      enable = true;
      settings = {
        options = {
          separator_style = "thin";
          diagnostics = "nvim_lsp";
          numbers = "ordinal";
          always_show_bufferline = true;
          show_buffer_close_icons = true;
          show_close_icon = true;
        };
        # Keep file glyphs and close controls on the same transparent canvas as
        # the tab text. The selected buffer remains identifiable through its
        # foreground/bold treatment and the indicator, not a glyph rectangle.
        highlights = {
          fill = { bg = "NONE"; };
          background = { bg = "NONE"; };
          buffer = { bg = "NONE"; };
          buffer_visible = { bg = "NONE"; };
          buffer_selected = { bg = "NONE"; bold = true; };
          tab = { bg = "NONE"; };
          tab_selected = { bg = "NONE"; bold = true; };
          tab_close = { bg = "NONE"; };
          close_button = { bg = "NONE"; };
          close_button_visible = { bg = "NONE"; };
          close_button_selected = { bg = "NONE"; };
          modified = { bg = "NONE"; };
          modified_visible = { bg = "NONE"; };
          modified_selected = { bg = "NONE"; };
          numbers = { bg = "NONE"; };
          numbers_visible = { bg = "NONE"; };
          numbers_selected = { bg = "NONE"; };
          separator = { bg = "NONE"; };
          separator_visible = { bg = "NONE"; };
          separator_selected = { bg = "NONE"; };
          indicator_selected = { bg = "NONE"; };
        };
      };
    };

    render-markdown = {
      enable = true;
      settings = {
        max_file_size = 16.0;
        render_modes = [ "n" "v" "V" "c" "t" ];
        completions.lsp.enabled = true;
        latex = {
          enabled = true;
          inline = true;
          block = true;
          converter = [ "utftex" "latex2text" ];
        };
        heading = {
          enabled = true;
          position = "overlay";
          width = "full";
        };
        code = {
          enabled = true;
          border = "hide";
          width = "full";
          language = true;
          language_icon = true;
        };
        bullet = {
          enabled = true;
          icons = [ "● " "○ " "◆ " ];
        };
        checkbox = {
          enabled = true;
          unchecked = { icon = "󰄱 "; highlight = "RenderMarkdownUnchecked"; };
          checked = { icon = "󰱒 "; highlight = "RenderMarkdownChecked"; };
        };
        pipe_table = {
          enabled = true;
          preset = "round";
        };
        # quote, link and sign are option tables in the pinned plugin API.
        # Callouts intentionally use the plugin's built-in definition table;
        # assigning callout.enabled would pass a boolean to resolved.lua and
        # reproduce the `attempt to index a boolean value` crash.
        quote = { enabled = true; };
        link = { enabled = true; };
        sign = { enabled = false; };
      };
    };
    aerial = {
      enable = true;
      settings = {
        backends = [ "lsp" "treesitter" "markdown" ];
        show_guides = true;
      };
    };
    trouble.enable = true;
  };

  extraConfigLua = ''
    -- MariaSolOs-style statusline/winbar: semantic components are rendered
    -- as small colored islands, while the canvas itself remains transparent.
    -- Colors are read from Livara's dynamic highlight groups on every render,
    -- so Matugen reloads and an optional Tokyo Night palette are reflected
    -- without rebuilding the component layout.
    local LivaraStatusline = {}
    local disabled_statusline_filetypes = {
      snacks_dashboard = true,
      snacks_picker_list = true,
      oil = true,
    }

    local statusline_mode = {
      n = { label = "NORMAL", group = "LivaraStatusNormalMode" },
      no = { label = "OP-PENDING", group = "LivaraStatusNormalMode" },
      i = { label = "INSERT", group = "LivaraStatusInsertMode" },
      v = { label = "VISUAL", group = "LivaraStatusVisualMode" },
      V = { label = "VISUAL", group = "LivaraStatusVisualMode" },
      [vim.api.nvim_replace_termcodes("<C-v>", true, false, true)] = { label = "VISUAL", group = "LivaraStatusVisualMode" },
      R = { label = "REPLACE", group = "LivaraStatusReplaceMode" },
      c = { label = "COMMAND", group = "LivaraStatusCommandMode" },
      t = { label = "TERMINAL", group = "LivaraStatusCommandMode" },
    }

    local function rgb(value, fallback)
      return value and string.format("#%06x", value) or fallback
    end

    local function highlight(name, fg, bg, opts)
      local spec = vim.tbl_extend("force", opts or {}, { fg = fg, bg = bg })
      vim.api.nvim_set_hl(0, name, spec)
      return name
    end

    local function group_colors(group, fallback_fg, fallback_bg)
      local spec = vim.api.nvim_get_hl(0, { name = group, link = false })
      return rgb(spec.fg, fallback_fg), rgb(spec.bg, fallback_bg)
    end

    local function prepare_highlights(mode_group)
      local mode_fg, mode_bg = group_colors(mode_group, "#111318", "#c3adff")
      local text_fg = group_colors("Normal", "#e1e2e8", "NONE")
      local muted_fg = group_colors("Comment", "#a6a8b3", "NONE")
      local accent_fg = group_colors("Directory", "#c3adff", "NONE")
      highlight("LivaraStatusMode", mode_fg, mode_bg, { bold = true })
      highlight("LivaraStatusModeSep", mode_bg, "NONE")
      highlight("LivaraStatusText", text_fg, "NONE")
      highlight("LivaraStatusMuted", muted_fg, "NONE")
      highlight("LivaraStatusAccent", accent_fg, "NONE", { bold = true })
      highlight("LivaraStatusError", group_colors("DiagnosticError", "#ff7a90", "NONE"), "NONE")
      highlight("LivaraStatusWarn", group_colors("DiagnosticWarn", "#f5d782", "NONE"), "NONE")
      highlight("LivaraStatusInfo", group_colors("DiagnosticInfo", "#8fc7ff", "NONE"), "NONE")
      highlight("LivaraStatusHint", group_colors("DiagnosticHint", "#8ee6b0", "NONE"), "NONE")
      highlight("LivaraWinbarText", text_fg, "NONE")
      highlight("LivaraWinbarMuted", muted_fg, "NONE")
      return mode_fg, mode_bg
    end

    local function mode_component()
      local current = vim.api.nvim_get_mode().mode
      local mode = statusline_mode[current] or statusline_mode[current:sub(1, 1)] or statusline_mode.n
      prepare_highlights(mode.group)
      return table.concat({
        "%#LivaraStatusModeSep#",
        "%#LivaraStatusMode#  " .. mode.label,
        "%#LivaraStatusModeSep#",
      })
    end

    local function git_component()
      local head = vim.b.gitsigns_head
      return head and ("%#LivaraStatusAccent# " .. head) or ""
    end

    local function diagnostics_component()
      local counts = { 0, 0, 0, 0 }
      for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        counts[diagnostic.severity] = counts[diagnostic.severity] + 1
      end
      local parts = {}
      local symbols = { "", "", "󰌵", "" }
      local groups = { "LivaraStatusError", "LivaraStatusWarn", "LivaraStatusHint", "LivaraStatusInfo" }
      for severity = 1, 4 do
        if counts[severity] > 0 then
          parts[#parts + 1] = string.format("%%#%s#%s %d", groups[severity], symbols[severity], counts[severity])
        end
      end
      return table.concat(parts, " ")
    end

    local function filetype_component()
      local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "no filetype"
      local icon = "󰈮"
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if ok then
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
        icon = devicons.get_icon(name, vim.bo.filetype, { default = true }) or icon
      end
      return "%#LivaraStatusAccent#" .. icon .. " %#LivaraStatusText#" .. filetype
    end

    local function lsp_component()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then return "" end
      local names = {}
      for _, client in ipairs(clients) do names[#names + 1] = client.name end
      table.sort(names)
      return "%#LivaraStatusAccent#󰒓 %#LivaraStatusMuted#" .. table.concat(names, ",")
    end

    function LivaraStatusline.render()
      if disabled_statusline_filetypes[vim.bo.filetype] then return "" end
      local left = table.concat({ mode_component(), git_component(), filetype_component() }, "  ")
      local right = table.concat({ diagnostics_component(), lsp_component(), "%#LivaraStatusMuted#󰍒 " .. vim.fn.line(".") .. ":" .. vim.fn.virtcol(".") }, "  ")
      return left .. "%=" .. right .. " "
    end

    function LivaraStatusline.winbar()
      if disabled_statusline_filetypes[vim.bo.filetype] then return "" end
      local path = vim.api.nvim_buf_get_name(0)
      if path == "" then return "" end
      local display = vim.fn.fnamemodify(path, ":~:.")
      local directory = vim.fn.fnamemodify(display, ":h")
      local basename = vim.fn.fnamemodify(display, ":t")
      return "%#LivaraWinbarMuted#󰉋 " .. directory .. " %#LivaraWinbarText#› " .. basename
    end

    _G.LivaraStatusline = LivaraStatusline
    _G.livara_statusline_activate = function()
      vim.o.showmode = false
      vim.o.statusline = "%!v:lua.LivaraStatusline.render()"
      vim.o.winbar = "%!v:lua.LivaraStatusline.winbar()"
      vim.cmd("redrawstatus")
    end
    _G.livara_statusline_activate()

    local navic_attach_group = vim.api.nvim_create_augroup("LivaraNavicAttach", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = navic_attach_group,
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or not client.server_capabilities.documentSymbolProvider then
          return
        end
        if vim.b[args.buf].livara_navic_client_id then
          return
        end
        local ok, navic = pcall(require, "nvim-navic")
        if ok then
          navic.attach(client, args.buf)
          vim.b[args.buf].livara_navic_client_id = client.id
        end
      end,
    })

    local function notify(message, level)
      vim.notify(message, level or vim.log.levels.INFO)
    end

    local templates = {
      java = 'package %s;\n\npublic class %s {\n    public static void main(String[] args) {\n        // TODO\n    }\n}\n',
      py = '#!/usr/bin/env python3\n"""Module %s."""\n\n\ndef main():\n    pass\n\n\nif __name__ == "__main__":\n    main()\n',
      js = '// %s\n\nexport default function %s() {\n  return null;\n}\n',
      ts = '// %s\n\nexport function %s(): void {\n  // TODO\n}\n',
      tsx = "import React from 'react';\n\nexport const %s = () => {\n  return <div>%s</div>;\n};\n",
      nix = '{ lib, pkgs, ... }:\n{\n  options = {};\n  config = {};\n}\n',
      md = '# %s\n\n## Overview\n\nTODO\n',
      sh = '#!/bin/bash\nset -euo pipefail\n\n# %s\n',
      json = '{\n  "name": "%s",\n  "version": "1.0.0"\n}\n',
      yaml = '---\n# %s\n\nversion: 1.0.0\n',
      c = '#include <stdio.h>\n\nint main(void) {\n    return 0;\n}\n',
      cpp = '#include <iostream>\n\nint main() {\n    return 0;\n}\n',
      rs = 'fn main() {\n    println!("Hello");\n}\n',
      go = 'package main\n\nimport "fmt"\n\nfunc main() {\n    fmt.Println("Hello")\n}\n',
    }

    local template_choices = {
      { ext = "java", label = "Java class" },
      { ext = "py", label = "Python module" },
      { ext = "js", label = "JavaScript module" },
      { ext = "ts", label = "TypeScript function" },
      { ext = "tsx", label = "React TSX component" },
      { ext = "nix", label = "Nix module" },
      { ext = "md", label = "Markdown note" },
      { ext = "sh", label = "Shell script" },
      { ext = "json", label = "JSON document" },
      { ext = "yaml", label = "YAML document" },
      { ext = "c", label = "C program" },
      { ext = "cpp", label = "C++ program" },
      { ext = "rs", label = "Rust program" },
      { ext = "go", label = "Go program" },
    }

    local function template_content(ext, name)
      local template = templates[ext]
      if not template then return nil end
      local stem = name:gsub("%.[^.]+$", "")
      local class_name = stem:gsub("^%l", string.upper):gsub("[^%w]", "")
      local ok, content = pcall(string.format, template, class_name, class_name)
      return ok and content or nil
    end

    local function apply_current_template(choice)
      local name = vim.fn.expand("%:t")
      if name == "" then name = "Main" end
      local content = template_content(choice.ext, name)
      if not content then
        notify("Template unavailable: " .. choice.ext, vim.log.levels.ERROR)
        return
      end

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local has_content = #lines > 1 or (lines[1] or "") ~= ""
      local function replace_buffer()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n", { plain = true }))
        vim.bo.modified = true
        notify("Loaded " .. choice.label .. " into current buffer")
      end
      if has_content then
        vim.ui.select({ "Replace buffer", "Cancel" }, {
          prompt = "Current buffer is not empty: ",
        }, function(action)
          if action == "Replace buffer" then replace_buffer() end
        end)
      else
        replace_buffer()
      end
    end

    _G.load_current_template = function()
      vim.ui.select(template_choices, {
        prompt = "Load template into current buffer: ",
        format_item = function(choice) return choice.label end,
      }, function(choice)
        if choice then apply_current_template(choice) end
      end)
    end

    local function create_file(path)
      path = vim.fn.expand(path)
      if path == "" or path == "/" then return end
      local dir = vim.fn.fnamemodify(path, ":h")
      if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
      local name = vim.fn.fnamemodify(path, ":t")
      local ext = name:match("%.([^.]+)$") or ""
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      local content = template_content(ext, name)
      if content then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n", { plain = true }))
      end
      vim.cmd("write")
      notify("Created: " .. path)
    end

    _G.advanced_new_file = function()
      Snacks.input({
        prompt = "New file path: ",
        default = vim.fn.expand("%:p:h") ~= "" and vim.fn.expand("%:p:h") .. "/" or vim.fn.getcwd() .. "/",
      }, function(value)
        if value and value ~= "" then create_file(value) end
      end)
    end

    _G.open_projects = function()
      local projects_dir = vim.fn.expand("$HOME") .. "/Projects"
      if vim.fn.isdirectory(projects_dir) == 0 then
        notify("Projects directory not found: " .. projects_dir, vim.log.levels.WARN)
        return
      end
      local items = {}
      local handle = vim.loop.fs_scandir(projects_dir)
      if handle then
        while true do
          local name, kind = vim.loop.fs_scandir_next(handle)
          if not name then break end
          if kind == "directory" and name:sub(1, 1) ~= "." then
            items[#items + 1] = { text = name, file = projects_dir .. "/" .. name }
          end
        end
      end
      table.sort(items, function(a, b) return a.text < b.text end)
      if #items == 0 then
        notify("No project folders found in " .. projects_dir, vim.log.levels.WARN)
        return
      end
      Snacks.picker.pick({
        title = "Projects",
        items = items,
        format = "file",
        confirm = function(picker, item)
          picker:close()
          if item and item.file then
            vim.cmd("cd " .. vim.fn.fnameescape(item.file))
            vim.cmd("Oil " .. vim.fn.fnameescape(item.file))
            notify("Opened project: " .. item.file)
          end
        end,
      })
    end

    _G.spring_boot_wizard = function()
      vim.ui.select({ "17", "21" }, { prompt = "Java version:" }, function(java_version)
        if not java_version then return end
        vim.ui.select({ "3.2.0", "3.3.0" }, { prompt = "Spring Boot version:" }, function(boot_version)
          if not boot_version then return end
          vim.ui.input({ prompt = "Group ID: ", default = "com.example" }, function(group)
            if not group then return end
            vim.ui.input({ prompt = "Artifact ID: ", default = "demo" }, function(artifact)
              if not artifact then return end
              vim.ui.input({ prompt = "Destination directory: ", default = vim.fn.getcwd() }, function(root)
                if not root or vim.fn.isdirectory(root) == 0 then
                  notify("Destination directory does not exist", vim.log.levels.ERROR)
                  return
                end
                local project = root .. "/" .. artifact
                local command = table.concat({
                  "curl -fsSL --fail https://start.spring.io/starter.tgz",
                  "-d type=maven-project",
                  "-d language=java",
                  "-d bootVersion=" .. vim.fn.shellescape(boot_version),
                  "-d baseDir=" .. vim.fn.shellescape(artifact),
                  "-d groupId=" .. vim.fn.shellescape(group),
                  "-d artifactId=" .. vim.fn.shellescape(artifact),
                  "-d javaVersion=" .. vim.fn.shellescape(java_version),
                  "| tar -xzf - -C " .. vim.fn.shellescape(root),
                }, " ")
                vim.fn.jobstart({ "sh", "-c", command }, {
                  on_exit = function(_, code)
                    vim.schedule(function()
                      if code == 0 then
                        vim.cmd("Oil " .. vim.fn.fnameescape(project))
                        notify("Spring Boot project created at: " .. project)
                      else
                        notify("Spring Boot generator failed with exit code " .. code, vim.log.levels.ERROR)
                      end
                    end)
                  end,
                })
              end)
            end)
          end)
        end)
      end)
    end
  '';

  autoCmd = [
    {
      event = "FileType";
      pattern = "snacks_dashboard";
      command = ''
        lua
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.cursorline = false
          vim.opt_local.signcolumn = "no"
          vim.opt_local.syntax = "off"
          vim.opt_local.scrolloff = 0
          vim.cmd("nohlsearch")
          pcall(function() require("illuminate").pause() end)
      '';
    }
    {
      event = "WinLeave";
      pattern = "*";
      command = ''
        lua
          pcall(function()
            if vim.bo.filetype ~= "snacks_dashboard" then
              require("illuminate").resume()
            end
          end)
      '';
    }
    {
      event = "VimEnter";
      pattern = "*";
      command = ''
        lua
          local original_open_float = vim.lsp.util.open_floating_preview
          vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or "rounded"
            return original_open_float(contents, syntax, opts, ...)
          end
          vim.diagnostic.config({
            float = { border = "rounded", source = true, header = "", prefix = "" },
            virtual_text = { prefix = "●", spacing = 4 },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
          })
          local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
          for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
          end
      '';
    }
  ];
}

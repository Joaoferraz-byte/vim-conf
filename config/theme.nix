{ ... }:
{
  extraConfigLua = ''
    local livara_theme_path = vim.fn.stdpath("config") .. "/matugen_colors.lua"

    local function set_livara_highlight(name, fg, bg, opts)
      local spec = vim.tbl_extend("force", opts or {}, {})
      if fg then spec.fg = fg end
      if bg then spec.bg = bg end
      vim.api.nvim_set_hl(0, name, spec)
    end

    local function clear_transparent_backgrounds()
      -- Only the editor canvas and structural separators are transparent.
      -- Float menus, completion menus and statusline segments retain bounded
      -- surfaces so contrast is not destroyed by a wallpaper reload.
      local groups = {
        "Normal", "NormalNC", "SignColumn", "FoldColumn", "Folded",
        "EndOfBuffer", "LineNr", "CursorLine", "ColorColumn", "Conceal",
        "NonText", "Whitespace", "VertSplit", "WinSeparator", "TabLine",
        "TabLineFill", "TabLineSel", "WinBar", "WinBarNC", "OilColumn",
        "OilDir", "OilDirIcon", "OilFile", "SnacksNormal", "SnacksBackdrop",
        "SnacksDashboardNormal", "SnacksPickerList", "SnacksPickerInput",
      }
      for _, group in ipairs(groups) do
        local current = vim.api.nvim_get_hl(0, { name = group, link = false })
        current.bg = nil
        current.ctermbg = nil
        vim.api.nvim_set_hl(0, group, current)
      end
    end

    local function apply_livara_theme()
      if vim.fn.filereadable(livara_theme_path) ~= 1 then return false end
      local ok, colors = pcall(dofile, livara_theme_path)
      if not ok or type(colors) ~= "table" then return false end

      vim.opt.background = "dark"
      vim.cmd("colorscheme habamax")
      set_livara_highlight("Normal", colors.text)
      set_livara_highlight("NormalNC", colors.text)
      set_livara_highlight("NormalFloat", colors.text, colors.surface0, { blend = 8 })
      set_livara_highlight("FloatBorder", colors.blue, colors.surface0, { blend = 8 })
      set_livara_highlight("CursorLine", nil, colors.surface0, { blend = 15 })
      set_livara_highlight("CursorLineNr", colors.blue, nil, { bold = true })
      set_livara_highlight("LineNr", colors.overlay1)
      set_livara_highlight("Comment", colors.overlay2, nil, { italic = true })
      set_livara_highlight("String", colors.green)
      set_livara_highlight("Function", colors.blue, nil, { bold = true })
      set_livara_highlight("Keyword", colors.mauve)
      set_livara_highlight("Type", colors.yellow)
      set_livara_highlight("Constant", colors.peach)
      set_livara_highlight("Number", colors.peach)
      set_livara_highlight("Identifier", colors.text)
      set_livara_highlight("Statement", colors.red)
      set_livara_highlight("Error", colors.red, nil, { bold = true })
      set_livara_highlight("DiagnosticError", colors.red)
      set_livara_highlight("DiagnosticWarn", colors.yellow)
      set_livara_highlight("DiagnosticInfo", colors.blue)
      set_livara_highlight("DiagnosticHint", colors.teal)
      set_livara_highlight("Pmenu", colors.text, colors.surface1, { blend = 8 })
      set_livara_highlight("PmenuSel", colors.on_primary, colors.primary, { bold = true })
      set_livara_highlight("StatusLine", colors.text, "NONE", { blend = 10 })
      set_livara_highlight("StatusLineNC", colors.overlay2, "NONE", { blend = 10 })
      set_livara_highlight("WinBar", colors.subtext1, "NONE", { blend = 18 })
      set_livara_highlight("WinBarNC", colors.overlay1, "NONE", { blend = 24 })
      set_livara_highlight("Visual", nil, colors.surface2, { blend = 12 })
      set_livara_highlight("Search", colors.on_secondary, colors.secondary, { bold = true })
      set_livara_highlight("IncSearch", colors.on_primary, colors.primary, { bold = true })

      local function set_lualine_group(name, fg, bg, blend, bold)
        vim.api.nvim_set_hl(0, name, {
          fg = fg,
          bg = bg,
          blend = blend or 0,
          bold = bold or false,
        })
      end

      set_lualine_group("LivaraLualineNormalA", colors.on_primary, colors.primary, 0, true)
      set_lualine_group("LivaraLualineNormalB", colors.text, colors.surface0, 18, false)
      set_lualine_group("LivaraLualineNormalC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineInsertA", colors.base, colors.green, 0, true)
      set_lualine_group("LivaraLualineInsertB", colors.text, colors.surface0, 18, false)
      set_lualine_group("LivaraLualineInsertC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineVisualA", colors.base, colors.mauve, 0, true)
      set_lualine_group("LivaraLualineVisualB", colors.text, colors.surface0, 18, false)
      set_lualine_group("LivaraLualineVisualC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineReplaceA", colors.base, colors.red, 0, true)
      set_lualine_group("LivaraLualineReplaceB", colors.text, colors.surface0, 18, false)
      set_lualine_group("LivaraLualineReplaceC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineCommandA", colors.base, colors.peach, 0, true)
      set_lualine_group("LivaraLualineCommandB", colors.text, colors.surface0, 18, false)
      set_lualine_group("LivaraLualineCommandC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineInactiveA", colors.subtext0, colors.surface0, 28, true)
      set_lualine_group("LivaraLualineInactiveB", colors.subtext0, colors.surface0, 28, false)
      set_lualine_group("LivaraLualineInactiveC", colors.subtext0, "NONE", 0, false)

      clear_transparent_backgrounds()
      vim.g.colors_name = "livara-matugen"
      pcall(function() require("lualine").refresh() end)
      return true
    end

    _G.reload_livara_theme = apply_livara_theme
    apply_livara_theme()

    vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
      group = vim.api.nvim_create_augroup("LivaraFillchars", { clear = true }),
      callback = function()
        vim.opt.fillchars:append("eob: ")
      end,
    })

    if not _G.livara_theme_watcher_started then
      _G.livara_theme_watcher_started = true
      local theme_dir = vim.fn.fnamemodify(livara_theme_path, ":h")
      local theme_file = vim.fn.fnamemodify(livara_theme_path, ":t")
      local watcher = vim.uv.new_fs_event()
      if watcher and vim.fn.isdirectory(theme_dir) == 1 then
        watcher:start(theme_dir, {}, vim.schedule_wrap(function(err, filename)
          if not err and (filename == nil or filename == theme_file) then
            apply_livara_theme()
            vim.cmd("redraw!")
          end
        end))
        vim.api.nvim_create_autocmd("VimLeavePre", {
          group = vim.api.nvim_create_augroup("LivaraThemeWatcher", { clear = true }),
          callback = function()
            if not watcher:is_closing() then
              watcher:stop()
              watcher:close()
            end
          end,
        })
      end
    end
  '';
}

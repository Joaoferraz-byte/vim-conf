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

    local function set_transparent_group(name, fg, blend)
      local current = vim.api.nvim_get_hl(0, { name = name, link = false })
      current.fg = fg or current.fg
      current.bg = "NONE"
      current.ctermbg = "NONE"
      current.blend = blend or 0
      vim.api.nvim_set_hl(0, name, current)
    end

    local function apply_transparency_policy(colors)
      -- The canvas and structural UI must reveal the compositor wallpaper.
      -- Popup surfaces remain translucent rather than opaque: this preserves
      -- readability while ensuring every interactive layer participates in the
      -- same wallpaper-backed visual hierarchy.
      local transparent = {
        "Normal", "NormalNC", "SignColumn", "FoldColumn", "Folded",
        "EndOfBuffer", "LineNr", "CursorLine", "CursorColumn", "ColorColumn",
        "Conceal", "NonText", "Whitespace", "VertSplit", "WinSeparator",
        "TabLine", "TabLineFill", "TabLineSel", "WinBar", "WinBarNC",
        "StatusLine", "StatusLineNC", "BufferLineFill", "BufferLineBackground",
        "OilColumn", "OilDir", "OilDirIcon", "OilFile", "OilType",
        "SnacksNormal", "SnacksBackdrop", "SnacksDashboardNormal",
        "SnacksDashboardFooter", "SnacksPickerList", "SnacksPickerInput",
        "SnacksPickerPreview", "SnacksInputNormal", "SnacksWin", "WhichKey",
        "WhichKeyGroup", "WhichKeyDesc", "WhichKeySeparator", "WhichKeyValue",
        "NoiceCmdlinePopup", "NoicePopup", "NoicePopupmenu", "LspFloatWinNormal",
        "BarbecueNormal", "BarbecueContext", "BarbecueDirname", "BarbecueFilename",
        "BarbecueSeparator", "BarbecueEllipsis", "BarbecueModified",
      }
      for _, group in ipairs(transparent) do
        set_transparent_group(group)
      end

      local translucent = {
        { "NormalFloat", colors.text, colors.surface0, 18 },
        { "FloatBorder", colors.primary, colors.surface0, 18 },
        { "Pmenu", colors.text, colors.surface1, 22 },
        { "PmenuSel", colors.on_primary, colors.primary, 8 },
        { "SnacksPickerBorder", colors.primary, colors.surface0, 20 },
        { "SnacksPickerPrompt", colors.text, colors.surface0, 16 },
        { "SnacksPickerPromptTitle", colors.primary, colors.surface0, 16 },
        { "SnacksPickerPreviewBorder", colors.secondary, colors.surface0, 20 },
        { "SnacksPickerListCursorLine", colors.text, colors.surface2, 18 },
        { "SnacksInputBorder", colors.primary, colors.surface0, 20 },
        { "SnacksInputTitle", colors.primary, colors.surface0, 18 },
        { "WhichKeyFloat", colors.text, colors.surface0, 20 },
        { "WhichKeyBorder", colors.primary, colors.surface0, 20 },
        { "NoiceCmdlinePopupBorder", colors.primary, colors.surface0, 20 },
        { "NoicePopupBorder", colors.primary, colors.surface0, 20 },
        { "NoicePopupmenuBorder", colors.primary, colors.surface0, 20 },
        { "LspFloatWinBorder", colors.primary, colors.surface0, 20 },
        { "OilFloat", colors.text, colors.surface0, 18 },
        { "OilFloatBorder", colors.primary, colors.surface0, 20 },
        { "BarbecueFilename", colors.text, "NONE", 0 },
        { "BufferLineIndicatorSelected", colors.primary, "NONE", 0 },
      }
      for _, item in ipairs(translucent) do
        set_livara_highlight(item[1], item[2], item[3], { blend = item[4] })
      end

      -- These groups are commonly linked by plugins after colorscheme load;
      -- explicit links keep their backgrounds consistent on every reload.
      local links = {
        SnacksPickerInputBorder = "SnacksPickerBorder",
        SnacksPickerPreviewTitle = "SnacksPickerPromptTitle",
        SnacksPickerListCursorLineNr = "CursorLineNr",
        SnacksPickerSelected = "PmenuSel",
        SnacksPickerMatch = "Search",
        SnacksInputIcon = "SnacksPickerPromptTitle",
        WhichKeyIcon = "SnacksPickerPromptTitle",
        NoiceCmdlineIcon = "SnacksPickerPromptTitle",
        NoiceCmdlineIcon2 = "SnacksPickerPromptTitle",
      }
      for target, source in pairs(links) do
        vim.api.nvim_set_hl(0, target, { link = source })
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

      apply_transparency_policy(colors)
      vim.g.colors_name = "livara-matugen"
      pcall(function() require("lualine").refresh() end)
      return true
    end

    _G.reload_livara_theme = apply_livara_theme
    apply_livara_theme()

    vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "ColorScheme" }, {
      group = vim.api.nvim_create_augroup("LivaraFillchars", { clear = true }),
      callback = function(args)
        vim.opt.fillchars:append("eob: ")
        if args.event == "VimEnter" or args.event == "UIEnter" then
          vim.defer_fn(function()
            pcall(apply_livara_theme)
            vim.cmd("redraw!")
          end, 50)
        end
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

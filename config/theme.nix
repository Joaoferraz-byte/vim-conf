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

    local function theme_color(colors, key, fallback)
      return colors[key] or (fallback and colors[fallback]) or colors.text or "#e1e2e8"
    end

    -- bufferline and barbecue create per-icon groups lazily. Clear only those
    -- generated groups, plus the ordinal-number groups, instead of flattening
    -- every plugin surface into the terminal background.
    local function clear_generated_icon_backgrounds()
      local static_groups = {
        "BufferLineNumbers",
        "BufferLineNumbersVisible",
        "BufferLineNumbersSelected",
        "BufferLineCloseButton",
        "BufferLineCloseButtonVisible",
        "BufferLineCloseButtonSelected",
        "BufferLineTabClose",
        "BufferLineTabCloseVisible",
        "BufferLineTabCloseSelected",
      }
      for _, group in ipairs(static_groups) do
        set_transparent_group(group)
      end

      local generated_prefixes = {
        "BufferLineDevIcon",
        "BufferLineCloseButton",
        "barbecue_fileicon_",
      }
      for _, prefix in ipairs(generated_prefixes) do
        for _, group in ipairs(vim.fn.getcompletion(prefix, "highlight")) do
          if group:sub(1, #prefix) == prefix then
            set_transparent_group(group)
          end
        end
      end
    end

    local function apply_transparency_policy(colors)
      -- The canvas and structural UI must reveal the compositor wallpaper.
      -- Popup surfaces remain translucent rather than opaque: this preserves
      -- readability while ensuring every interactive layer participates in the
      -- same wallpaper-backed visual hierarchy.
      local transparent = {
        "Normal", "NormalNC", "SignColumn", "FoldColumn", "Folded",
        "EndOfBuffer", "LineNr", "CursorColumn", "ColorColumn",
        "Conceal", "NonText", "Whitespace", "VertSplit", "WinSeparator",
        "TabLine", "TabLineFill", "TabLineSel", "WinBar", "WinBarNC",
        "StatusLine", "StatusLineNC", "StatusLineTerm", "StatusLineTermNC",
        "BufferLineFill", "BufferLineBackground", "BufferLineTab",
        "MsgArea", "ModeMsg", "MoreMsg", "Question", "Title", "Directory",
        "WildMenu", "MatchParen", "QuickFixLine", "CursorLineSign", "CursorLineFold",
        "PmenuSbar", "PmenuThumb", "OilColumn", "OilDir", "OilDirIcon", "OilFile", "OilType",
        "SnacksNormal", "SnacksBackdrop", "SnacksDashboardNormal", "SnacksDashboardFooter",
        "SnacksPickerList", "SnacksPickerInput", "SnacksPickerPreview", "SnacksPickerBox",
        "SnacksPickerHeader", "SnacksPickerPrompt", "SnacksPickerPromptPrefix",
        "SnacksPickerInputSearch", "SnacksPickerInputIcon", "SnacksPickerInputTitle",
        "SnacksPickerListBorder", "SnacksPickerPreviewTitle", "SnacksPickerMatch",
        "SnacksPickerDir", "SnacksPickerFile", "SnacksPickerRow", "SnacksPickerCursorLine",
        "SnacksInputNormal", "SnacksWin", "WhichKey",
        "WhichKeyGroup", "WhichKeyDesc", "WhichKeySeparator", "WhichKeyValue",
        "NoiceCmdlinePopup", "NoicePopup", "NoicePopupmenu", "NoiceMini",
        "NoiceFormatProgressDone", "NoiceFormatProgressTodo", "LspFloatWinNormal",
        "barbecue_normal", "barbecue_context", "barbecue_dirname", "barbecue_basename",
        "barbecue_separator", "barbecue_ellipsis", "barbecue_modified",
        "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer", "NeoTreeWinSeparator",
        "NeoTreeFloatNormal", "NeoTreeFloatBorder", "NeoTreeTabInactive", "NeoTreeTabActive",
        "NeoTreeDirectoryName", "NeoTreeFileName", "NeoTreeRootName", "NeoTreeGitModified",
        "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeWinSeparator", "NvimTreeEndOfBuffer",
        "BufferLineFill", "BufferLineBackground", "BufferLineBuffer", "BufferLineBufferVisible",
        "BufferLineBufferSelected", "BufferLineTab", "BufferLineTabSelected", "BufferLineTabClose",
        "BufferLineCloseButton", "BufferLineCloseButtonVisible", "BufferLineModified", "BufferLineModifiedSelected",
        "BufferLineSeparator", "BufferLineSeparatorSelected", "BufferLineIndicatorSelected",
        "AerialNormal", "AerialLine", "AerialGuide", "TroubleNormal", "TroubleText",
        "TroubleCount", "TroubleIndent", "FidgetNormal", "RenderMarkdownCode", "RenderMarkdownCodeInfo",
        "CmpNormal", "CmpDocNormal", "CmpBorder", "LazyNormal", "MasonNormal",
        "SnacksDashboardHeader", "SnacksDashboardTitle", "SnacksDashboardDesc", "SnacksDashboardKey",
        "SnacksDashboardIcon", "SnacksDashboardFile", "SnacksDashboardDir", "SnacksDashboardSpecial",
        "SnacksDashboardSection", "SnacksPickerInputBorder", "SnacksPickerListBorder",
        "SnacksPickerPreviewBorder", "SnacksPickerPromptTitle", "SnacksPickerPromptIcon",
        "SnacksPickerListCursorLine", "SnacksPickerListCursorLineNr", "SnacksPickerSelected",
        "SnacksPickerPath", "SnacksPickerLabel", "SnacksPickerToggle", "SnacksPickerTree",
      }
      for _, group in ipairs(transparent) do
        set_transparent_group(group)
      end

      local translucent = {
        { "NormalFloat", colors.text, "NONE", 0 },
        { "FloatBorder", colors.primary, "NONE", 0 },
        -- Completion and active selections retain a readable surface; all
        -- structural/plugin containers reveal the terminal canvas.
        { "Pmenu", colors.text, colors.surface1, 22 },
        { "PmenuSel", colors.on_primary, colors.primary, 8 },
        { "SnacksPicker", colors.text, "NONE", 0 },
        { "SnacksPickerTitle", colors.text, "NONE", 0 },
        { "SnacksPickerBorder", colors.primary, "NONE", 0 },
        { "SnacksPickerInputTitle", colors.text, "NONE", 0 },
        { "SnacksPickerInputBorder", colors.primary, "NONE", 0 },
        { "SnacksPickerPromptTitle", colors.text, "NONE", 0 },
        { "SnacksPickerPreview", colors.text, "NONE", 0 },
        { "SnacksPickerPreviewBorder", colors.secondary, "NONE", 0 },
        { "SnacksPickerPreviewTitle", colors.text, "NONE", 0 },
        { "SnacksPickerListCursorLine", colors.text, colors.surface2, 18 },
        { "SnacksInputBorder", colors.primary, "NONE", 0 },
        { "SnacksInputTitle", colors.primary, "NONE", 0 },
        { "SnacksInputPrompt", colors.text, "NONE", 0 },
        { "SnacksInputIcon", colors.primary, "NONE", 0 },
        { "WhichKeyBorder", colors.primary, "NONE", 0 },
        { "WhichKeyTitle", colors.primary, "NONE", 0 },
        { "WhichKeyDesc", colors.text, "NONE", 0 },
        { "WhichKeyGroup", colors.secondary, "NONE", 0 },
        { "WhichKeySeparator", colors.overlay1, "NONE", 0 },
        { "WhichKeyValue", colors.subtext0, "NONE", 0 },
        { "WhichKeyIcon", colors.primary, "NONE", 0 },
        { "NoiceCmdlinePopupBorder", colors.primary, "NONE", 0 },
        { "NoicePopupBorder", colors.primary, "NONE", 0 },
        { "NoicePopupmenuBorder", colors.primary, "NONE", 0 },
        { "LspFloatWinBorder", colors.primary, "NONE", 0 },
        { "OilFloat", colors.text, "NONE", 0 },
        { "OilFloatBorder", colors.primary, "NONE", 0 },
        { "BarbecueFilename", colors.text, "NONE", 0 },
        { "BufferLineIndicatorSelected", colors.primary, "NONE", 0 },
        { "NeoTreeFloatBorder", colors.primary, "NONE", 0 },
        { "NeoTreeRootName", colors.text, "NONE", 0 },
        { "SnacksPickerPromptTitle", colors.text, "NONE", 0 },
        { "SnacksPickerPromptIcon", colors.primary, "NONE", 0 },
        { "WhichKeyFloat", colors.text, "NONE", 0 },
        { "WhichKeyNormal", colors.text, "NONE", 0 },
      }
      for _, item in ipairs(translucent) do
        set_livara_highlight(item[1], item[2], item[3], { blend = item[4] })
      end

      -- These groups are commonly linked by plugins after colorscheme load;
      -- explicit links keep their backgrounds consistent on every reload.
      local links = {
        SnacksPickerListBorder = "SnacksPickerBorder",
        SnacksPickerListCursorLineNr = "CursorLineNr",
        SnacksPickerSelected = "PmenuSel",
        SnacksInputIcon = "SnacksPickerPromptTitle",
        WhichKeyIcon = "SnacksPickerPromptTitle",
        NoiceCmdlineIcon = "SnacksPickerPromptTitle",
        NoiceCmdlineIcon2 = "SnacksPickerPromptTitle",
      }
      for target, source in pairs(links) do
        vim.api.nvim_set_hl(0, target, { link = source })
      end

      clear_generated_icon_backgrounds()
    end

    local function apply_livara_theme()
      if vim.fn.filereadable(livara_theme_path) ~= 1 then
        vim.notify("Livara Matugen palette not found: " .. livara_theme_path, vim.log.levels.WARN)
        return false
      end
      local ok, colors = pcall(dofile, livara_theme_path)
      if not ok then
        vim.notify("Livara Matugen palette could not be loaded: " .. tostring(colors), vim.log.levels.ERROR)
        return false
      end
      if type(colors) ~= "table" then
        vim.notify("Livara Matugen palette did not return a Lua table", vim.log.levels.ERROR)
        return false
      end

      vim.opt.background = "dark"
      -- Load a neutral built-in baseline only once. Re-running :colorscheme
      -- from the ColorScheme autocmd would recursively schedule this function
      -- and could overwrite the dynamic palette after every wallpaper change.
      if vim.g.livara_base_colorscheme_loaded ~= true then
        vim.g.livara_base_colorscheme_loaded = true
        pcall(vim.cmd, "colorscheme habamax")
      end
      set_livara_highlight("Normal", colors.text, "NONE")
      set_livara_highlight("NormalNC", colors.text, "NONE")
      set_livara_highlight("NormalFloat", colors.text, "NONE")
      set_livara_highlight("FloatBorder", colors.primary, "NONE")
      set_livara_highlight("CursorLine", nil, colors.surface0, { blend = 15 })
      set_livara_highlight("CursorLineNr", colors.blue, nil, { bold = true })
      set_livara_highlight("LineNr", colors.overlay1)
      set_livara_highlight("Comment", theme_color(colors, "overlay2", "overlay1"), nil, { italic = true })
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
      set_livara_highlight("Pmenu", colors.text, colors.surface1, { blend = 22 })
      set_livara_highlight("PmenuSel", colors.on_primary, colors.primary, { bold = true })
      set_livara_highlight("StatusLine", colors.text, "NONE")
      set_livara_highlight("StatusLineNC", theme_color(colors, "subtext1", "subtext0"), "NONE")
      set_livara_highlight("WinBar", colors.text, "NONE")
      set_livara_highlight("WinBarNC", colors.subtext0, "NONE")
      set_livara_highlight("TabLine", colors.text, "NONE")
      set_livara_highlight("TabLineFill", colors.text, "NONE")
      set_livara_highlight("TabLineSel", colors.text, "NONE", { bold = true })
      set_livara_highlight("Directory", colors.text, "NONE")
      set_livara_highlight("Visual", nil, colors.surface2, { blend = 12 })
      set_livara_highlight("Search", theme_color(colors, "on_secondary", "on_surface"), colors.secondary, { bold = true })
      set_livara_highlight("IncSearch", colors.on_primary, colors.primary, { bold = true })

      -- Snacks defaults intentionally use separate semantic groups. Keep
      -- dashboard prose white/readable; reserve Matugen colors for icons, keys,
      -- headers and active selections instead of tinting all descriptions blue.
      set_livara_highlight("SnacksDashboardNormal", colors.text, "NONE")
      set_livara_highlight("SnacksDashboardHeader", colors.text, "NONE", { bold = true })
      set_livara_highlight("SnacksDashboardTitle", colors.text, "NONE", { bold = true })
      set_livara_highlight("SnacksDashboardDesc", colors.text, "NONE")
      set_livara_highlight("SnacksDashboardFile", colors.text, "NONE")
      set_livara_highlight("SnacksDashboardDir", colors.subtext1 or colors.subtext0, "NONE")
      set_livara_highlight("SnacksDashboardKey", colors.secondary, "NONE", { bold = true })
      set_livara_highlight("SnacksDashboardIcon", colors.primary, "NONE")
      set_livara_highlight("SnacksDashboardSpecial", colors.tertiary, "NONE")
      set_livara_highlight("SnacksDashboardFooter", colors.subtext0, "NONE")
      set_livara_highlight("SnacksPicker", colors.text, "NONE")
      set_livara_highlight("SnacksPickerTitle", colors.text, "NONE", { bold = true })
      set_livara_highlight("SnacksPickerPrompt", colors.text, "NONE")
      set_livara_highlight("SnacksPickerPromptPrefix", colors.primary, "NONE")
      set_livara_highlight("SnacksPickerInput", colors.text, "NONE")
      set_livara_highlight("SnacksPickerInputTitle", colors.text, "NONE", { bold = true })
      set_livara_highlight("SnacksPickerInputBorder", colors.primary, "NONE")
      set_livara_highlight("SnacksPickerList", colors.text, "NONE")
      set_livara_highlight("SnacksPickerPreview", colors.text, "NONE")
      set_livara_highlight("SnacksPickerPreviewBorder", colors.secondary, "NONE")
      set_livara_highlight("SnacksPickerDir", colors.subtext0, "NONE")
      set_livara_highlight("SnacksPickerFile", colors.text, "NONE")
      set_livara_highlight("SnacksPickerPath", colors.subtext0, "NONE")
      set_livara_highlight("SnacksPickerLabel", colors.text, "NONE")
      set_livara_highlight("SnacksPickerDesc", colors.subtext0, "NONE")
      set_livara_highlight("SnacksPickerMatch", colors.primary, "NONE")
      set_livara_highlight("NeoTreeNormal", colors.text, "NONE")
      set_livara_highlight("NeoTreeNormalNC", colors.subtext0, "NONE")
      set_livara_highlight("BufferLineBackground", colors.subtext0, "NONE")
      set_livara_highlight("BufferLineBufferSelected", colors.text, "NONE", { bold = true })
      -- barbecue.nvim owns the winbar with lowercase highlight names. The
      -- previous Barbecue* names were never created by the plugin, so the
      -- path row kept the default style after every palette reload.
      set_livara_highlight("barbecue_normal", colors.text, "NONE")
      set_livara_highlight("barbecue_ellipsis", colors.subtext0, "NONE")
      set_livara_highlight("barbecue_separator", colors.overlay1, "NONE")
      set_livara_highlight("barbecue_modified", colors.tertiary, "NONE", { bold = true })
      set_livara_highlight("barbecue_dirname", colors.subtext0, "NONE")
      set_livara_highlight("barbecue_basename", colors.text, "NONE", { bold = true })
      set_livara_highlight("barbecue_context", colors.text, "NONE")
      set_livara_highlight("barbecue_context_file", colors.primary, "NONE")
      set_livara_highlight("barbecue_context_module", colors.secondary, "NONE")
      set_livara_highlight("barbecue_context_namespace", colors.secondary, "NONE")
      set_livara_highlight("barbecue_context_package", colors.tertiary, "NONE")
      set_livara_highlight("barbecue_context_class", colors.yellow, "NONE")
      set_livara_highlight("barbecue_context_method", colors.blue, "NONE")
      set_livara_highlight("barbecue_context_function", colors.blue, "NONE")
      set_livara_highlight("barbecue_context_variable", colors.text, "NONE")
      set_livara_highlight("barbecue_context_constant", colors.peach, "NONE")

      local function set_lualine_group(name, fg, bg, blend, bold)
        vim.api.nvim_set_hl(0, name, {
          fg = fg,
          bg = bg,
          blend = blend or 0,
          bold = bold or false,
        })
      end

      set_lualine_group("LivaraLualineNormalA", colors.on_primary, colors.primary, 0, true)
      set_lualine_group("LivaraLualineNormalB", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineNormalC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineInsertA", colors.base, colors.green, 0, true)
      set_lualine_group("LivaraLualineInsertB", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineInsertC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineVisualA", colors.base, colors.mauve, 0, true)
      set_lualine_group("LivaraLualineVisualB", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineVisualC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineReplaceA", colors.base, colors.red, 0, true)
      set_lualine_group("LivaraLualineReplaceB", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineReplaceC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineCommandA", colors.base, colors.peach, 0, true)
      set_lualine_group("LivaraLualineCommandB", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineCommandC", colors.text, "NONE", 0, false)
      set_lualine_group("LivaraLualineInactiveA", theme_color(colors, "subtext1", "subtext0"), "NONE", 0, true)
      set_lualine_group("LivaraLualineInactiveB", colors.subtext0, "NONE", 0, false)
      set_lualine_group("LivaraLualineInactiveC", colors.subtext0, "NONE", 0, false)

      -- lualine owns its generated lualine_* highlight groups. Supplying
      -- concrete colors here is more reliable than linking a section to a
      -- group that may be created after lualine initializes. It also keeps
      -- the footer transparent on every wallpaper reload.
      local function lualine_section(fg, bg, bold)
        return { fg = fg, bg = bg, gui = bold and "bold" or nil }
      end
      local lualine_theme = {
        normal = {
          a = lualine_section(colors.on_primary, colors.primary, true),
          b = lualine_section(colors.text, "NONE", false),
          c = lualine_section(colors.text, "NONE", false),
          x = lualine_section(colors.text, "NONE", false),
          y = lualine_section(colors.text, "NONE", false),
          z = lualine_section(colors.on_primary, colors.primary, true),
        },
        insert = {
          a = lualine_section(colors.base, colors.green, true),
          b = lualine_section(colors.text, "NONE", false),
          c = lualine_section(colors.text, "NONE", false),
          x = lualine_section(colors.text, "NONE", false),
          y = lualine_section(colors.text, "NONE", false),
          z = lualine_section(colors.base, colors.green, true),
        },
        visual = {
          a = lualine_section(colors.base, colors.mauve, true),
          b = lualine_section(colors.text, "NONE", false),
          c = lualine_section(colors.text, "NONE", false),
          x = lualine_section(colors.text, "NONE", false),
          y = lualine_section(colors.text, "NONE", false),
          z = lualine_section(colors.base, colors.mauve, true),
        },
        replace = {
          a = lualine_section(colors.base, colors.red, true),
          b = lualine_section(colors.text, "NONE", false),
          c = lualine_section(colors.text, "NONE", false),
          x = lualine_section(colors.text, "NONE", false),
          y = lualine_section(colors.text, "NONE", false),
          z = lualine_section(colors.base, colors.red, true),
        },
        command = {
          a = lualine_section(colors.base, colors.peach, true),
          b = lualine_section(colors.text, "NONE", false),
          c = lualine_section(colors.text, "NONE", false),
          x = lualine_section(colors.text, "NONE", false),
          y = lualine_section(colors.text, "NONE", false),
          z = lualine_section(colors.base, colors.peach, true),
        },
        inactive = {
          a = lualine_section(colors.subtext0, "NONE", true),
          b = lualine_section(colors.subtext0, "NONE", false),
          c = lualine_section(colors.subtext0, "NONE", false),
          x = lualine_section(colors.subtext0, "NONE", false),
          y = lualine_section(colors.subtext0, "NONE", false),
          z = lualine_section(colors.subtext0, "NONE", true),
        },
      }

      apply_transparency_policy(colors)
      pcall(function()
        local lualine = require("lualine")
        lualine.setup({ options = { theme = lualine_theme } })
        lualine.refresh({ force = true })
      end)
      -- lualine may recreate StatusLine after the general policy; restate the
      -- canvas groups after setup so the terminal background remains visible.
      vim.api.nvim_set_hl(0, "StatusLine", { fg = colors.text, bg = "NONE" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { fg = theme_color(colors, "subtext1", "subtext0"), bg = "NONE" })
      vim.g.colors_name = "livara-matugen"
      pcall(function() require("lualine").refresh() end)
      return true
    end

    _G.reload_livara_theme = apply_livara_theme
    apply_livara_theme()

    local livara_autocmd_group = vim.api.nvim_create_augroup("LivaraFillchars", { clear = true })
    vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter" }, {
      group = livara_autocmd_group,
      callback = function()
        vim.opt.fillchars:append("eob: ")
        vim.defer_fn(function()
          pcall(apply_livara_theme)
          vim.cmd("redraw!")
        end, 150)
      end,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = livara_autocmd_group,
      callback = function()
        vim.schedule(function()
          pcall(apply_livara_theme)
          vim.cmd("redraw!")
        end)
      end,
    })
    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
      group = livara_autocmd_group,
      callback = function()
        -- Both plugins create file-icon groups during their first render.
        vim.schedule(clear_generated_icon_backgrounds)
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      group = livara_autocmd_group,
      pattern = "VeryLazy",
      callback = function()
        vim.opt.fillchars:append("eob: ")
        pcall(apply_livara_theme)
        vim.cmd("redraw!")
      end,
    })
    vim.api.nvim_create_autocmd("FocusGained", {
      group = livara_autocmd_group,
      callback = function()
        pcall(apply_livara_theme)
        vim.cmd("redraw!")
      end,
    })

    if not _G.livara_theme_watcher_started then
      _G.livara_theme_watcher_started = true
      local theme_dir = vim.fn.fnamemodify(livara_theme_path, ":h")
      local watcher = vim.uv.new_fs_event()
      if watcher and vim.fn.isdirectory(theme_dir) == 1 then
        watcher:start(theme_dir, {}, vim.schedule_wrap(function(err)
          -- The sync service writes a temporary file and atomically renames it;
          -- libuv may report the temporary basename or a nil filename. Watching
          -- the directory and debouncing avoids missing wallpaper updates.
          if not err then
            vim.defer_fn(function()
              if vim.fn.filereadable(livara_theme_path) == 1 then
                apply_livara_theme()
                vim.cmd("redraw!")
              end
            end, 100)
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

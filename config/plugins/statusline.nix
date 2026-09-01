{
  extraConfigLua = ''
    local LivaraBar = {}

    local hidden_filetypes = {
      snacks_dashboard = true,
      snacks_picker_list = true,
      snacks_picker_preview = true,
      oil = true,
      help = true,
      qf = true,
    }

    -- The mode is the only colored surface. This is intentionally fixed rather
    -- than palette-derived: it remains a stable visual anchor while Matugen
    -- changes the rest of the editor's foregrounds.
    local MODE_BG = "#ff6b9d"
    local MODE_FG = "#17131b"
    local MODE_ICON = "#fff2f7"

    local mode_icons = {
      n = "",
      i = "󰏫",
      v = "󰈈",
      V = "󰈈",
      ["\22"] = "󰈈",
      c = "",
      R = "󰛔",
      t = "",
      s = "󰈈",
      S = "󰈈",
    }

    local mode_names = {
      n = "NORMAL",
      i = "INSERT",
      v = "VISUAL",
      V = "V-LINE",
      ["\22"] = "V-BLOCK",
      c = "COMMAND",
      R = "REPLACE",
      t = "TERM",
      s = "SELECT",
      S = "S-LINE",
    }

    local diagnostic_icons = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌵",
    }

    local diagnostic_groups = {
      [vim.diagnostic.severity.ERROR] = "LivaraStatusError",
      [vim.diagnostic.severity.WARN] = "LivaraStatusWarn",
      [vim.diagnostic.severity.INFO] = "LivaraStatusInfo",
      [vim.diagnostic.severity.HINT] = "LivaraStatusHint",
    }

    local function highlight(name, spec)
      vim.api.nvim_set_hl(0, name, spec)
    end

    local function set_statusline_highlights()
      -- Mode geometry keeps the original left edge and uses the right
      -- rounded separator to give the colored island more vertical presence.
      -- Text size and horizontal spacing remain unchanged.
      highlight("LivaraModeEdge", { fg = MODE_BG, bg = "NONE" })
      highlight("LivaraModeIcon", { fg = MODE_ICON, bg = MODE_BG, bold = true })
      highlight("LivaraModeText", { fg = MODE_FG, bg = MODE_BG, bold = true })
      highlight("LivaraModeTail", { fg = MODE_BG, bg = "NONE", bold = true })

      highlight("StatusLine", { fg = "NONE", bg = "NONE" })
      highlight("StatusLineNC", { fg = "NONE", bg = "NONE" })
      highlight("WinBar", { fg = "NONE", bg = "NONE" })
      highlight("WinBarNC", { fg = "NONE", bg = "NONE" })
    end

    local function escape(value)
      return (value or ""):gsub("%%", "%%%%")
    end

    local function current_mode()
      local raw = vim.fn.mode()
      return mode_names[raw] or raw:upper()
    end

    local function current_mode_icon()
      return mode_icons[vim.fn.mode()] or "󰘧"
    end

    local function mode_segment()
      return "%#LivaraModeEdge#▎%#LivaraModeIcon# "
        .. current_mode_icon()
        .. " %#LivaraModeText#"
        .. current_mode()
        .. " %#LivaraModeTail#%#LivaraStatusText#"
    end

    local function separator()
      return "%#LivaraStatusMuted#  ·  %#LivaraStatusText#"
    end

    local function git_component()
      local git = vim.b.gitsigns_status_dict or {}
      if not git.head or git.head == "" then return "" end
      local changed = (tonumber(git.added or 0) or 0)
        + (tonumber(git.changed or 0) or 0)
        + (tonumber(git.removed or 0) or 0)
      local result = "%#LivaraStatusGit#%#LivaraStatusText# " .. escape(git.head)
      if changed > 0 then
        result = result .. "%#LivaraStatusMuted#  " .. changed
      end
      return result
    end

    local function diagnostics_component()
      local counts = {}
      for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        local severity = diagnostic.severity
        if severity then counts[severity] = (counts[severity] or 0) + 1 end
      end

      local parts = {}
      for severity = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.HINT do
        if counts[severity] then
          parts[#parts + 1] = string.format(
            "%%#%s#%s %d",
            diagnostic_groups[severity],
            " " .. diagnostic_icons[severity] .. " ",
            counts[severity]
          )
        end
      end
      return table.concat(parts, "%#LivaraStatusMuted# · ")
    end

    -- Keep every right-side icon in the same one-space envelope. This is
    -- intentionally shared instead of hand-spacing each component: Nerd Font
    -- glyphs have different advance widths, but their statusline baseline and
    -- optical breathing room must remain identical.
    local function right_icon(glyph)
      return "%#LivaraStatusAccent# " .. glyph .. " %#LivaraStatusText#"
    end

    local function lsp_component()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then return "" end
      local names = {}
      for _, client in ipairs(clients) do
        names[#names + 1] = client.name
      end
      table.sort(names)
      return right_icon("󰒋") .. escape(names[1])
    end

    local function line_count_component()
      local count = vim.api.nvim_buf_line_count(0)
      return right_icon("󰧳") .. count
    end

    local function position_component()
      return right_icon("󰆧") .. "%l:%c"
    end

    local function file_icon()
      local name = vim.fn.expand("%:t")
      local fallback = "%#LivaraStatusAccent#󰈙%#LivaraStatusText#"
      if name == "" then return fallback end

      local ok, MiniIcons = pcall(require, "mini.icons")
      if not ok then return fallback end
      local glyph, group = MiniIcons.get("file", name)
      if not glyph then return fallback end
      return "%#" .. (group or "LivaraStatusAccent") .. "#" .. glyph .. "%#LivaraStatusText#"
    end

    local function file_name()
      local name = vim.fn.expand("%:t")
      if name == "" then name = "[No Name]" end
      return escape(name)
    end

    local function file_directory()
      local path = vim.fn.expand("%:p:h")
      if path == "" then return "" end
      path = vim.fn.fnamemodify(path, ":~:.")
      return escape(path)
    end

    local function modified_marker()
      if not vim.bo.modified then return "" end
      return "%#LivaraStatusWarn# ●%#LivaraStatusText#"
    end

    local function narrow_statusline(width)
      local left = { mode_segment() }
      local git = git_component()
      if git ~= "" and width >= 90 then left[#left + 1] = separator() .. git end

      local right = {}
      local diagnostics = diagnostics_component()
      if diagnostics ~= "" then right[#right + 1] = diagnostics end
      if width >= 110 then
        local lsp = lsp_component()
        if lsp ~= "" then right[#right + 1] = lsp end
      end
      if width >= 75 then right[#right + 1] = line_count_component() end
      right[#right + 1] = position_component()

      return " " .. table.concat(left, "") .. "%=" .. table.concat(right, separator()) .. " "
    end

    function LivaraBar.statusline()
      if hidden_filetypes[vim.bo.filetype] then return "" end
      set_statusline_highlights()
      return narrow_statusline(vim.api.nvim_win_get_width(0))
    end

    function LivaraBar.winbar()
      if hidden_filetypes[vim.bo.filetype] then return "" end
      set_statusline_highlights()
      local directory = file_directory()
      local context = directory ~= "" and (separator() .. directory) or ""
      return " " .. file_icon() .. " " .. file_name() .. modified_marker() .. context .. " "
    end

    -- Theme reloads call this stable public hook. It only restores fixed mode
    -- geometry and transparent canvas groups; Matugen owns semantic text hues.
    _G.livara_statusline_activate = set_statusline_highlights
    _G.LivaraBar = LivaraBar

    local group = vim.api.nvim_create_augroup("LivaraMinimalBars", { clear = true })
    vim.api.nvim_create_autocmd({
      "BufEnter",
      "BufWinEnter",
      "BufFilePost",
      "WinEnter",
      "DirChanged",
      "DiagnosticChanged",
      "LspAttach",
      "LspDetach",
      "ModeChanged",
      "BufModifiedSet",
    }, {
      group = group,
      callback = function() vim.cmd("redrawstatus") end,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = function()
        set_statusline_highlights()
        vim.cmd("redrawstatus")
      end,
    })

    vim.o.showmode = false
    vim.o.laststatus = 3
    vim.o.statusline = "%!v:lua.LivaraBar.statusline()"
    vim.o.winbar = "%!v:lua.LivaraBar.winbar()"
    set_statusline_highlights()
  '';
}

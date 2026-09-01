{ ... }:
{
  # Statusline and winbar intentionally live together: both are renderers for
  # the same window state, and no other plugin is allowed to own either option.
  extraConfigLua = ''
    local LivaraStatusline = {}
    local LivaraWinbar = {}
    local disabled_filetypes = {
      snacks_dashboard = true,
      snacks_picker_list = true,
      oil = true,
      help = true,
    }

    local function rgb(value, fallback)
      return value and string.format("#%06x", value) or fallback
    end

    local function group_fg(group, fallback)
      local spec = vim.api.nvim_get_hl(0, { name = group, link = false })
      return rgb(spec.fg, fallback)
    end

    local function highlight(name, fg, opts)
      vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", { bg = "NONE", fg = fg }, opts or {}))
    end

    local function prepare_highlights()
      highlight("LivaraStatusText", group_fg("Normal", "#e1e2e8"))
      highlight("LivaraStatusMuted", group_fg("Comment", "#a6a8b3"), { italic = true })
      highlight("LivaraStatusAccent", group_fg("Directory", "#c3adff"), { bold = true })
      highlight("LivaraStatusError", group_fg("DiagnosticError", "#ff7a90"))
      highlight("LivaraStatusWarn", group_fg("DiagnosticWarn", "#f5d782"))
      highlight("LivaraStatusInfo", group_fg("DiagnosticInfo", "#8fc7ff"))
      highlight("LivaraStatusHint", group_fg("DiagnosticHint", "#8ee6b0"))
      highlight("LivaraStatusGit", group_fg("Directory", "#c3adff"))
      highlight("LivaraStatusLocation", group_fg("LineNr", "#a6a8b3"))
      highlight("LivaraWinbarText", group_fg("Normal", "#e1e2e8"))
      highlight("LivaraWinbarMuted", group_fg("Comment", "#a6a8b3"), { italic = true })
      highlight("LivaraWinbarAccent", group_fg("Directory", "#c3adff"), { bold = true })
    end

    local function escape_statusline(value)
      return (value or ""):gsub("%%", "%%%%")
    end

    local function current_buffer()
      local winid = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
      if not vim.api.nvim_win_is_valid(winid) then return 0 end
      return vim.api.nvim_win_get_buf(winid)
    end

    local function fileinfo_component()
      local buffer = current_buffer()
      local name = vim.api.nvim_buf_get_name(buffer)
      name = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "Empty"
      local filetype = vim.bo[buffer].filetype
      local icon = "󰈚"
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if ok then
        icon = devicons.get_icon(vim.fn.fnamemodify(name, ":t"), filetype, { default = true }) or icon
      end
      local flags = {}
      if vim.bo[buffer].modified then flags[#flags + 1] = "[+]" end
      if vim.bo[buffer].readonly or not vim.bo[buffer].modifiable then flags[#flags + 1] = "[RO]" end
      return "%#LivaraStatusText# " .. icon .. " " .. escape_statusline(name) .. " " .. table.concat(flags, " ")
    end

    local function git_component()
      local status = vim.b.gitsigns_status_dict or {}
      local parts = {}
      if status.head and status.head ~= "" then
        parts[#parts + 1] = " " .. escape_statusline(status.head)
      end
      local added = tonumber(status.added or 0) or 0
      local changed = tonumber(status.changed or 0) or 0
      local removed = tonumber(status.removed or 0) or 0
      if added + changed + removed > 0 then
        parts[#parts + 1] = string.format("+%d ~%d -%d", added, changed, removed)
      end
      return #parts > 0 and "%#LivaraStatusGit#" .. table.concat(parts, " ") or ""
    end

    local function diagnostics_component()
      local counts = { 0, 0, 0, 0 }
      for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        if diagnostic.severity then counts[diagnostic.severity] = counts[diagnostic.severity] + 1 end
      end
      local symbols = { "", "", "", "󰌵" }
      local groups = { "LivaraStatusError", "LivaraStatusWarn", "LivaraStatusInfo", "LivaraStatusHint" }
      local parts = {}
      for severity = 1, 4 do
        if counts[severity] > 0 then
          parts[#parts + 1] = string.format("%%#%s#%s %d", groups[severity], symbols[severity], counts[severity])
        end
      end
      return table.concat(parts, " ")
    end

    local function lsp_component()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then return "" end
      local names = {}
      for _, client in ipairs(clients) do names[#names + 1] = client.name end
      table.sort(names)
      return "%#LivaraStatusAccent#󰄭 %#LivaraStatusMuted#" .. table.concat(names, ",")
    end

    local function mode_component()
      local modes = {
        n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", ["\22"] = "V-BLOCK",
        c = "COMMAND", R = "REPLACE", t = "TERM", s = "SELECT", S = "S-LINE",
      }
      return "%#LivaraStatusAccent#" .. (modes[vim.fn.mode()] or vim.fn.mode():upper())
    end

    local function filetype_component()
      local filetype = vim.bo.filetype ~= "" and vim.bo.filetype:upper() or "NO FILETYPE"
      return "%#LivaraStatusMuted#" .. filetype
    end

    local function location_component()
      return "%#LivaraStatusLocation#%3l:%-2c"
    end

    local function scrollbar_component()
      local chars = { "▔", "🮂", "🬂", "🮃", "▀", "▄", "▃", "🬭", "▂", "▁" }
      local line = vim.fn.line(".")
      local lines = math.max(vim.api.nvim_buf_line_count(0), 1)
      local index = math.min(#chars, math.floor((line - 1) / lines * #chars) + 1)
      return "%#LivaraStatusMuted#" .. chars[index]
    end

    function LivaraStatusline.render()
      if disabled_filetypes[vim.bo.filetype] then return "" end
      prepare_highlights()
      local left = table.concat({ mode_component(), fileinfo_component(), git_component() }, "  ")
      local right = table.concat({ diagnostics_component(), lsp_component(), filetype_component(), location_component(), scrollbar_component() }, "  ")
      return left .. "%=" .. right .. " "
    end

    local function breadcrumb()
      local path = vim.fn.expand("%:~:.")
      if path == "" then return "" end
      local pieces = vim.split(path, "/", { plain = true, trimempty = true })
      if #pieces == 0 then return "" end
      local rendered = {}
      for index, piece in ipairs(pieces) do
        local escaped = escape_statusline(piece)
        rendered[#rendered + 1] = (index == #pieces and "%#LivaraWinbarAccent#" or "%#LivaraWinbarMuted#") .. escaped
      end
      return " %#LivaraWinbarText#" .. table.concat(rendered, " %#LivaraWinbarMuted#› ")
    end

    function LivaraWinbar.render()
      if disabled_filetypes[vim.bo.filetype] then return "" end
      prepare_highlights()
      return breadcrumb() .. " "
    end

    _G.LivaraStatusline = LivaraStatusline
    _G.LivaraWinbar = LivaraWinbar
    _G.livara_statusline_activate = function()
      vim.o.showmode = false
      vim.o.laststatus = 3
      vim.o.statusline = "%!v:lua.LivaraStatusline.render()"
      vim.o.winbar = "%!v:lua.LivaraWinbar.render()"
      vim.cmd("redrawstatus")
      vim.cmd("redrawtabline")
    end

    local redraw_group = vim.api.nvim_create_augroup("LivaraStatuslineWinbar", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufFilePost", "WinEnter", "DirChanged", "DiagnosticChanged", "LspAttach", "LspDetach" }, {
      group = redraw_group,
      callback = function()
        if vim.bo.buftype ~= "nofile" then vim.cmd("redrawstatus") end
      end,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = redraw_group,
      callback = function()
        prepare_highlights()
        vim.cmd("redrawstatus")
      end,
    })
    _G.livara_statusline_activate()
  '';
}

{ ... }:
{
  extraConfigLua = ''
    local LivaraBar = {}
    local hidden_filetypes = {
      snacks_dashboard = true,
      snacks_picker_list = true,
      oil = true,
      help = true,
    }

    local CAP_LEFT = ""
    local CAP_RIGHT = ""

    local function color(group, field, fallback)
      local spec = vim.api.nvim_get_hl(0, { name = group, link = false })
      if spec[field] then return string.format("#%06x", spec[field]) end
      return fallback
    end

    local function set_bar_highlights()
      local base = color("Normal", "bg", "#191b24")
      local surface = color("NormalFloat", "bg", "#20232f")
      local text_fg = color("Normal", "fg", "#e7e9ef")
      local muted = color("Comment", "fg", "#9da3b4")
      local accent = color("Directory", "fg", "#ff6b9d")
      local error = color("DiagnosticError", "fg", "#ff718d")
      local warn = color("DiagnosticWarn", "fg", "#f4d36b")
      local info = color("DiagnosticInfo", "fg", "#82c8ff")
      local hint = color("DiagnosticHint", "fg", "#8ce6ad")

      -- Caps: fg = the pill's own background, bg = NONE (transparent),
      -- so the rounded glyph draws the pill's color directly on the
      -- editor background, creating the floating-capsule look.
      vim.api.nvim_set_hl(0, "LivaraCapMode", { fg = accent, bg = "NONE" })
      vim.api.nvim_set_hl(0, "LivaraCapSurface", { fg = surface, bg = "NONE" })

      -- Mode pill (solid accent badge).
      vim.api.nvim_set_hl(0, "LivaraModeText", { fg = base, bg = accent, bold = true })

      -- Everything else lives on the neutral "surface" pill.
      vim.api.nvim_set_hl(0, "LivaraText", { fg = text_fg, bg = surface })
      vim.api.nvim_set_hl(0, "LivaraMuted", { fg = muted, bg = surface })
      vim.api.nvim_set_hl(0, "LivaraDot", { fg = muted, bg = surface })
      vim.api.nvim_set_hl(0, "LivaraGitIcon", { fg = hint, bg = surface, bold = true })
      vim.api.nvim_set_hl(0, "LivaraAccentOnSurface", { fg = accent, bg = surface, bold = true })
      vim.api.nvim_set_hl(0, "LivaraError", { fg = error, bg = surface, bold = true })
      vim.api.nvim_set_hl(0, "LivaraWarn", { fg = warn, bg = surface, bold = true })
      vim.api.nvim_set_hl(0, "LivaraInfo", { fg = info, bg = surface, bold = true })
      vim.api.nvim_set_hl(0, "LivaraHint", { fg = hint, bg = surface, bold = true })

      -- Winbar: no pill, just quiet, transparent text.
      vim.api.nvim_set_hl(0, "LivaraWinbarMuted", { fg = muted, bg = "NONE", italic = true })
      vim.api.nvim_set_hl(0, "LivaraWinbarName", { fg = text_fg, bg = "NONE" })
      vim.api.nvim_set_hl(0, "LivaraWinbarDot", { fg = accent, bg = "NONE", bold = true })

      -- Force both bars fully transparent so pills float on the editor bg.
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })
    end

    local function escape(value)
      return (value or ""):gsub("%%", "%%%%")
    end

    local function current_name()
      local name = vim.fn.expand("%:t")
      if name == "" then return "[No Name]" end
      return escape(name)
    end

    local function mode()
      local names = {
        n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", ["\22"] = "V-BLOCK",
        c = "COMMAND", R = "REPLACE", t = "TERM", s = "SELECT", S = "S-LINE",
      }
      return names[vim.fn.mode()] or vim.fn.mode():upper()
    end

    -- Wrap `body` (a string that must open with its own "%#Group#" switch)
    -- in rounded caps. Every highlight used inside `body` must share the
    -- same background so the pill reads as one seamless capsule.
    local function pill(cap_hl, body)
      if body == "" then return "" end
      return "%#" .. cap_hl .. "#" .. CAP_LEFT .. body .. "%#" .. cap_hl .. "#" .. CAP_RIGHT
    end

    local function join(parts)
      local out = {}
      for _, part in ipairs(parts) do
        if part ~= "" then out[#out + 1] = part end
      end
      return table.concat(out, " ")
    end

    local function mode_pill()
      return pill("LivaraCapMode", "%#LivaraModeText# " .. mode() .. " ")
    end

    local function git_pill()
      local git = vim.b.gitsigns_status_dict or {}
      if not git.head or git.head == "" then return "" end
      local changed = (tonumber(git.added or 0) or 0) + (tonumber(git.changed or 0) or 0) + (tonumber(git.removed or 0) or 0)
      local body = "%#LivaraGitIcon#  %#LivaraText#" .. escape(git.head)
      if changed > 0 then
        body = body .. "  %#LivaraMuted#" .. changed
      end
      return pill("LivaraCapSurface", body .. " ")
    end

    local function diagnostics_pill()
      local counts = { 0, 0, 0, 0 }
      for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        if diagnostic.severity then counts[diagnostic.severity] = counts[diagnostic.severity] + 1 end
      end
      local symbols = { "", "", "", "󰌵" }
      local groups = { "LivaraError", "LivaraWarn", "LivaraInfo", "LivaraHint" }
      local parts = {}
      for severity = 1, 4 do
        if counts[severity] > 0 then
          parts[#parts + 1] = string.format("%%#%s# %s %d", groups[severity], symbols[severity], counts[severity])
        end
      end
      if #parts == 0 then return "" end
      return pill("LivaraCapSurface", table.concat(parts, "%#LivaraDot# │") .. " ")
    end

    local function meta_pill()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      local lsp_name = "no lsp"
      if #clients > 0 then
        local names = {}
        for _, client in ipairs(clients) do names[#names + 1] = client.name end
        table.sort(names)
        lsp_name = names[1]
      end
      local filetype = vim.bo.filetype ~= "" and vim.bo.filetype:upper() or "TEXT"
      local body = "%#LivaraMuted# 󰄭 " .. escape(lsp_name)
        .. " %#LivaraDot#│ %#LivaraMuted#" .. filetype
        .. " %#LivaraDot#│ %#LivaraAccentOnSurface#%3l:%-2c "
      return pill("LivaraCapSurface", body)
    end

    function LivaraBar.statusline()
      if hidden_filetypes[vim.bo.filetype] then return "" end
      set_bar_highlights()
      local left = join({ mode_pill(), git_pill() })
      local right = join({ diagnostics_pill(), meta_pill() })
      return " " .. left .. "%=" .. right .. " "
    end

    function LivaraBar.winbar()
      if hidden_filetypes[vim.bo.filetype] then return "" end
      set_bar_highlights()
      local name = current_name()
      local dot = vim.bo.modified and " %#LivaraWinbarDot#●" or ""
      return "%#LivaraWinbarMuted#  %#LivaraWinbarName#" .. name .. dot .. " "
    end

    _G.LivaraBar = LivaraBar
    local group = vim.api.nvim_create_augroup("LivaraMinimalBars", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufFilePost", "WinEnter", "DirChanged", "DiagnosticChanged", "LspAttach", "LspDetach", "ModeChanged" }, {
      group = group,
      callback = function() vim.cmd("redrawstatus") end,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = function() set_bar_highlights(); vim.cmd("redrawstatus") end,
    })

    vim.o.showmode = false
    vim.o.laststatus = 3
    vim.o.statusline = "%!v:lua.LivaraBar.statusline()"
    vim.o.winbar = "%!v:lua.LivaraBar.winbar()"
    set_bar_highlights()
  '';
}

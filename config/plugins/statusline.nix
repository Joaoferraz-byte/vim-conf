{ ... }:
{
  # One owner for both bars. The footer is intentionally compact; the winbar
  # provides only the current filename, never a duplicated full path.
  extraConfigLua = ''
    local LivaraBar = {}
    local hidden_filetypes = {
      snacks_dashboard = true,
      snacks_picker_list = true,
      oil = true,
      help = true,
    }

    local function color(group, field, fallback)
      local spec = vim.api.nvim_get_hl(0, { name = group, link = false })
      if spec[field] then return string.format("#%06x", spec[field]) end
      return fallback
    end

    local function set_bar_highlights()
      local text_bg = color("NormalFloat", "bg", "#191b24")
      local text_fg = color("Normal", "fg", "#e7e9ef")
      local muted = color("Comment", "fg", "#9da3b4")
      local vivid = color("Directory", "fg", "#ff6b9d")
      local error = color("DiagnosticError", "fg", "#ff718d")
      local warn = color("DiagnosticWarn", "fg", "#f4d36b")
      local info = color("DiagnosticInfo", "fg", "#82c8ff")
      local hint = color("DiagnosticHint", "fg", "#8ce6ad")

      vim.api.nvim_set_hl(0, "LivaraBarCap", { fg = text_bg, bg = vivid, bold = true })
      vim.api.nvim_set_hl(0, "LivaraBarBlock", { fg = text_fg, bg = text_bg, blend = 8 })
      vim.api.nvim_set_hl(0, "LivaraBarMuted", { fg = muted, bg = text_bg, blend = 8 })
      vim.api.nvim_set_hl(0, "LivaraBarAccent", { fg = vivid, bg = text_bg, bold = true, blend = 8 })
      vim.api.nvim_set_hl(0, "LivaraBarMode", { fg = vivid, bg = text_bg, bold = true, blend = 8 })
      vim.api.nvim_set_hl(0, "LivaraBarError", { fg = error, bg = text_bg, blend = 8 })
      vim.api.nvim_set_hl(0, "LivaraBarWarn", { fg = warn, bg = text_bg, blend = 8 })
      vim.api.nvim_set_hl(0, "LivaraBarInfo", { fg = info, bg = text_bg, blend = 8 })
      vim.api.nvim_set_hl(0, "LivaraBarHint", { fg = hint, bg = text_bg, blend = 8 })
      vim.api.nvim_set_hl(0, "LivaraBarWinbar", { fg = muted, bg = "NONE", italic = true })
      vim.api.nvim_set_hl(0, "LivaraBarWinbarActive", { fg = text_fg, bg = "NONE", bold = true })
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

    local function git_component()
      local git = vim.b.gitsigns_status_dict or {}
      if not git.head or git.head == "" then return "" end
      local changed = (tonumber(git.added or 0) or 0) + (tonumber(git.changed or 0) or 0) + (tonumber(git.removed or 0) or 0)
      return " " .. escape(git.head) .. (changed > 0 and " " .. changed or "")
    end

    local function diagnostics_component()
      local counts = { 0, 0, 0, 0 }
      for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        if diagnostic.severity then counts[diagnostic.severity] = counts[diagnostic.severity] + 1 end
      end
      local parts = {}
      local symbols = { "", "", "", "󰌵" }
      local groups = { "LivaraBarError", "LivaraBarWarn", "LivaraBarInfo", "LivaraBarHint" }
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
      return "󰄭 " .. escape(names[1])
    end

    local function position_component()
      return "%3l:%-2c"
    end

    function LivaraBar.statusline()
      if hidden_filetypes[vim.bo.filetype] then return "" end
      set_bar_highlights()
      local left = table.concat({ mode(), git_component() }, "  ")
      local right = table.concat({ diagnostics_component(), lsp_component(), vim.bo.filetype ~= "" and vim.bo.filetype:upper() or "TEXT", position_component() }, "  ")
      return "%#LivaraBarCap#%#LivaraBarBlock# "
        .. "%#LivaraBarMode#" .. left .. "%#LivaraBarBlock# %=" .. right .. " "
    end

    function LivaraBar.winbar()
      if hidden_filetypes[vim.bo.filetype] then return "" end
      set_bar_highlights()
      local name = current_name()
      return "%#LivaraBarWinbar# " .. name .. (vim.bo.modified and " [+]" or "") .. " %#LivaraBarWinbarActive#"
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

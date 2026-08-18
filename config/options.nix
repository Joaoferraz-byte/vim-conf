{ ... }:
{
  opts = {
    number = true;
    relativenumber = true;
    cursorline = true;
    signcolumn = "yes";
    termguicolors = true;

    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    softtabstop = 2;
    autoindent = true;
    smartindent = true;
    breakindent = true;

    ignorecase = true;
    smartcase = true;
    inccommand = "split";
    incsearch = true;
    hlsearch = false;
    completeopt = [ "menu" "menuone" "noselect" ];
    wildmode = "longest:full,full";
    wildoptions = "pum";
    pumheight = 12;
    clipboard = "unnamedplus";

    splitbelow = true;
    splitright = true;
    scrolloff = 8;
    sidescrolloff = 8;
    wrap = false;
    mouse = "a";
    updatetime = 200;
    timeoutlen = 400;

    swapfile = false;
    backup = false;
    undofile = true;
    undolevels = 10000;

    fillchars = "eob: ,fold: ,foldopen:󰃆,foldsep: ,foldclose:󰃄";
    listchars = "tab:→ ,trail:·,extends:»,precedes:«,nbsp:·";
    showbreak = "↪ ";
    conceallevel = 2;
    shortmess = "atIcF";
    cmdheight = 1;
    more = false;

    laststatus = 3;
  };

  # Keep evaluation independent from runtime Matugen. The Lua loader below
  # applies the generated palette when it exists and falls back to habamax.
  colorscheme = "habamax";

  performance = {
    byteCompileLua = {
      enable = true;
      nvimRuntime = true;
      configs = true;
      plugins = true;
    };
  };

  extraConfigLua = ''
    -- Ensure fillchars eob=space is respected after every theme switch.
    -- Theme reloads may reset some options, so re-apply here.
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("SerpantinumFillchars", { clear = true }),
      callback = function()
        vim.opt.fillchars:append("eob: ")
      end,
    })

    -- Also apply on VimEnter for early UI rendering
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.opt.fillchars:append("eob: ")
      end,
    })

    -- Apply the optional Serpantinum/Matugen palette without requiring the
    -- generator during Nix evaluation. The generated file is a Lua table.
    local function apply_serpantinum_theme()
      local path = vim.fn.stdpath("config") .. "/matugen_colors.lua"
      if vim.fn.filereadable(path) ~= 1 then return end
      local ok, colors = pcall(dofile, path)
      if not ok or type(colors) ~= "table" then return end

      local function set(name, fg, bg, opts)
        local spec = opts or {}
        if fg then spec.fg = fg end
        if bg then spec.bg = bg end
        vim.api.nvim_set_hl(0, name, spec)
      end

      local function apply_transparency()
        -- Keep the editor canvas transparent so Hyprland/QuickShell can show
        -- through it. This must run after every colorscheme/palette reload:
        -- many plugins recreate these groups with opaque backgrounds.
        local transparent_groups = {
          "Normal", "NormalNC", "SignColumn", "FoldColumn", "Folded",
          "EndOfBuffer", "LineNr", "CursorLineNr", "CursorLine",
          "ColorColumn", "Conceal", "NonText", "Whitespace", "VertSplit",
          "WinSeparator", "StatusLine", "StatusLineNC", "TabLine",
          "TabLineFill", "TabLineSel", "NvimTreeNormal", "NvimTreeNormalNC",
          "NvimTreeEndOfBuffer", "NeoTreeNormal", "NeoTreeNormalNC",
          "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal",
          "TelescopeResultsNormal", "TelescopePreviewNormal",
          "WhichKeyNormal", "WhichKeyFloat", "WhichKeyBorder", "WhichKeyTitle",
          "SnacksInputNormal", "SnacksInputBorder", "SnacksInputTitle", "SnacksInputIcon",
          "TelescopePromptBorder", "TelescopePromptTitle", "TelescopeResultsBorder",
          "TelescopeResultsTitle", "TelescopePreviewBorder", "TelescopePreviewTitle",
          "WinBar", "WinBarNC", "NavicText", "NavicSeparator",
          "FloatShadow", "FloatShadowThrough",
        }
        for _, group in ipairs(transparent_groups) do
          local current = vim.api.nvim_get_hl(0, { name = group, link = false })
          current.bg = nil
          current.ctermbg = nil
          vim.api.nvim_set_hl(0, group, current)
        end
      end

      vim.cmd("colorscheme habamax")
      vim.opt.background = "dark"
      set("Normal", colors.text)
      set("NormalNC", colors.text)
      set("NormalFloat", colors.text, colors.surface0, { blend = 8 })
      set("FloatBorder", colors.blue, colors.surface0, { blend = 8 })
      set("CursorLine", nil, colors.surface0, { blend = 15 })
      set("CursorLineNr", colors.blue, nil, { bold = true })
      set("LineNr", colors.overlay1)
      set("Comment", colors.overlay2, nil, { italic = true })
      set("String", colors.green)
      set("Function", colors.blue, nil, { bold = true })
      set("Keyword", colors.mauve)
      set("Type", colors.yellow)
      set("Constant", colors.peach)
      set("Number", colors.peach)
      set("Identifier", colors.text)
      set("Statement", colors.red)
      set("Error", colors.red, nil, { bold = true })
      set("DiagnosticError", colors.red)
      set("DiagnosticWarn", colors.yellow)
      set("DiagnosticInfo", colors.blue)
      set("DiagnosticHint", colors.teal)
      set("Pmenu", colors.text, colors.surface1, { blend = 8 })
      set("PmenuSel", colors.on_primary, colors.primary, { bold = true })
      -- Keep the editor's global statusline transparent. Lualine receives
      -- its own bounded surfaces below so only the footer segments have a
      -- readable material background.
      set("StatusLine", colors.text, "NONE", { blend = 10 })
      set("StatusLineNC", colors.overlay2, "NONE", { blend = 10 })
      set("WinBar", colors.subtext1, "NONE", { blend = 18 })
      set("WinBarNC", colors.overlay1, "NONE", { blend = 24 })
      set("NavicText", colors.subtext1, "NONE", { blend = 18 })
      set("NavicSeparator", colors.overlay1, "NONE", { blend = 24 })
      set("VertSplit", colors.overlay0)

      local function set_lualine_group(name, fg, bg, blend, bold)
        vim.api.nvim_set_hl(0, name, {
          fg = fg,
          bg = bg,
          blend = blend or 0,
          bold = bold or false,
        })
      end

      -- Lualine references these highlight groups by name instead of storing
      -- a one-time copy of the wallpaper palette. Matugen can therefore update
      -- the footer in place on the next wallpaper change.
      set_lualine_group("SerpantinumLualineNormalA", colors.on_primary, colors.primary, 0, true)
      set_lualine_group("SerpantinumLualineNormalB", colors.text, colors.surface0, 18, false)
      set_lualine_group("SerpantinumLualineNormalC", colors.text, "NONE", 0, false)
      set_lualine_group("SerpantinumLualineInsertA", colors.base, colors.green, 0, true)
      set_lualine_group("SerpantinumLualineInsertB", colors.text, colors.surface0, 18, false)
      set_lualine_group("SerpantinumLualineInsertC", colors.text, "NONE", 0, false)
      set_lualine_group("SerpantinumLualineVisualA", colors.base, colors.mauve, 0, true)
      set_lualine_group("SerpantinumLualineVisualB", colors.text, colors.surface0, 18, false)
      set_lualine_group("SerpantinumLualineVisualC", colors.text, "NONE", 0, false)
      set_lualine_group("SerpantinumLualineReplaceA", colors.base, colors.red, 0, true)
      set_lualine_group("SerpantinumLualineReplaceB", colors.text, colors.surface0, 18, false)
      set_lualine_group("SerpantinumLualineReplaceC", colors.text, "NONE", 0, false)
      set_lualine_group("SerpantinumLualineCommandA", colors.base, colors.peach, 0, true)
      set_lualine_group("SerpantinumLualineCommandB", colors.text, colors.surface0, 18, false)
      set_lualine_group("SerpantinumLualineCommandC", colors.text, "NONE", 0, false)
      set_lualine_group("SerpantinumLualineInactiveA", colors.subtext0, colors.surface0, 28, true)
      set_lualine_group("SerpantinumLualineInactiveB", colors.subtext0, colors.surface0, 28, false)
      set_lualine_group("SerpantinumLualineInactiveC", colors.subtext0, "NONE", 0, false)
      set("Visual", nil, colors.surface2, { blend = 12 })
      set("Search", colors.on_secondary, colors.secondary, { bold = true })
      set("IncSearch", colors.on_primary, colors.primary, { bold = true })
      apply_transparency()
      vim.g.colors_name = "serpantinum-matugen"
      pcall(function()
        require("lualine").refresh()
      end)
    end

    _G.reload_serpantinum_theme = apply_serpantinum_theme
    apply_serpantinum_theme()

    if not _G.serpantinum_theme_watcher_started then
      _G.serpantinum_theme_watcher_started = true
      local timer = vim.uv.new_timer()
      local last_mtime = nil
      timer:start(1000, 1000, vim.schedule_wrap(function()
        local path = vim.fn.stdpath("config") .. "/matugen_colors.lua"
        local stat = vim.uv.fs_stat(path)
        local mtime = stat and stat.mtime and (stat.mtime.sec .. ":" .. stat.mtime.nsec) or nil
        if mtime and mtime ~= last_mtime then
          last_mtime = mtime
          apply_serpantinum_theme()
          vim.cmd("redraw!")
        end
      end))
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if not timer:is_closing() then timer:stop(); timer:close() end
        end,
      })
    end

    -- Ensure transparency for float windows after theme application.
    vim.api.nvim_create_autocmd("WinEnter", {
      callback = function()
        if vim.api.nvim_win_get_config(0).zindex then
          vim.wo.winhl = "Normal:NormalFloat,FloatBorder:FloatBorder"
        end
      end,
    })
  '';
}

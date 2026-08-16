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

      vim.cmd("colorscheme habamax")
      set("Normal", colors.text, colors.base)
      set("NormalFloat", colors.text, colors.surface0)
      set("FloatBorder", colors.blue, colors.surface0)
      set("CursorLine", nil, colors.surface0)
      set("CursorLineNr", colors.blue, nil, { bold = true })
      set("LineNr", colors.overlay1, nil)
      set("Comment", colors.overlay2, nil, { italic = true })
      set("String", colors.green, nil)
      set("Function", colors.blue, nil, { bold = true })
      set("Keyword", colors.mauve, nil)
      set("Type", colors.yellow, nil)
      set("Constant", colors.peach, nil)
      set("Number", colors.peach, nil)
      set("Identifier", colors.text, nil)
      set("Statement", colors.red, nil)
      set("Error", colors.red, nil, { bold = true })
      set("DiagnosticError", colors.red, nil)
      set("DiagnosticWarn", colors.yellow, nil)
      set("DiagnosticInfo", colors.blue, nil)
      set("DiagnosticHint", colors.teal, nil)
      set("Pmenu", colors.text, colors.surface1)
      set("PmenuSel", colors.on_primary, colors.primary)
      set("StatusLine", colors.text, colors.surface1)
      set("StatusLineNC", colors.overlay2, colors.surface0)
      set("VertSplit", colors.overlay0, colors.base)
      set("Visual", nil, colors.surface2)
      set("Search", colors.on_secondary, colors.secondary)
      set("IncSearch", colors.on_primary, colors.primary)
      vim.g.colors_name = "serpantinum-matugen"
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

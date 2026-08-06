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
    smartindent = true;
    breakindent = true;

    ignorecase = true;
    smartcase = true;
    inccommand = "split";
    incsearch = true;
    hlsearch = false;
    completeopt = [ "menu" "menuone" "noselect" ];

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

    # Tilde (~) lines and whitespace fill are replaced with spaces
    # so end-of-buffer appears clean without visual markers.
    fillchars = "eob: ";
    shortmess = "atIcF"; # a: all, t: truncate, I: no intro, c: no completion messages, F: no file info
    cmdheight = 1;
    more = false; # Desativa o prompt "press enter" para mensagens longas

    # Disable the built-in scrollbar signcolumn indicator (replaces ~ with nothing)
    # The signcolumn is "yes" for diagnostics; the visual scrollbar column
    # that shows | on the right edge is removed via highlight overrides below.
  };

  # DMS theme
  colorscheme = "dms";

  performance = {
    byteCompileLua = {
      enable = true;
      nvimRuntime = true;
      configs = true;
      plugins = true;
    };
  };

  extraConfigLua = ''
    _G.apply_dms_theme = function()
      vim.g.dms_colors = {}
      local dms_css = vim.fn.expand("~/.config/DankMaterialShell/dms.css")
      if vim.fn.filereadable(dms_css) == 1 then
        local css = vim.fn.readfile(dms_css)
        for _, line in ipairs(css) do
          local key, value = line:match(":%s*--(%w+):%s*(%S+)")
          if key and value then
            vim.g.dms_colors[key] = value
          end
        end
      end

      -- Full transparency group list: covers all standard groups and
      -- common plugin groups. bg=NONE + ctermbg=NONE + force=true ensures
      -- the terminal background shows through even after plugin reloads.
      local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "FloatTitle",
        "FloatFooter",
        "FloatShadow",
        "FloatShadowThrough",
        "SignColumn",
        "EndOfBuffer",
        "EndOfBufferTop",
        "LineNr",
        "CursorLineNr",
        "NonText",
        "WinSeparator",
        "StatusLine",
        "StatusLineNC",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
        "Pmenu",
        "PmenuSel",
        "Folded",
        "FoldColumn",
        "NvimTreeNormal",
        "NvimTreeNormalNC",
        "NvimTreeWinSeparator",
        -- Dashboard groups
        "DashboardHeader",
        "DashboardFooter",
        "DashboardCenter",
        "DashboardKey",
        "DashboardDesc",
        "DashboardIcon",
        "DashboardShortCut",
        "DashboardNoiceHide",
      }
      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE", force = true })
      end

      -- Remove visual scrollbar: clear the highlight that draws | on the right edge
      vim.api.nvim_set_hl(0, "CursorColumn", { bg = "NONE", ctermbg = "NONE" })

      -- Clear any remaining highlight group that could draw a scrollbar column
      for _, g in ipairs({ "ScrollbarThumb", "ScrollbarLine", "ScrollbarEmpty" }) do
        pcall(vim.api.nvim_set_hl, 0, g, { bg = "NONE", ctermbg = "NONE" })
      end

      -- Pmenu selection uses primary color
      vim.api.nvim_set_hl(0, "PmenuSel", {
        bg = vim.g.dms_colors.primary or "#7aa2f7",
        fg = vim.g.dms_colors.background or "#1a1b26",
      })

      -- Dashboard-specific highlight overrides with fallback colors
      local p = vim.g.dms_colors.primary or "#7aa2f7"
      local c = vim.g.dms_colors.comment or "#565f89"
      local f = vim.g.dms_colors.fg or "#c0caf5"
      vim.api.nvim_set_hl(0, "DashboardHeader",   { fg = p })
      vim.api.nvim_set_hl(0, "DashboardFooter",   { fg = c })
      vim.api.nvim_set_hl(0, "DashboardCenter",   { fg = f })
      vim.api.nvim_set_hl(0, "DashboardKey",      { fg = f, bold = true })
      vim.api.nvim_set_hl(0, "DashboardDesc",     { fg = f })
      vim.api.nvim_set_hl(0, "DashboardIcon",     { fg = f })
      vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = c })

      -- Ensure fillchars eob=space is respected after every theme switch
      vim.opt.fillchars:append("eob: ")
    end

    -- Reapply transparency after any ColorScheme event (plugin reload, lazy load)
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("DmsDynamicTheme", { clear = true }),
      callback = function()
        _G.apply_dms_theme()
      end,
    })

    -- Initial application before VimEnter to cover early UI rendering
    _G.apply_dms_theme()

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        _G.apply_dms_theme()
        vim.opt.fillchars:append("eob: ")
      end,
    })

    -- Silenciamento total na inicialização
    vim.opt.shortmess:append("s")
  '';
}

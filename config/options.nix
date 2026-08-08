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
    # Command-line autocomplete popup (Vim-level ":" completion)
    wildmode = "longest:full,full";
    wildoptions = "pum";
    pumheight = 12;
    # Default yank/put registers use the system clipboard
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

    # Tilde (~) lines and whitespace fill are replaced with spaces
    # so end-of-buffer appears clean without visual markers.
    fillchars = "eob: ";
    shortmess = "atIcF"; # a: all, t: truncate, I: no intro, c: no completion messages, F: no file info
    cmdheight = 1;
    more = false; # Desativa o prompt "press enter" para mensagens longas

    # Disable the built-in scrollbar signcolumn indicator.
    # The signcolumn is "yes" for diagnostics; the visual scrollbar column
    # that shows | on the right edge is removed via fillchars.
    laststatus = 3; # Global statusline (single line across all windows)
  };

  # DMS theme — set by DMS matugen-generated ~/.config/nvim/colors/dms.lua
  # which harmonizes a base theme with wallpaper colors and calls base46.load("dms").
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
    -- Ensure fillchars eob=space is respected after every theme switch.
    -- base46.load() resets some options, so re-apply here.
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("DmsFillchars", { clear = true }),
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

    -- Ensure transparency for float windows (complements base46 transparency)
    vim.api.nvim_create_autocmd("WinEnter", {
      callback = function()
        if vim.api.nvim_win_get_config(0).zindex then
          vim.wo.winhl = "Normal:NormalFloat,FloatBorder:FloatBorder"
        end
      end,
    })
  '';
}

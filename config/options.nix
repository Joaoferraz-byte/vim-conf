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

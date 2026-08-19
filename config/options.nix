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

  # Dark is a policy of the Livara editor profile. Dynamic colors are applied
  # by theme.nix from the Matugen adapter at runtime.
  colorscheme = "habamax";
  extraConfigLua = ''
    vim.opt.background = "dark"
  '';

  performance.byteCompileLua = {
    enable = true;
    nvimRuntime = true;
    configs = true;
    plugins = true;
  };
}

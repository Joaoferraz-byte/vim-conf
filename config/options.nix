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
  };

  # Catppuccin theme for Neovim
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha"; # Mocha is the darkest flavor, matching DMS dark mode
      transparent_background = true;
      term_colors = true;
      integrations = {
        cmp = true;
        gitsigns = true;
        nvimtree = true;
        treesitter = true;
        notify = true;
        mini.enabled = true;
        indent_blankline.enabled = true;
      };
    };
  };
  colorscheme = "catppuccin-mocha";

  performance = {
    byteCompileLua = {
      enable = true;
      nvimRuntime = true;
      configs = true;
      plugins = true;
    };
  };
}

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

  # ─── DMS Dynamic Theme ────────────────────────────────────────────────────
  # Uses the DMS base46 plugin (AvengeMedia/base46).
  # DMS generates ~/.config/nvim/colors/dms.lua automatically.
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
    -- DMS Dynamic Theme: Load colors from Matugen-generated CSS
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

    -- Transparent background for floating windows
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatFooter", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

    -- Dashboard specific highlights (no noise)
    vim.api.nvim_set_hl(0, "DashboardHeader", { fg = vim.g.dms_colors.primary or "#7aa2f7" })
    vim.api.nvim_set_hl(0, "DashboardFooter", { fg = vim.g.dms_colors.comment or "#565f89" })
    vim.api.nvim_set_hl(0, "DashboardCenter", { fg = vim.g.dms_colors.fg or "#c0caf5" })
    vim.api.nvim_set_hl(0, "DashboardKey", { fg = vim.g.dms_colors.primary or "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "DashboardDesc", { fg = vim.g.dms_colors.fg or "#c0caf5" })
    vim.api.nvim_set_hl(0, "DashboardIcon", { fg = vim.g.dms_colors.primary or "#7aa2f7" })
    vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = vim.g.dms_colors.comment or "#565f89" })
  '';
}

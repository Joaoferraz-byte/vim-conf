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
  # Reads colors from the Matugen-generated theme (DMS).
  # Neovim theme is set via lua in extraConfigLua.
  colorscheme = "dms-dark";

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

    -- Create custom highlight groups based on DMS colors
    local bg = vim.g.dms_colors.bg or "#1a1b26"
    local bg_alt = vim.g.dms_colors.bg_alt or "#24283b"
    local fg = vim.g.dms_colors.fg or "#c0caf5"
    local comment = vim.g.dms_colors.comment or "#565f89"
    local primary = vim.g.dms_colors.primary or "#7aa2f7"

    -- Transparent background for floating windows
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", fg = fg })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = bg_alt })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = bg_alt })

    -- Dashboard specific highlights (no noise)
    vim.api.nvim_set_hl(0, "DashboardHeader", { fg = primary })
    vim.api.nvim_set_hl(0, "DashboardFooter", { fg = comment })
    vim.api.nvim_set_hl(0, "DashboardCenter", { fg = fg })
    vim.api.nvim_set_hl(0, "DashboardKey", { fg = primary, bold = true })
    vim.api.nvim_set_hl(0, "DashboardDesc", { fg = fg })
    vim.api.nvim_set_hl(0, "DashboardIcon", { fg = primary })
    vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = comment })
  '';
}

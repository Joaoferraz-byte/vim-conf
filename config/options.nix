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
    -- ─── DMS Dynamic Theme + Full Transparency ────────────────────────────
    -- Reaplicado a cada evento "ColorScheme" (não só no startup), porque o
    -- DMS pode re-executar `:colorscheme dms` em runtime quando o wallpaper
    -- muda (matugen). Sem isso, a transparência e as cores se perdem no
    -- primeiro reload de tema.
    _G.apply_dms_theme = function()
      -- Recarrega a paleta gerada pelo Matugen a partir do CSS do DMS
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

      -- Fundo transparente em todo o editor (igual ao terminal/compositor)
      local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "FloatTitle",
        "FloatFooter",
        "SignColumn",
        "EndOfBuffer",
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
        "Folded",
        "FoldColumn",
      }
      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
      end

      -- Mantém o item selecionado no menu de completion legível
      -- mesmo com o Pmenu transparente.
      vim.api.nvim_set_hl(0, "PmenuSel", {
        bg = vim.g.dms_colors.primary or "#7aa2f7",
        fg = vim.g.dms_colors.background or "#1a1b26",
      })

      -- Dashboard specific highlights (no noise)
      vim.api.nvim_set_hl(0, "DashboardHeader", { fg = vim.g.dms_colors.primary or "#7aa2f7" })
      vim.api.nvim_set_hl(0, "DashboardFooter", { fg = vim.g.dms_colors.comment or "#565f89" })
      vim.api.nvim_set_hl(0, "DashboardCenter", { fg = vim.g.dms_colors.fg or "#c0caf5" })
      vim.api.nvim_set_hl(0, "DashboardKey", { fg = vim.g.dms_colors.primary or "#7aa2f7", bold = true })
      vim.api.nvim_set_hl(0, "DashboardDesc", { fg = vim.g.dms_colors.fg or "#c0caf5" })
      vim.api.nvim_set_hl(0, "DashboardIcon", { fg = vim.g.dms_colors.primary or "#7aa2f7" })
      vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = vim.g.dms_colors.comment or "#565f89" })
    end

    _G.apply_dms_theme()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("DmsDynamicTheme", { clear = true }),
      callback = _G.apply_dms_theme,
      desc = "Reaplica paleta DMS e transparência ao trocar/recarregar o colorscheme",
    })
  '';
}

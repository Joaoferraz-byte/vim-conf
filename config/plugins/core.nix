{ config, pkgs, lib, ... }:
let
  base46-plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "base46";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "AvengeMedia";
      repo = "base46";
      rev = "83522e02c6c3b4ea901c4bffd9e0a5e0371c1fe6";
      hash = "sha256-kwDMC6rYzJYECmGnwn8JiAbffUq7hAXcUH6gPSkk2uI=";
    };
    doCheck = false;
  };
in
{
  plugins = {
    web-devicons.enable = true;
    gitsigns.enable = true;
    neogit.enable = true;
    diffview.enable = true;
    comment.enable = true;
    todo-comments.enable = true;
    undotree.enable = true;
    which-key.enable = true;
    nvim-autopairs.enable = true;
    illuminate = {
      enable = true;
      settings = {
        filetypes_denylist = [ "dashboard" "alpha" "NvimTree" "help" ];
        under_cursor = false;
      };
    };
    trouble.enable = true;

    # Flash
    flash.enable = true;

    # Aerial
    aerial = {
      enable = true;
      settings = {
        backends = [ "lsp" "treesitter" "markdown" ];
        show_guides = true;
      };
    };

    # Harpoon
    harpoon = {
      enable = true;
      enableTelescope = true;
      settings.settings = {
        save_on_toggle = true;
      };
    };

    # Project.nvim
    project-nvim = {
      enable = true;
      enableTelescope = true;
      settings = {
        history = {
          # The previous project_history.json is corrupt and is preserved as a
          # legacy backup; a fresh file prevents project.nvim callbacks from
          # failing during BufEnter and BufWipeout.
          save_dir.__raw = ''vim.fn.stdpath("data")'';
          save_file = "project_history_v2.json";
        };
      };
    };

    # TS Autotag
    ts-autotag.enable = true;

    # Zen Mode
    zen-mode.enable = true;

    # Smart Splits
    smart-splits.enable = true;

    # Oil
    oil.enable = true;

    # Treesitter
    treesitter = {
      enable = true;
      nixGrammars = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    # Telescope
    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
      extensions.file-browser.enable = true;
    };

    # Lazydev — Lua LSP completion for Neovim config
    lazydev = {
      enable = true;
      settings = {
        integrations = {
          lspconfig = true;
          cmp = true;
        };
      };
    };

    # Neo-tree — modern file explorer (replaces dashboard-nvim's NvimTree dependency)
    neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem = {
          follow_current_file = {
            enabled = true;
            leave_dirs_open = true;
          };
          filtered_items = {
            visible = true;
            show_hidden = true;
            always_show = [ ".git" ];
          };
        };
        window = {
          mappings = {
            "s" = "open_split";
            "S" = "open_vsplit";
          };
        };
      };
    };

    # Mini.nvim modules — essential modern Neovim utilities
    mini = {
      enable = true;
      modules = {
        animate = {
          cursor.enable = false;
          scroll.enable = false;
          resize.enable = true;
          open.enable = true;
          close.enable = true;
        };
        icons = {
          mockDevIcons = true;
        };
        surround = {};
        ai = {};
        bracketed = {};
        files = {
          mappings = {
            create = "c";
            copy = "y";
            copy_to_base = "Y";
            delete = "d";
            detail = ".";
            find = "f";
            go_in = "l";
            go_in_plus = "L";
            go_out = "h";
            go_out_plus = "H";
            hide_dotfiles = "gh";
            hide_parent = "gp";
            join = "j";
            mark_goto = "'";
            mark_toggle = "m";
            open = "o";
            open_cwd = "<C-g>c";
            open_external = "x";
            open_in_split = "s";
            pick = "p";
            pick_cwd = "<C-g>f";
            rename = "r";
            show_help = "g?";
            sort_name = "<C-n>";
            sort_mtime = "<C-m>";
            sort_size = "<C-s>";
            synchronize = "S";
            trim_rslash = "T";
          };
        };
      };
    };
  };

  extraPlugins = [ base46-plugin ];

  extraPackages = with pkgs; [
    git ripgrep fd gnumake nodejs jdk21 maven gradle chafa
  ];

  # DMS base46 setup: enable transparency and register DMS integrations.
  # The actual theme loading is handled by DMS matugen-generated dms.lua
  # at ~/.config/nvim/colors/dms.lua, which calls base46.theme_harmonize()
  # and base46.load("dms") dynamically.
  extraConfigLua = ''
    pcall(function()
      local b46 = require("base46")
      b46.setup({
        transparency = true,
        set_background = true,
        term_colors = true,
        integrations = {
          blankline = true,
          cmp = true,
          defaults = true,
          devicons = true,
          git = true,
          lsp = true,
          mason = true,
          neotest = true,
          nvimtree = true,
          statusline = true,
          syntax = true,
          treesitter = true,
          tbline = true,
          telescope = true,
          whichkey = true,
          alpha = true,
          avante = true,
          ["blink-pair"] = true,
          bufferline = true,
          codeactionmenu = true,
          dap = true,
          diffview = true,
          edgy = true,
          flash = true,
          ["git-conflict"] = true,
          gitsigns = true,
          grug_far = true,
          hop = true,
          leap = true,
          lspsaga = true,
          markview = true,
          ["mini-tabline"] = true,
          ["mini-icons"] = true,
          navic = true,
          neogit = true,
          notify = true,
          nvshades = true,
          orgmode = true,
          rainbowdelimiters = true,
          ["render-markdown"] = true,
          semantic_tokens = true,
          ["snacks-dashboard"] = true,
          ["tiny-inline-diagnostic"] = true,
          todo = true,
          trouble = true,
          ["vim-illuminate"] = true,
        },
      })

      -- DMS/base46 may reapply opaque highlight groups when the generated
      -- colorscheme reloads. Reassert transparent backgrounds after every
      -- colorscheme event so the terminal wallpaper remains visible.
      local function apply_transparent_backgrounds()
        local groups = {
          "Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle",
          "SignColumn", "FoldColumn", "EndOfBuffer", "NonText", "LineNr",
          "CursorLineNr", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill",
          "TabLineSel", "WinSeparator", "VertSplit", "MsgArea", "Pmenu",
          "PmenuSel", "WildMenu", "TelescopeNormal", "TelescopeBorder",
          "WhichKeyNormal", "NotifyBackground",
        }
        for _, group in ipairs(groups) do
          local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
          highlight.bg = nil
          highlight.ctermbg = nil
          vim.api.nvim_set_hl(0, group, highlight)
        end
      end

      local transparency_group = vim.api.nvim_create_augroup("DmsTransparency", { clear = true })
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "UIEnter" }, {
        group = transparency_group,
        callback = apply_transparent_backgrounds,
      })
      vim.schedule(apply_transparent_backgrounds)
    end)
  '';
}

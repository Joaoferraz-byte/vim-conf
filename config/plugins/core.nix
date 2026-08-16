{ config, pkgs, lib, ... }:
let
  mermaid-plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "mermaid.nvim";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "kevalin";
      repo = "mermaid.nvim";
      rev = "b6ab941f418809d40102f11ace9da3569c33e52e";
      hash = "sha256-SHNfpIinSGFLsx5SVvG1T8XJUZSK4BMEpqko6Vb0YzU=";
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

    flash.enable = true;

    aerial = {
      enable = true;
      settings = {
        backends = [ "lsp" "treesitter" "markdown" ];
        show_guides = true;
      };
    };

    harpoon = {
      enable = true;
      enableTelescope = true;
      settings.settings = {
        save_on_toggle = true;
      };
    };

    project-nvim = {
      enable = true;
      enableTelescope = true;
      settings = {
        history = {
          save_dir.__raw = ''vim.fn.stdpath("data")'';
          save_file = "project_history_clean.json";
        };
      };
    };

    ts-autotag.enable = true;

    zen-mode.enable = true;

    smart-splits.enable = true;

    oil.enable = true;

    treesitter = {
      enable = true;
      nixGrammars = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    grug-far = {
      enable = true;
      settings = {
        engine = "ripgrep";
        engines.ripgrep.showReplaceDiff = true;
        minSearchChars = 1;
      };
    };

    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
      extensions.file-browser.enable = true;
      extensions.media-files.enable = true;
    };

    # WezTerm is the supported terminal for Livara, not Kitty. image.nvim's
    # alternative ueberzug backend was crashing during startup and produced
    # the terminal's "press any key to continue" pause. Keep image rendering
    # opt-in until a terminal/backend pair is explicitly configured by the
    # user; Neovim itself must never depend on a graphics helper process.
    image = {
      enable = false;
    };

    lazydev = {
      enable = true;
      settings = {
        integrations = {
          lspconfig = true;
          cmp = true;
        };
      };
    };

    neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem = {
          follow_current_file = {
            enabled = true;
            leave_dirs_open = true;
          };
          group_empty_dirs = true;
          scan_mode = "deep";
          filtered_items = {
            visible = true;
            show_hidden = true;
            always_show = [ ".git" ];
          };
        };
        window = {
          mappings = {
            "<bs>" = "navigate_up";
            "s" = "open_split";
            "S" = "open_vsplit";
          };
        };
      };
    };

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

  extraPlugins = with pkgs.vimPlugins; [
    telescope-media-files-nvim
    mermaid-plugin
    vim-sleuth
  ];

  extraPackages = with pkgs; [
    git ripgrep fd gnumake nodejs jdk21 maven gradle chafa imagemagick wl-clipboard ffmpeg
  ];

  extraConfigLua = ''
    pcall(function()
      -- Initialize Telescope early and load its extensions (media_files,
      -- file_browser, fzf). Telescope defers loading its actions and
      -- state modules until setup runs, so functions called from other
      -- plugins (e.g. dashboard actions) can see a nil `telescope.actions`
      -- if Telescope was never touched before them.
      local telescope_ok, telescope = pcall(require, "telescope")
      if telescope_ok then
        telescope.setup {}
        pcall(telescope.load_extension, "media_files")
        pcall(telescope.load_extension, "file_browser")
        pcall(telescope.load_extension, "fzf")
      end

      -- A theme reload may reapply opaque highlight groups. Reassert
      -- transparent backgrounds after every colorscheme event so the
      -- terminal wallpaper remains visible.
      local function apply_transparent_backgrounds()
        local groups = {
          "Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle", "FloatShadow",
          "WinBar", "WinBarNC", "SignColumn", "FoldColumn", "EndOfBuffer", "NonText", "LineNr",
          "CursorLine", "CursorLineNr", "StatusLine", "StatusLineNC", "StatusLineTerm", "StatusLineTermNC",
          "TabLine", "TabLineFill", "TabLineSel", "WinSeparator", "VertSplit", "MsgArea",
          "BufferLineFill", "BufferLineBackground", "BufferLineBuffer", "BufferLineBufferSelected",
          "BufferLineTab", "BufferLineTabSelected", "BufferLineTabClose", "BufferLineCloseButton",
          "BufferLineCloseButtonSelected", "BufferLineIndicatorSelected", "BufferLineModified",
          "BufferLineModifiedSelected", "BufferLineDuplicate", "BufferLineDuplicateSelected",
          "BufferLineDevIconDefault", "BufferLineDevIconDefaultSelected",
          "Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb", "WildMenu", "CmpNormal", "CmpBorder",
          "CmpDoc", "CmpDocBorder", "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal",
          "TelescopePromptBorder", "TelescopeResultsNormal", "TelescopeResultsBorder",
          "TelescopePreviewNormal", "TelescopePreviewBorder", "WhichKeyNormal", "WhichKeyFloat",
          "NotifyBackground", "NoiceCmdlinePopup", "NoiceCmdlinePopupBorder", "SnacksNormal",
          "SnacksBackdrop", "MiniFilesNormal", "MiniFilesBorder", "MiniFilesTitle",
          "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeWinSeparator", "NeoTreeEndOfBuffer",
          "NeoTreeFloatBorder", "NeoTreeFloatTitle", "NvimTreeNormal", "NvimTreeNormalNC",
          "NvimTreeEndOfBuffer", "MasonNormal", "MasonHeader", "AerialNormal", "TroubleNormal",
          "NavicIconsFile", "NavicIconsModule", "NavicIconsNamespace", "NavicIconsPackage",
          "NavicIconsClass", "NavicIconsMethod", "NavicIconsProperty", "NavicIconsField",
          "NavicIconsConstructor", "NavicIconsEnum", "NavicIconsInterface", "NavicIconsFunction",
          "NavicIconsVariable", "NavicIconsConstant", "NavicIconsString", "NavicIconsNumber",
          "NavicIconsBoolean", "NavicIconsArray", "NavicIconsObject", "NavicIconsKey",
          "NavicIconsNull", "NavicIconsEnumMember", "NavicIconsStruct", "NavicIconsEvent",
          "NavicIconsOperator", "NavicIconsTypeParameter",
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

{ config, pkgs, ... }:
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
    nvim-autopairs.enable = true;
    illuminate = {
      enable = true;
      settings = {
        filetypes_denylist = [ "snacks_dashboard" "snacks_picker_list" "oil" "help" ];
        under_cursor = false;
      };
    };
    flash.enable = true;

    harpoon = {
      enable = true;
      settings.settings = {
        save_on_toggle = true;
      };
    };

    ts-autotag.enable = true;
    smart-splits.enable = true;

    treesitter = {
      enable = true;
      nixGrammars = true;
      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
        markdown
        markdown_inline
        html
        xml
        latex
        yaml
      ];
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

    image.enable = false;

    lazydev = {
      enable = true;
      settings.integrations = {
        lspconfig = true;
        cmp = true;
      };
    };

    # Keep only the mini modules that provide text objects, icons and motions.
    # Filesystem navigation belongs exclusively to Oil.
    mini = {
      enable = true;
      modules = {
        icons = {
          mockDevIcons = true;
          directory = {
            "Black Box" = { glyph = "󰮂"; hl = "MiniIconsBlue"; };
            "Source Notes" = { glyph = "󰧮"; hl = "MiniIconsCyan"; };
            "Xournal++" = { glyph = "󰻂"; hl = "MiniIconsGreen"; };
            "Projects" = { glyph = "󰏗"; hl = "MiniIconsOrange"; };
            "Daily Notes" = { glyph = "󰃭"; hl = "MiniIconsYellow"; };
            "Thoughts" = { glyph = "󰗞"; hl = "MiniIconsPurple"; };
            "References" = { glyph = "󰈙"; hl = "MiniIconsAzure"; };
            "Documents" = { glyph = "󰈙"; hl = "MiniIconsAzure"; };
            "Downloads" = { glyph = "󰇚"; hl = "MiniIconsGreen"; };
            "Pictures" = { glyph = "󰉏"; hl = "MiniIconsYellow"; };
            "Wallpapers" = { glyph = "󰸉"; hl = "MiniIconsPurple"; };
            "Books" = { glyph = "󰂺"; hl = "MiniIconsOrange"; };
            "Games" = { glyph = "󰊗"; hl = "MiniIconsRed"; };
            "Music" = { glyph = "󰝚"; hl = "MiniIconsPurple"; };
            "Musics" = { glyph = "󰝚"; hl = "MiniIconsPurple"; };
            "Fire" = { glyph = "󰈸"; hl = "MiniIconsRed"; };
            "Vault" = { glyph = "󰌾"; hl = "MiniIconsBlue"; };
            "Config" = { glyph = "󰒓"; hl = "MiniIconsGrey"; };
          };
        };
        surround = {};
        ai = {};
        bracketed = {};
      };
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    mermaid-plugin
    vim-sleuth
  ];

  extraConfigLua = ''
    -- SVG is XML with a graphics vocabulary. Reuse the maintained XML
    -- grammar so tags, attributes and embedded text receive structural
    -- highlighting without pretending Snacks supports SVG preview directly.
    pcall(vim.filetype.add, { extension = { svg = "svg" } })
    pcall(vim.treesitter.language.register, "xml", { "svg" })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "svg",
      callback = function(args)
        pcall(vim.treesitter.start, args.buf, "xml")
      end,
    })
  '';

  # Runtime tools are explicit closure members. chafa/ImageMagick support
  # dashboard and image workflows; ffmpeg supports Snacks image formats.
  extraPackages = with pkgs; [
    git
    ripgrep
    fd
    gnumake
    nodejs
    jdk21
    maven
    gradle
    chafa
    imagemagick
    python3Packages.pylatexenc
    ffmpeg
    wl-clipboard
  ];
}

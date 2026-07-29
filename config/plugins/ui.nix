{ ... }:
{
  plugins = {
    nvim-tree = {
      enable = true;
      settings = {
        view = {
          width = 36;
          side = "left";
        };
        renderer = {
          group_empty = true;
          highlight_git = true;
        };
        filters = {
          dotfiles = false;
          git_ignored = false;
          custom = [
            ".direnv"
            ".git"
            ".result"
          ];
        };
        git.enable = true;
        diagnostics.enable = true;
      };
    };

    bufferline.enable = true;

    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "auto";
          globalstatus = true;
          component_separators = "";
          section_separators = "";
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "branch" "diff" "diagnostics" ];
          lualine_c = [ "filename" ];
          lualine_x = [ "encoding" "fileformat" "filetype" ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };

    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        open_mapping = "[[<c-\\>]]";
        shade_terminals = true;
        start_in_insert = true;
        persist_size = true;
        close_on_exit = true;
        float_opts = {
          border = "curved";
          winblend = 0;
        };
      };
    };
  };
}

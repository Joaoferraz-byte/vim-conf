{ pkgs, ... }:
{
  plugins.competitest.enable = true;

  extraPlugins = with pkgs.vimPlugins; [
    leetcode-nvim
  ];

  extraConfigLua = ''
    require("leetcode").setup({
      lang = "cpp",
      logging = false,
      plugins = {
        non_standalone = true,
      },
      picker = {
        provider = "snacks-picker",
      },
      editor = {
        reset_previous_code = false,
        fold_imports = true,
      },
      console = {
        open_on_runcode = true,
      },
    })
  '';

  keymaps = [
    {
      key = "<leader>pc";
      action = "<cmd>Leet menu<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open LeetCode Menu"; };
    }
    {
      key = "<leader>pd";
      action = "<cmd>Leet daily<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open LeetCode Daily"; };
    }
    {
      key = "<leader>pl";
      action = "<cmd>Leet list<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "List LeetCode Problems"; };
    }
    {
      key = "<leader>pr";
      action = "<cmd>Leet random<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Random LeetCode Problem"; };
    }
    {
      key = "<leader>pt";
      action = "<cmd>Leet test<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Test LeetCode Solution"; };
    }
    {
      key = "<leader>px";
      action = "<cmd>Leet submit<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Submit LeetCode Solution"; };
    }
  ];

  extraPackages = with pkgs; [
    clang
    clang-tools
    gcc
  ];
}

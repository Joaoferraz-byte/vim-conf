{ pkgs, ... }:
let
  plenary-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "plenary-nvim";
    version = "unstable-2026-09-19";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "74b06c6c75e4eeb3108ec01852001636d85a932b";
      hash = "sha256-nkfETDkPiE+Kd2BWYZijgUp9bP8RgFwRmvqJz2BMuq4=";
    };
    nvimSkipModules = [ "plenary.neorocks.init" ];
  };
  nui-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "nui-nvim";
    version = "unstable-2026-09-19";
    src = pkgs.fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "nui.nvim";
      rev = "10fc361835c856ba4233ef5ea135b919bf3dce97";
      hash = "sha256-UJp9A5Qb38ie552wRdHAeA9vm5PFURumYP9wZ83OU7Y=";
    };
  };
in
{
  plugins.competitest.enable = true;

  extraPlugins = with pkgs.vimPlugins; [
    plenary-nvim
    nui-nvim
    leetcode-nvim
  ];

  extraConfigLua = ''
    require("leetcode").setup({
      lang = "java",
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
      description = {
        position = "left",
        width = "36%",
        show_stats = true,
      },
      console = {
        open_on_runcode = true,
      },
    })
  '';

  keymaps = [
    {
      key = "<leader>p";
      action = "<cmd>Leet<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open LeetCode Menu"; };
    }
    {
      key = "<leader>pc";
      action = "<cmd>Leet<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open LeetCode Menu"; };
    }
    {
      key = "<leader>pd";
      action = "<cmd>lua require(\"leetcode.command\").qot()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open LeetCode Daily"; };
    }
    {
      key = "<leader>pl";
      action = "<cmd>lua require(\"leetcode.command\").problems({})<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "List LeetCode Problems"; };
    }
    {
      key = "<leader>pr";
      action = "<cmd>lua require(\"leetcode.command\").random_question({})<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Random LeetCode Problem"; };
    }
    {
      key = "<leader>pt";
      action = "<cmd>lua require(\"leetcode.command\").q_run()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Test LeetCode Solution"; };
    }
    {
      key = "<leader>px";
      action = "<cmd>lua require(\"leetcode.command\").q_submit()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Submit LeetCode Solution"; };
    }
  ];

  extraPackages = with pkgs; [
    jdk21
  ];
}

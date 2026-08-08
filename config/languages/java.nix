{ pkgs, ... }:
let
  intellij-lsp-plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-intellij-lsp";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "gipo355";
      repo = "nvim-intellij-lsp";
      rev = "4f51c0270b5e1369569c5a7b00d3831d3ec05616";
      hash = "sha256-5/ZAOUCEYGM9bqMQFfVbM6wzZI5exLAciPQXYjEDcj4=";
    };
    doCheck = false;
  };
in
{
  # IntelliJ LSP (JetBrains "Java by IntelliJ IDEA" server).
  # The server ships its own bundled JBR and downloads from the JetBrains CDN
  # on first :IntellijInstall; a JDK is still needed for symbol resolution.
  plugins.jdtls.enable = false;

  plugins.neotest = {
    enable = true;
    settings = {
      adapters = [
        { __raw = ''require("neotest-java")''; }
      ];
    };
  };

  extraPlugins = [
    intellij-lsp-plugin
    pkgs.vimPlugins.neotest-java
  ];

  extraPackages = with pkgs; [
    jdk21
    jdt-language-server
    lombok
    maven
    gradle
    curl
  ];

  extraConfigLua = ''
    local ok = pcall(require, "intellij-lsp")
    if not ok then
      return
    end
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      once = true,
      callback = function()
        pcall(vim.lsp.config, "intellij", {
          init_options = { defaultSdk = "${pkgs.jdk21}" },
          cmd_env = { JDK_HOME = "${pkgs.jdk21}" },
        })
        pcall(vim.lsp.enable, "intellij")
      end,
    })
    require("intellij-lsp").setup({
      jdk = "${pkgs.jdk21}/bin/java",
      accept_eula = true,
      inlay_hints = true,
      codelens = true,
      organize_imports_on_save = true,
      workspace_dir = vim.fn.stdpath("cache") .. "/intellij-lsp",
      isolate_index = true,
    })
  '';
}

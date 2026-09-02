{ pkgs, ... }:
{
  # IntelliJ LSP is provided by the IntelliJ LSP Server plugin running in an
  # open IntelliJ project. The plugin exposes a TCP server on port 2087.
  # Neovim connects to that already-running server instead of starting JDTLS.
  extraConfigLua = ''
    local intellij_lsp = {}
    intellij_lsp.host = "127.0.0.1"
    intellij_lsp.port = 2087

    function intellij_lsp.start()
      local bufnr = vim.api.nvim_get_current_buf()
      local root_dir = vim.fs.root(bufnr, { "pom.xml", "mvnw", "build.gradle", "build.gradle.kts", "gradlew", ".git" })
        or vim.fn.getcwd()

      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "intellij-lsp" })) do
        return client.id
      end

      local ok, rpc = pcall(vim.lsp.rpc.connect, intellij_lsp.host, intellij_lsp.port)
      if not ok then
        vim.notify("IntelliJ LSP is unavailable on 127.0.0.1:2087. Open IntelliJ with the LSP Server plugin first.", vim.log.levels.WARN)
        return
      end

      local client_id = vim.lsp.start({
        name = "intellij-lsp",
        cmd = function() return rpc end,
        root_dir = root_dir,
        workspace_folders = { { uri = vim.uri_from_fname(root_dir), name = vim.fn.fnamemodify(root_dir, ":t") } },
        on_attach = function(_, attached_bufnr)
          vim.notify("IntelliJ LSP attached", vim.log.levels.INFO)
          vim.api.nvim_buf_create_user_command(attached_bufnr, "JavaOrganizeImports", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" }, diagnostics = {} },
              apply = true,
            })
          end, { desc = "Organize Java imports through IntelliJ LSP" })
        end,
      }, { bufnr = bufnr })

      if not client_id then
        vim.notify("Failed to attach IntelliJ LSP. Verify that IntelliJ is open and indexed.", vim.log.levels.WARN)
      end
      return client_id
    end

    function intellij_lsp.stop()
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "intellij-lsp" })) do
        vim.lsp.stop_client(client.id)
      end
    end

    function intellij_lsp.restart()
      intellij_lsp.stop()
      vim.schedule(intellij_lsp.start)
    end

    _G.livara_intellij_lsp_start = intellij_lsp.start
    _G.livara_intellij_lsp_stop = intellij_lsp.stop
    _G.livara_intellij_lsp_restart = intellij_lsp.restart

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "java", "kotlin" },
      callback = intellij_lsp.start,
      desc = "Connect Java/Kotlin buffers to IntelliJ LSP",
    })
  '';

  # JDTLS is intentionally disabled: IntelliJ provides the semantic analysis,
  # completion and diagnostics through the external LSP connection above.
  plugins.jdtls.enable = false;
  plugins.lsp.servers.jdtls.enable = false;

  plugins.neotest = {
    enable = true;
    settings = {
      adapters = [
        { __raw = ''require("neotest-java")''; }
      ];
    };
  };

  extraPlugins = [
    pkgs.vimPlugins.neotest-java
  ];

  extraPackages = with pkgs; [
    maven
    gradle
  ];
}

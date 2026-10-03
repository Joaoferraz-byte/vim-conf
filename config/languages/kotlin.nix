{ pkgs, ... }:
{
  # Opt-in path: kotlin-lsp is Alpha; do not enable the deprecated
  # kotlin-lsp is provisioned by nix-conf; enable it with vim.lsp.config in a project
  # once the pinned upstream CLI is available.
  # kotlin_language_server or start a second JDTLS client for Kotlin.
  extraConfigLua = ''
    if vim.fn.executable("kotlin-lsp") == 1 then
      vim.lsp.config("kotlin_lsp", {
        cmd = { "kotlin-lsp" },
        filetypes = { "kotlin" },
        root_markers = { "gradlew", "mvnw", "settings.gradle.kts", "pom.xml", ".git" },
      })
      vim.lsp.enable("kotlin_lsp")
    end
  '';
  extraPackages = with pkgs; [ jdk21 maven gradle ];
}

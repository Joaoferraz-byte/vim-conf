{ pkgs, ... }:
let
  extensionRoot = package: name: "${package}/share/vscode/extensions/${name}";
in
{
  plugins.java = {
    enable = true;
    settings = {
      root_markers = [
        "pom.xml"
        "mvnw"
        "build.gradle"
        "build.gradle.kts"
        "gradlew"
        "settings.gradle"
        "settings.gradle.kts"
        ".git"
      ];
      jdtls = {
        path = "${pkgs.jdt-language-server}/share/java/jdtls";
        auto_install = false;
      };
      jdk = {
        path = "${pkgs.jdk21}";
        auto_install = false;
      };
      lombok = {
        enable = true;
        path = "${pkgs.lombok}/share/java/lombok.jar";
        auto_install = false;
      };
      java_test = {
        enable = true;
        path = extensionRoot pkgs.vscode-extensions.vscjava.vscode-java-test "vscjava.vscode-java-test";
        auto_install = false;
      };
      java_debug_adapter = {
        enable = true;
        path = extensionRoot pkgs.vscode-extensions.vscjava.vscode-java-debug "vscjava.vscode-java-debug";
        auto_install = false;
      };
      spring_boot_tools = {
        enable = true;
        auto_install = true;
        version = "1.55.1";
      };
      log = {
        use_console = true;
        use_file = true;
        level = "info";
      };
    };
  };

  plugins.neotest = {
    enable = true;
    settings.adapters = [
      { __raw = ''require("neotest-java")''; }
    ];
  };

  extraPlugins = with pkgs.vimPlugins; [
    neotest-java
    spring-boot-nvim
  ];

  extraConfigLuaPost = ''
    vim.lsp.config("jdtls", {
      settings = {
        java = {
          configuration = {
            updateBuildConfiguration = "automatic";
            importOnFirstTimeStartup = "automatic";
            runtimes = {
              { name = "JavaSE-1.8"; path = "${pkgs.jdk8}"; };
              { name = "JavaSE-21"; path = "${pkgs.jdk21}"; default = true; };
            };
          };
          eclipse = {
            downloadSources = true;
            downloadJavadocs = true;
          };
          maven = {
            downloadSources = true;
            updateSnapshots = true;
          };
          references = { includeDecompiledSources = true; };
      errors = { incompleteClasspath = { severity = "warning"; }; };
      signatureHelp = { enabled = true; };
      implementationsCodeLens = { enabled = true; };
      referencesCodeLens = { enabled = true; };
      format = { enabled = true; };
      saveActions = { organizeImports = false; };
          completion = {
            importOnCompletion = true;
            favoriteStaticMembers = {
              "org.junit.Assert.*";
              "org.junit.Assume.*";
              "org.junit.jupiter.api.Assertions.*";
              "org.junit.jupiter.api.Assumptions.*";
              "org.mockito.Mockito.*";
              "org.mockito.ArgumentMatchers.*";
            };
            importOrder = { "java"; "javax"; "org"; "com"; ""; };
          };
        };
      };
      filetypes = { "java"; };
      root_markers = {
        { "pom.xml"; "mvnw"; };
        { "build.gradle"; "build.gradle.kts"; "gradlew"; "settings.gradle"; "settings.gradle.kts"; };
        { ".git"; };
      };
    });
    vim.lsp.enable("jdtls");
  '';

  extraPackages = with pkgs; [
    jdk21
    jdk8
    jdt-language-server
    lombok
    maven
    gradle
    unzip
    vscode-extensions.vscjava.vscode-java-test
    vscode-extensions.vscjava.vscode-java-debug
  ];
}

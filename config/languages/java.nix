{ pkgs, ... }:
let
  extensionRoot = package: name: "${package}/share/vscode/extensions/${name}";
  jdtlsRoot = "${pkgs.jdt-language-server}/share/java/jdtls";
  javaRuntime = "${pkgs.jdk25}";
  projectRuntime = "${pkgs.jdk21}";
  legacyRuntime = "${pkgs.jdk8}";
  lombokJar = "${pkgs.lombok}/share/java/lombok.jar";
  javaTestExtension = extensionRoot pkgs.vscode-extensions.vscjava.vscode-java-test "vscjava.vscode-java-test";
  javaDebugExtension = extensionRoot pkgs.vscode-extensions.vscjava.vscode-java-debug "vscjava.vscode-java-debug";
in
{
  plugins.java = {
    enable = true;
    settings = {
      checks = {
        nvim_version = true;
        nvim_jdtls_conflict = true;
      };
      root_markers = [
        "settings.gradle"
        "settings.gradle.kts"
        "pom.xml"
        "build.gradle"
        "build.gradle.kts"
        "mvnw"
        "gradlew"
        ".git"
      ];
      jdtls = {
        path = jdtlsRoot;
        auto_install = false;
      };
      jdk = {
        path = javaRuntime;
        auto_install = false;
      };
      lombok = {
        enable = true;
        path = lombokJar;
        auto_install = false;
      };
      java_test = {
        enable = true;
        path = javaTestExtension;
        auto_install = false;
      };
      java_debug_adapter = {
        enable = true;
        path = javaDebugExtension;
        auto_install = false;
      };
      spring_boot_tools = {
        enable = false;
        auto_install = false;
      };
      log = {
        use_console = true;
        use_file = true;
        level = "warn";
        log_file.__raw = "vim.fn.stdpath('state') .. '/nvim-java.log'";
        max_lines = 1000;
        show_location = false;
      };
    };
  };

  plugins.spring-boot = {
    enable = true;
    settings = {
      java_cmd = "${javaRuntime}/bin/java";
      server.root_dir.__raw = ''vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" })'';
      autocmd = true;
    };
  };

  plugins.neotest = {
    enable = true;
    adapters.java.enable = true;
  };

  extraConfigLuaPost = ''
    vim.lsp.config("jdtls", {
      settings = {
        java = {
          configuration = {
            updateBuildConfiguration = "interactive";
            importOnFirstTimeStartup = "automatic";
            runtimes = {
              { name = "JavaSE-8"; path = "${legacyRuntime}"; };
              { name = "JavaSE-21"; path = "${projectRuntime}"; default = true; };
              { name = "JavaSE-25"; path = "${javaRuntime}"; };
            };
          };
          eclipse = {
            downloadSources = true;
            downloadJavadocs = true;
          };
          maven = {
            downloadSources = true;
            updateSnapshots = false;
          };
          references = { includeDecompiledSources = true; };
          errors = { incompleteClasspath = { severity = "warning"; }; };
          signatureHelp = { enabled = true; };
          implementationsCodeLens = { enabled = true; };
          referencesCodeLens = { enabled = true; };
          format = { enabled = true; };
          saveActions = { organizeImports = true; };
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
        { "settings.gradle"; "settings.gradle.kts"; "pom.xml"; };
        { "build.gradle"; "build.gradle.kts"; "mvnw"; "gradlew"; };
      };
      single_file_support = true;
    });
    vim.lsp.enable("jdtls");
  '';

  extraPackages = with pkgs; [
    jdk8
    jdk21
    jdk25
    jdt-language-server
    lombok
    maven
    gradle
    unzip
    vscode-extensions.vscjava.vscode-java-test
    vscode-extensions.vscjava.vscode-java-debug
  ];
}

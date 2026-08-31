{ pkgs, ... }:
{
  # The jdtls launcher parses JDTLS_JVM_ARGS into --jvm-arg parameters.
  # Passing --jvm-arg=-javaagent directly in cmd makes the server itself
  # reject it as "Unrecognized option", as seen in the host LSP log.
  extraConfigLua = ''
    vim.env.JDTLS_JVM_ARGS = "-javaagent:${pkgs.lombok}/share/java/lombok.jar"
  '';

  # Keep Java on the declarative, NixOS-native JDTLS path. A downloaded
  # preview launcher would place a generic ELF into $XDG_DATA_HOME and fail
  # before the LSP handshake on NixOS because it is not patched for the
  # system dynamic linker.
  plugins.jdtls = {
    enable = true;
    jdtLanguageServerPackage = pkgs.jdt-language-server;
    settings = {
      cmd = [ "jdtls" ];
      settings = {
        java = {
          configuration = {
            updateBuildConfiguration = "automatic";
            runtimes = [
              {
                name = "JavaSE-1.8";
                path = "${pkgs.jdk8}";
              }
              {
                name = "JavaSE-21";
                path = "${pkgs.jdk21}";
                default = true;
              }
            ];
          };
          "import" = {
            maven.enabled = true;
            gradle = {
              enabled = true;
              wrapper.enabled = true;
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
          references = {
            includeDecompiledSources = true;
          };
          signatureHelp = {
            enabled = true;
          };
          implementationsCodeLens = {
            enabled = true;
          };
          referencesCodeLens = {
            enabled = true;
          };
          format = {
            enabled = true;
          };
          saveActions = {
            organizeImports = true;
          };
          completion = {
            favoriteStaticMembers = [
              "org.junit.Assert.*"
              "org.junit.Assume.*"
              "org.junit.jupiter.api.Assertions.*"
              "org.junit.jupiter.api.Assumptions.*"
              "org.mockito.Mockito.*"
              "org.mockito.ArgumentMatchers.*"
            ];
            importOrder = [
              "java"
              "javax"
              "org"
              "com"
              ""
            ];
          };
        };
      };
      init_options = {
        bundles = [ ];
      };
    };
  };

  # Native LSP root markers keep one JDTLS workspace per project root and
  # prevent a Java buffer from attaching to an unrelated parent workspace.
  plugins.lsp.servers.jdtls = {
    filetypes = [ "java" ];
    rootMarkers = [
      "pom.xml"
      "mvnw"
      "build.gradle"
      "build.gradle.kts"
      "gradlew"
      "settings.gradle"
      "settings.gradle.kts"
      ".git"
    ];
  };

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
    jdk21
    jdt-language-server
    lombok
    maven
    gradle
  ];
}

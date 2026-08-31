{
  # Keep Java on the declarative, NixOS-native JDTLS path. A downloaded
  # preview launcher would place a generic ELF into $XDG_DATA_HOME and fail
  # before the LSP handshake on NixOS because it is not patched for the
  # system dynamic linker.
  plugins.jdtls = {
    enable = true;
    jdtLanguageServerPackage = pkgs.jdt-language-server;
    settings = {
      cmd = [
        "jdtls"
        "--jvm-arg=-javaagent=${pkgs.lombok}/share/java/lombok.jar"
      ];
      root_dir.__raw = ''
        require("jdtls.setup").find_root({
          ".git",
          "mvnw",
          "pom.xml",
          "gradlew",
          "build.gradle",
          "build.gradle.kts",
          "settings.gradle",
          "settings.gradle.kts",
        })
      '';
      settings = {
        java = {
          configuration = {
            runtimes = [
              {
                name = "JavaSE-21";
                path = "${pkgs.jdk21}";
                default = true;
              }
            ];
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

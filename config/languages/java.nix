{ pkgs, ... }:
{
  # JDTLS
  plugins.jdtls = {
    enable = true;
    autoLoad = true;
    jdtLanguageServerPackage = pkgs.jdt-language-server;
  };

  # Spring Boot LS is not shipped by nixpkgs and is not installed through Mason.
  # Keep JDTLS fully enabled, but do not initialize spring-boot.nvim until its
  # VMware language-server bundle is explicitly provisioned.
  plugins.spring-boot = {
    enable = false;
    autoLoad = true;
    settings = {
      autocmd = true;
      java_cmd = "${pkgs.jdk21}/bin/java";
      server = {
        root_dir = {
          __raw = "vim.fs.root(0, { '.git', 'mvnw', 'gradlew' })";
        };
      };
    };
  };

  # Neotest
  plugins.neotest = {
    enable = true;
    settings = {
      adapters = [
        { __raw = ''require("neotest-java")''; }
      ];
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    neotest-java
  ];

  extraPackages = with pkgs; [
    jdk21
    jdt-language-server
    lombok
    maven
    gradle
  ];

  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local ok, jdtls = pcall(require, "jdtls")
        if not ok then
          return
        end

        local function on_attach(_, _)
          pcall(jdtls.setup_dap, {
            hotcodereplace = "auto",
            config_overrides = {},
          })

          vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = vim.api.nvim_get_current_buf(),
            callback = function()
              pcall(vim.cmd, "JdtOrganizeImports")
            end,
            once = true,
          })
        end

        local root_markers = {
          ".git",
          "mvnw",
          "gradlew",
          "pom.xml",
          "build.gradle",
          "build.gradle.kts",
          "settings.gradle",
          "settings.gradle.kts",
        }

        local root_dir = require("jdtls.setup").find_root(root_markers)
        if root_dir == nil then
          return
        end

        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name
        local config_dir = workspace_dir .. "/config"

        local config = {
          cmd = {
            "${pkgs.jdt-language-server}/bin/jdtls",
            "--jvm-arg=-javaagent:${pkgs.lombok}/share/java/lombok.jar",
            "-configuration",
            config_dir,
            "-data",
            workspace_dir,
          },
          root_dir = root_dir,
          settings = {
            java = {
              eclipse = { downloadSources = true },
              maven = { downloadSources = true },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens = { enabled = true },
              references = { includeDecompiledSources = true },
              format = { enabled = true },
              saveActions = { organizeImports = true },
              completion = {
                favoriteStaticMembers = {
                  "org.junit.jupiter.api.Assertions.*",
                  "org.junit.jupiter.api.Assumptions.*",
                  "org.junit.jupiter.api.DynamicContainer.*",
                  "org.junit.jupiter.api.DynamicTest.*",
                  "org.mockito.Mockito.*",
                  "org.mockito.ArgumentMatchers.*",
                  "org.mockito.Answers.*",
                },
                filteredTypes = {
                  "com.sun.*",
                  "io.micrometer.shaded.*",
                  "java.awt.*",
                  "jdk.*",
                  "sun.*",
                },
              },
              inlayHints = {
                parameterNames = { enabled = "all" },
              },
              configuration = {
                runtimes = {
                  {
                    name = "JavaSE-21",
                    path = "${pkgs.jdk21}",
                    default = true,
                  },
                },
              },
              codeGeneration = {
                toString = {
                  template = "${"$"}{object.className}{${"$"}{member.name()}=${"$"}{member.value}, ${"$"}{otherMembers}}",
                },
                useBlocks = true,
              },
            },
          },
          on_attach = on_attach,
          init_options = {
            bundles = {},
          },
        }

        jdtls.start_or_attach(config)
      end,
    })
  '';
}

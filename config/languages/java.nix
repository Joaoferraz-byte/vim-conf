{ pkgs, ... }:
{
  # ─── JDTLS nativo do Nixvim ───
  plugins.jdtls = {
    enable = true;
    autoLoad = true;
    jdtLanguageServerPackage = pkgs.jdt-language-server;
  };

  # ─── Spring Boot nativo do Nixvim ───
  plugins.spring-boot = {
    enable = true;
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

  # ─── Neotest + neotest-java (Test Runner Inline) ───
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

  # Configurações avançadas do JDTLS via extraConfigLua
  extraConfigLua = ''
    -- Configurações avançadas do JDTLS (settings, root_markers, dap integration)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        -- Configurar inlay hints para nomes de parâmetros
        local ok, jdtls = pcall(require, "jdtls")
        if not ok then
          return
        end

        -- Override settings do JDTLS para comportamento avançado
        local function on_attach(_, _)
          -- Habilitar DAP para Java com hot code replace
          pcall(jdtls.setup_dap, {
            hotcodereplace = "auto",
            config_overrides = {},
          })

          -- Organizar imports ao salvar
          vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = vim.api.nvim_get_current_buf(),
            callback = function()
              pcall(vim.cmd, "JdtOrganizeImports")
            end,
            once = true,
          })
        end

        -- Encontrar root do projeto
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

        -- Configurar workspace por projeto
        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name
        local config_dir = workspace_dir .. "/config"

        -- Iniciar/reattach JDTLS com configuração completa
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

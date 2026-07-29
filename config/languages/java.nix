{ pkgs, ... }:
{
  # JDTLS é iniciado pelo nvim-jdtls abaixo para que cada projeto receba
  # seu workspace, raízes Maven/Gradle e suporte de depuração corretamente.
  plugins.lsp.servers.jdtls.enable = false;

  extraPlugins = with pkgs.vimPlugins; [
    nvim-jdtls
    spring-boot-nvim
  ];

  extraPackages = with pkgs; [
    jdk21
    jdt-language-server
    lombok
    maven
    gradle
  ];

  extraConfigLua = ''
    local function start_jdtls()
      local ok, jdtls = pcall(require, "jdtls")
      if not ok then
        return
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
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local config = {
        cmd = {
          "${pkgs.jdt-language-server}/bin/jdtls",
          "--jvm-arg=-javaagent:${pkgs.lombok}/share/java/lombok.jar",
          "-data",
          workspace_dir,
        },
        root_dir = root_dir,
        capabilities = capabilities,
        settings = {
          java = {
            eclipse = { downloadSources = true },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
            references = { includeDecompiledSources = true },
            format = { enabled = true },
            saveActions = { organizeImports = true },
            configuration = {
              runtimes = {
                {
                  name = "JavaSE-21",
                  path = "${pkgs.jdk21}",
                  default = true,
                },
              },
            },
          },
        },
        on_attach = function(_, _)
          pcall(jdtls.setup_dap, { hotcodereplace = "auto" })
        end,
      }

      jdtls.start_or_attach(config)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = start_jdtls,
    })

    pcall(function()
      require("spring_boot").setup()
    end)
  '';
}

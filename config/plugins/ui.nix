# ─── UI Plugins ───────────────────────────────────────────────────────────────
# NOTE: Este módulo é importado no contexto do sistema de módulos do nixvim,
# não no contexto do Home Manager. As opções devem estar no nível raiz do
# módulo nixvim (plugins, opts, etc.) — NÃO dentro de programs.nixvim.
{ ... }:
{
  plugins = {
    # ─── Dashboard-nvim (Centralizado Verticalmente) ───
    dashboard = {
      enable = true;
      settings = {
        theme = "doom";
        config = {
          header = [
            ""
            ""
            ""
            ""
            "██╗     ██╗██╗   ██╗ █████╗ ██████╗  █████╗ "
            "██║     ██║██║   ██║██╔══██╗██╔══██╗██╔══██╗"
            "██║     ██║██║   ██║███████║██████╔╝███████║"
            "██║     ██║╚██╗ ██╔╝██╔══██║██╔══██╗██╔══██║"
            "███████╗██║ ╚████╔╝ ██║  ██║██║  ██║██║  ██║"
            "╚══════╝╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
            ""
            ""
          ];
          center = [
            {
              icon = "  ";
              desc = "Find File";
              action = "Telescope find_files";
              key = "f";
            }
            {
              icon = "  ";
              desc = "New File";
              action = "lua _G.advanced_new_file()";
              key = "n";
            }
            {
              icon = "  ";
              desc = "Spring Boot";
              action = "lua _G.spring_boot_wizard()";
              key = "s";
            }
            {
              icon = "  ";
              desc = "Find Text";
              action = "Telescope live_grep";
              key = "g";
            }
            {
              icon = "  ";
              desc = "Projects";
              action = "Telescope projects";
              key = "p";
            }
            {
              icon = "  ";
              desc = "Config";
              action = "NvimTreeOpen ~/.config/nvim";
              key = "c";
            }
            {
              icon = "󰋗  ";
              desc = "Browse All Keymaps";
              action = "lua require('which-key').show({ global = true })";
              key = "?";
            }
            {
              icon = "󰗼  ";
              desc = "Quit";
              action = "qa";
              key = "q";
            }
          ];
          footer = [ "" ];
        };
      };
    };
  };
}

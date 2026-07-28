require("snacks").setup({
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { section = "startup" },
    },
    preset = {
      header = [[
                        LIVARA
      Neovim declarativo — C/C++ · Java · Kotlin · Angular · Manim
      ]],
      keys = {
        { icon = " ", key = "f", desc = "Procurar Arquivo", action = ":Telescope find_files" },
        { icon = " ", key = "n", desc = "Novo Arquivo", action = ":enew" },
        { icon = " ", key = "r", desc = "Arquivos Recentes", action = ":Telescope oldfiles" },
        { icon = "󰙅 ", key = "e", desc = "Explorar Arquivos", action = ":NvimTreeToggle" },
        { icon = " ", key = "c", desc = "Configuração", action = ":e $HOME/Projects/nix-conf/flake.nix" },
        { icon = " ", key = "q", desc = "Sair do Neovim", action = ":qa" },
      },
    },
  },
})

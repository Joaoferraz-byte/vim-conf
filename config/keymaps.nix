{ ... }:
{
  globals.mapleader = " ";
  globals.maplocalleader = " ";

  keymaps = [
    # ─── Geral ───
    {
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Limpar destaque de busca"; };
    }
    {
      key = "<C-s>";
      action = "<cmd>w<CR>";
      mode = [ "n" "i" ];
      options = { silent = true; desc = "Salvar arquivo"; };
    }
    {
      key = "<leader>e";
      action = "<cmd>NvimTreeToggle<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Alternar NvimTree"; };
    }
    {
      key = "<leader>d";
      action = "<cmd>Dashboard<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Abrir Dashboard"; };
    }

    # ─── Categoria Novo (<leader>n) ───
    {
      key = "<leader>nf";
      action = "<cmd>lua _G.advanced_new_file()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Novo Arquivo (Avançado)"; };
    }
    {
      key = "<leader>ns";
      action = "<cmd>lua _G.spring_boot_wizard()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Novo Projeto Spring Boot"; };
    }

    # ─── Oil ───
    {
      key = "-";
      action = "<cmd>Oil<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Abrir Oil (File Explorer)"; };
    }

    # ─── Categoria Buscar (<leader>f) ───
    {
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Buscar Arquivos"; };
    }
    {
      key = "<leader>fg";
      action = "<cmd>Telescope live_grep<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Buscar Texto"; };
    }
    {
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Listar Buffers"; };
    }
    {
      key = "<leader>fp";
      action = "<cmd>Telescope projects<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Listar Projetos"; };
    }

    # ─── Categoria Configuração (<leader>c) ───
    {
      key = "<leader>cn";
      action = "<cmd>NvimTreeOpen ~/.config/nvim<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Configuração do Neovim"; };
    }
    {
      key = "<leader>cs";
      action = "<cmd>NvimTreeOpen /etc/nixos<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Configuração do Sistema"; };
    }

    # ─── Flash ───
    {
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      mode = [ "n" "x" "o" ];
      options = { silent = true; desc = "Flash: Jump"; };
    }

    # ─── Smart Splits ───
    {
      key = "<C-h>";
      action.__raw = "function() require('smart-splits').move_cursor_left() end";
      mode = [ "n" "t" ];
    }
    {
      key = "<C-j>";
      action.__raw = "function() require('smart-splits').move_cursor_down() end";
      mode = [ "n" "t" ];
    }
    {
      key = "<C-k>";
      action.__raw = "function() require('smart-splits').move_cursor_up() end";
      mode = [ "n" "t" ];
    }
    {
      key = "<C-l>";
      action.__raw = "function() require('smart-splits').move_cursor_right() end";
      mode = [ "n" "t" ];
    }

    # ─── Categoria LSP/Linguagens (<leader>l) ───
    {
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      mode = [ "n" ];
      options = { desc = "Ir para Definição"; };
    }
    {
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      mode = [ "n" ];
      options = { desc = "Hover Info"; };
    }
    {
      key = "<leader>la";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      mode = [ "n" "v" ];
      options = { desc = "Code Action"; };
    }
    {
      key = "<leader>lf";
      action = "<cmd>ConformFormat<CR>";
      mode = [ "n" ];
      options = { desc = "Formatar Buffer"; };
    }
    {
      key = "<leader>lr";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      mode = [ "n" ];
      options = { desc = "Renomear Símbolo"; };
    }
  ];
}

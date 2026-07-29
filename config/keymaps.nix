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
    {
      key = "<leader>nf";
      action = "<cmd>lua _G.advanced_new_file()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Criar novo arquivo (Avançado)"; };
    }
    {
      key = "-";
      action = "<cmd>Oil<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Abrir Oil (File Explorer)"; };
    }

    # ─── Telescope ───
    {
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Buscar arquivos"; };
    }
    {
      key = "<leader>fg";
      action = "<cmd>Telescope live_grep<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Buscar texto"; };
    }
    {
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Buffers"; };
    }
    {
      key = "<leader>fp";
      action = "<cmd>Telescope projects<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Projetos"; };
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

    # ─── LSP ───
    {
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      mode = [ "n" ];
    }
    {
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      mode = [ "n" ];
    }
    {
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      mode = [ "n" "v" ];
    }
    {
      key = "<leader>lf";
      action = "<cmd>ConformFormat<CR>";
      mode = [ "n" ];
    }
  ];
}

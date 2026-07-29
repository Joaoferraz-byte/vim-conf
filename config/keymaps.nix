{ ... }:
{
  globals.mapleader = " ";
  globals.maplocalleader = " ";

  keymaps = [
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
      key = "<leader>q";
      action = "<cmd>qa<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Sair"; };
    }
    {
      key = "<leader>bd";
      action = "<cmd>bdelete<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Fechar buffer"; };
    }

    {
      key = "<leader>e";
      action = "<cmd>NvimTreeToggle<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Alternar explorador"; };
    }
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
      options = { silent = true; desc = "Buscar conteúdo"; };
    }
    {
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Buffers"; };
    }
    {
      key = "<leader>fd";
      action = "<cmd>Telescope diagnostics<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Diagnósticos"; };
    }

    {
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Ir para definição"; };
    }
    {
      key = "gD";
      action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Ir para declaração"; };
    }
    {
      key = "gi";
      action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Ir para implementação"; };
    }
    {
      key = "gr";
      action = "<cmd>lua vim.lsp.buf.references()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Referências"; };
    }
    {
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Documentação"; };
    }
    {
      key = "<leader>rn";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Renomear símbolo"; };
    }
    {
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      mode = [ "n" "v" ];
      options = { silent = true; desc = "Ação de código"; };
    }
    {
      key = "<leader>lf";
      action = "<cmd>ConformFormat<CR>";
      mode = [ "n" "v" ];
      options = { silent = true; desc = "Formatar"; };
    }
    {
      key = "<leader>ld";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Lista de diagnósticos"; };
    }

    {
      key = "<C-\\>";
      action = "<cmd>ToggleTerm direction=float<CR>";
      mode = [ "n" "t" ];
      options = { silent = true; desc = "Terminal flutuante"; };
    }

    {
      key = "<leader>db";
      action = "<cmd>lua require('dap').toggle_breakpoint()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Alternar breakpoint"; };
    }
    {
      key = "<leader>dc";
      action = "<cmd>lua require('dap').continue()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Continuar depuração"; };
    }
    {
      key = "<leader>dn";
      action = "<cmd>lua require('dap').step_over()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Passar por cima"; };
    }
    {
      key = "<leader>di";
      action = "<cmd>lua require('dap').step_into()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Entrar na chamada"; };
    }
    {
      key = "<leader>do";
      action = "<cmd>lua require('dap').step_out()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Sair da chamada"; };
    }
    {
      key = "<leader>du";
      action = "<cmd>lua require('dapui').toggle()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Alternar interface DAP"; };
    }

    {
      key = "<leader>jo";
      action = "<cmd>JdtOrganizeImports<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Java: organizar imports"; };
    }
    {
      key = "<leader>ju";
      action = "<cmd>JdtUpdateConfig<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Java: atualizar configuração"; };
    }
  ];

  autoGroups = {
    nixvim_yank = { };
  };

  autoCmd = [
    {
      event = "TextYankPost";
      group = "nixvim_yank";
      command = "lua vim.highlight.on_yank({ higroup = 'Visual', timeout = 180 })";
    }
  ];
}

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

    # ─── Dashboard ───
    {
      key = "<leader>d";
      action = ":lua Snacks.dashboard()";
      mode = [ "n" ];
      options = { silent = true; desc = "Abrir dashboard"; };
    }

    # ─── Navegação / Busca ───
    {
      key = "<leader>e";
      action = ":lua Snacks.explorer()";
      mode = [ "n" ];
      options = { silent = true; desc = "Alternar explorador de arquivos"; };
    }
    {
      key = "<leader>ff";
      action = ":lua Snacks.picker.files()";
      mode = [ "n" ];
      options = { silent = true; desc = "Buscar arquivos"; };
    }
    {
      key = "<leader>fg";
      action = ":lua Snacks.picker.grep()";
      mode = [ "n" ];
      options = { silent = true; desc = "Buscar conteúdo"; };
    }
    {
      key = "<leader>fb";
      action = ":lua Snacks.picker.buffers()";
      mode = [ "n" ];
      options = { silent = true; desc = "Buffers"; };
    }
    {
      key = "<leader>fd";
      action = ":lua Snacks.picker.diagnostics()";
      mode = [ "n" ];
      options = { silent = true; desc = "Diagnósticos"; };
    }
    {
      key = "<leader>fr";
      action = ":lua Snacks.picker.recent()";
      mode = [ "n" ];
      options = { silent = true; desc = "Arquivos recentes"; };
    }
    {
      key = "<leader>fp";
      action = ":lua Snacks.picker.projects()";
      mode = [ "n" ];
      options = { silent = true; desc = "Projetos"; };
    }
    {
      key = "<leader>f:";
      action = ":lua Snacks.picker.command_history()";
      mode = [ "n" ];
      options = { silent = true; desc = "Histórico de comandos"; };
    }

    # ─── Telescope (fallback compatibilidade) ───
    {
      key = "<leader>tf";
      action = "<cmd>Telescope find_files<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Telescope: buscar arquivos"; };
    }
    {
      key = "<leader>tg";
      action = "<cmd>Telescope live_grep<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Telescope: buscar conteúdo"; };
    }
    {
      key = "<leader>tb";
      action = "<cmd>Telescope buffers<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Telescope: buffers"; };
    }

    # ─── Aerial (outline) ───
    {
      key = "<leader>o";
      action = "<cmd>AerialToggle<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Alternar outline"; };
    }
    {
      key = "<leader>on";
      action = "<cmd>AerialNavToggle<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Alternar navegação outline"; };
    }

    # ─── Harpoon ───
    {
      key = "<leader>ha";
      action.__raw = "function() require('harpoon'):list():add() end";
      mode = [ "n" ];
      options = { silent = true; desc = "Harpoon: marcar arquivo"; };
    }
    {
      key = "<leader>ht";
      action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Harpoon: lista rápida"; };
    }
    {
      key = "<leader>h1";
      action.__raw = "function() require('harpoon'):list():select(1) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Harpoon: ir para 1"; };
    }
    {
      key = "<leader>h2";
      action.__raw = "function() require('harpoon'):list():select(2) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Harpoon: ir para 2"; };
    }
    {
      key = "<leader>h3";
      action.__raw = "function() require('harpoon'):list():select(3) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Harpoon: ir para 3"; };
    }
    {
      key = "<leader>h4";
      action.__raw = "function() require('harpoon'):list():select(4) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Harpoon: ir para 4"; };
    }

    # ─── Flash ───
    {
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      mode = [ "n" "x" "o" ];
      options = { silent = true; desc = "Flash: navegar"; };
    }
    {
      key = "S";
      action.__raw = "function() require('flash').treesitter() end";
      mode = [ "n" "x" "o" ];
      options = { silent = true; desc = "Flash: treesitter"; };
    }

    # ─── Zen Mode ───
    {
      key = "<leader>z";
      action = "<cmd>ZenMode<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Zen mode"; };
    }

    # ─── Smart Splits ───
    {
      key = "<C-h>";
      action.__raw = "function() require('smart-splits').move_cursor_left() end";
      mode = [ "n" "t" ];
      options = { silent = true; desc = "Smart splits: mover cursor esquerda"; };
    }
    {
      key = "<C-j>";
      action.__raw = "function() require('smart-splits').move_cursor_down() end";
      mode = [ "n" "t" ];
      options = { silent = true; desc = "Smart splits: mover cursor baixo"; };
    }
    {
      key = "<C-k>";
      action.__raw = "function() require('smart-splits').move_cursor_up() end";
      mode = [ "n" "t" ];
      options = { silent = true; desc = "Smart splits: mover cursor cima"; };
    }
    {
      key = "<C-l>";
      action.__raw = "function() require('smart-splits').move_cursor_right() end";
      mode = [ "n" "t" ];
      options = { silent = true; desc = "Smart splits: mover cursor direita"; };
    }

    # ─── LSP ───
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

    # ─── Terminal ───
    {
      key = "<C-\\>";
      action = "<cmd>ToggleTerm direction=float<CR>";
      mode = [ "n" "t" ];
      options = { silent = true; desc = "Terminal flutuante"; };
    }

    # ─── DAP ───
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

    # ─── Java ───
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

{
  globals.mapleader = " ";
  globals.maplocalleader = " ";

  keymaps = [
    # General
    {
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Clear Search Highlight"; };
    }
    {
      key = "<C-s>";
      action = "<cmd>w<CR>";
      mode = [ "n" "i" ];
      options = { silent = true; desc = "Save File"; };
    }
    {
      key = "<leader>e";
      action = "<cmd>NeotreeToggle<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Toggle File Explorer"; };
    }
    {
      key = "<leader>d";
      action = "<cmd>Dashboard<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Dashboard"; };
    }
    {
      key = "<leader>?";
      action = "<cmd>lua require('which-key').show({ global = true })<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Browse All Keymaps"; };
    }
    {
      key = "<leader><leader>";
      action = "<cmd>lua require('which-key').show() <CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Show Leader Keymaps"; };
    }

    # New
    {
      key = "<leader>nf";
      action = "<cmd>lua _G.advanced_new_file()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "New File (Advanced)"; };
    }
    {
      key = "<leader>ns";
      action = "<cmd>lua _G.spring_boot_wizard()<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "New Spring Boot Project"; };
    }

    # File Explorer (Oil — buffer-level explorer)
    {
      key = "-";
      action = "<cmd>Oil<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Oil File Explorer"; };
    }

    # Files
    {
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Find Files"; };
    }
    {
      key = "<leader>fg";
      action = "<cmd>Telescope live_grep<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Find Text"; };
    }
    {
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "List Buffers"; };
    }
    {
      key = "<leader>fr";
      action = "<cmd>Telescope oldfiles<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "List Recent Files"; };
    }
    {
      key = "<leader>fp";
      action = "<cmd>Telescope projects<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "List Projects"; };
    }

    # Configuration
    {
      key = "<leader>cn";
      action = "<cmd>Neotree ~/.config/nvim<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Neovim Configuration"; };
    }
    {
      key = "<leader>cs";
      action = "<cmd>Neotree /etc/nixos<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open System Configuration"; };
    }

    # Navigation
    {
      key = "<leader>o";
      action = "<cmd>AerialToggle<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Toggle Symbol Outline"; };
    }
    {
      key = "<leader>z";
      action = "<cmd>ZenMode<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Toggle Zen Mode"; };
    }

    # Harpoon
    {
      key = "<leader>ha";
      action.__raw = "function() require('harpoon'):list():add() end";
      mode = [ "n" ];
      options = { silent = true; desc = "Add Current File"; };
    }
    {
      key = "<leader>ht";
      action = "<cmd>Telescope harpoon marks<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Harpoon Marks"; };
    }
    {
      key = "<leader>h1";
      action.__raw = "function() require('harpoon'):list():select(1) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Harpoon File 1"; };
    }
    {
      key = "<leader>h2";
      action.__raw = "function() require('harpoon'):list():select(2) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Harpoon File 2"; };
    }
    {
      key = "<leader>h3";
      action.__raw = "function() require('harpoon'):list():select(3) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Harpoon File 3"; };
    }
    {
      key = "<leader>h4";
      action.__raw = "function() require('harpoon'):list():select(4) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Harpoon File 4"; };
    }

    # Git
    {
      key = "<leader>gg";
      action = "<cmd>Neogit<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Git Status"; };
    }
    {
      key = "<leader>gc";
      action = "<cmd>Neogit commit<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Create Commit"; };
    }
    {
      key = "<leader>gb";
      action = "<cmd>Neogit branch<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Manage Branches"; };
    }
    {
      key = "<leader>gl";
      action = "<cmd>Neogit pull<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Pull Changes"; };
    }
    {
      key = "<leader>gp";
      action = "<cmd>Neogit push<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Push Changes"; };
    }
    {
      key = "<leader>gr";
      action = "<cmd>Neogit rebase<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Rebase Current Branch"; };
    }
    {
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Diff View"; };
    }
    {
      key = "<leader>gh";
      action = "<cmd>DiffviewFileHistory %<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Show File History"; };
    }
    {
      key = "<leader>gH";
      action = "<cmd>DiffviewFileHistory<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Show Repository History"; };
    }
    {
      key = "<leader>gB";
      action = "<cmd>Gitsigns blame_line<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Blame Current Line"; };
    }

    # Debug
    {
      key = "<leader>xb";
      action = "<cmd>DapToggleBreakpoint<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Toggle Breakpoint"; };
    }
    {
      key = "<leader>xc";
      action = "<cmd>DapContinue<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Start or Continue Debugging"; };
    }
    {
      key = "<leader>xn";
      action = "<cmd>DapStepOver<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Step Over"; };
    }
    {
      key = "<leader>xi";
      action = "<cmd>DapStepInto<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Step Into"; };
    }
    {
      key = "<leader>xo";
      action = "<cmd>DapStepOut<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Step Out"; };
    }
    {
      key = "<leader>xt";
      action = "<cmd>DapTerminate<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Terminate Debugging"; };
    }

    # Tests
    {
      key = "<leader>tt";
      action.__raw = "function() require('neotest').run.run(vim.fn.expand('%')) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Run Test File"; };
    }
    {
      key = "<leader>tr";
      action.__raw = "function() require('neotest').run.run() end";
      mode = [ "n" ];
      options = { silent = true; desc = "Run Nearest Test"; };
    }
    {
      key = "<leader>td";
      action.__raw = "function() require('neotest').run.run({ strategy = 'dap' }) end";
      mode = [ "n" ];
      options = { silent = true; desc = "Debug Nearest Test"; };
    }
    {
      key = "<leader>ts";
      action.__raw = "function() require('neotest').summary.toggle() end";
      mode = [ "n" ];
      options = { silent = true; desc = "Toggle Test Summary"; };
    }
    {
      key = "<leader>to";
      action.__raw = "function() require('neotest').output_panel.toggle() end";
      mode = [ "n" ];
      options = { silent = true; desc = "Toggle Test Output Panel"; };
    }
    {
      key = "<leader>tS";
      action.__raw = "function() require('neotest').run.stop() end";
      mode = [ "n" ];
      options = { silent = true; desc = "Stop Running Test"; };
    }

    # Flash
    {
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      mode = [ "n" "x" "o" ];
      options = { silent = true; desc = "Flash Jump"; };
    }
    {
      key = "S";
      action.__raw = "function() require('flash').treesitter() end";
      mode = [ "n" "x" "o" ];
      options = { silent = true; desc = "Flash Treesitter Selection"; };
    }

    # Smart Splits
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

    # Language
    {
      key = "<leader>ld";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      mode = [ "n" ];
      options = { desc = "Go to Definition"; };
    }
    {
      key = "<leader>lD";
      action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
      mode = [ "n" ];
      options = { desc = "Go to Declaration"; };
    }
    {
      key = "<leader>li";
      action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
      mode = [ "n" ];
      options = { desc = "Go to Implementation"; };
    }
    {
      key = "<leader>lr";
      action = "<cmd>lua vim.lsp.buf.references()<CR>";
      mode = [ "n" ];
      options = { desc = "List References"; };
    }
    {
      key = "<leader>lh";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      mode = [ "n" ];
      options = { desc = "Show Documentation"; };
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
      options = { desc = "Format Buffer"; };
    }
    {
      key = "<leader>ln";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      mode = [ "n" ];
      options = { desc = "Rename Symbol"; };
    }
    {
      key = "<leader>lx";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      mode = [ "n" ];
      options = { silent = true; desc = "Toggle Diagnostics"; };
    }

    # Mini files (quick project file navigation)
    {
      key = "<leader>mf";
      action.__raw = "function() require('mini.files').open() end";
      mode = [ "n" ];
      options = { silent = true; desc = "Open Mini Files"; };
    }
  ];
}

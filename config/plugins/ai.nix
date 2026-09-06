{ pkgs, ... }:
{
  plugins.copilot-lua = {
    enable = true;
    settings = {
      panel = {
        enabled = false;
        auto_refresh = false;
      };
      suggestion = {
        enabled = true;
        auto_trigger = false;
        hide_during_completion = true;
        debounce = 75;
        keymap = {
          accept = false;
          accept_word = false;
          accept_line = false;
          next = false;
          prev = false;
          dismiss = false;
        };
      };
      filetypes = {
        "*" = false;
        bash = true;
        c = true;
        cpp = true;
        css = true;
        go = true;
        html = true;
        java = true;
        javascript = true;
        json = true;
        lua = true;
        nix = true;
        php = true;
        python = true;
        rust = true;
        sh = true;
        sql = true;
        typescript = true;
        yaml = true;
      };
      copilot_node_command = "node";
      should_attach.__raw = ''function(bufnr, _)
        return vim.g.livara_copilot_enabled == true
          and vim.bo[bufnr].buflisted
          and vim.bo[bufnr].buftype == ""
      end'';
    };
  };

  plugins.copilot-chat = {
    enable = true;
    settings = {
      model = "gpt-4.1";
      temperature = 0.1;
      auto_follow_cursor = true;
      auto_insert_mode = false;
      clear_chat_on_new_prompt = false;
      highlight_selection = true;
      window = {
        layout = "vertical";
        width = 0.42;
        height = 0.82;
        border = "rounded";
        title = "Copilot Chat";
        zindex = 50;
      };
      prompts = {
        Explain = {
          prompt = "Explain the selected code and identify important design decisions.";
          description = "Explain selected code";
        };
        Review = {
          prompt = "Review the selected code for correctness, security, performance, and maintainability.";
          description = "Review selected code";
        };
        Fix = {
          prompt = "Find the root cause of the issue in the selected code and propose a minimal robust fix.";
          description = "Fix selected code";
        };
        Optimize = {
          prompt = "Improve the selected code without changing its external behavior, prioritizing correctness and performance.";
          description = "Optimize selected code";
        };
        Tests = {
          prompt = "Generate focused tests for the selected code and explain the important cases.";
          description = "Generate tests";
        };
      };
    };
  };

  extraPlugins = with pkgs.vimPlugins; [ plenary-nvim ];
  extraPackages = with pkgs; [ curl nodejs ];

  extraConfigLuaPost = ''
    vim.g.livara_copilot_enabled = false

    local function copilot_buffers()
      local client = require("copilot.client")
      if not client.id then return {} end
      return vim.lsp.get_buffers_by_client_id(client.id) or {}
    end

    local function set_current_suggestion(enabled)
      if enabled then
        vim.b.copilot_suggestion_auto_trigger = nil
        require("copilot.suggestion").toggle_auto_trigger()
      else
        vim.b.copilot_suggestion_auto_trigger = false
        require("copilot.suggestion").dismiss()
      end
    end

    _G.livara_copilot_enable = function()
      vim.g.livara_copilot_enabled = true
      local client = require("copilot.client")
      client.buf_attach(false)
      set_current_suggestion(true)
      vim.notify("Copilot inline suggestions enabled", vim.log.levels.INFO)
    end

    _G.livara_copilot_disable = function()
      vim.g.livara_copilot_enabled = false
      for _, bufnr in ipairs(copilot_buffers()) do
        require("copilot.client").buf_detach_if_attached(bufnr)
      end
      vim.b.copilot_suggestion_auto_trigger = false
      require("copilot.suggestion").dismiss()
      vim.notify("Copilot inline suggestions disabled", vim.log.levels.INFO)
    end

    _G.livara_copilot_toggle = function()
      if vim.g.livara_copilot_enabled then
        _G.livara_copilot_disable()
      else
        _G.livara_copilot_enable()
      end
    end

    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("LivaraCopilotState", { clear = true }),
      callback = function(args)
        if vim.g.livara_copilot_enabled then
          vim.b[args.buf].copilot_suggestion_auto_trigger = true
        end
      end,
    })
  '';
}

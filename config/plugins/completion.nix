{ ... }:
{
  plugins.luasnip.enable = true;
  plugins.cmp-nvim-lsp.enable = true;
  plugins.cmp-buffer.enable = true;
  plugins.cmp-path.enable = true;
  plugins.cmp-cmdline.enable = true;
  plugins.cmp_luasnip.enable = true;

  plugins.lspkind = {
    enable = true;
    cmp.enable = true;
  };

  plugins.cmp = {
    enable = true;
    autoEnableSources = true;
    settings = {
      snippet.expand.__raw = "function(args) require('luasnip').lsp_expand(args.body) end";
      completion.completeopt = "menu,menuone,noselect";
      completion.autocomplete = [
        { __raw = "require('cmp.types').cmp.TriggerEvent.InsertEnter"; }
        { __raw = "require('cmp.types').cmp.TriggerEvent.TextChanged"; }
      ];
      performance = {
        debounce = 60;
        throttle = 30;
        fetching_timeout = 300;
        max_view_entries = 50;
      };
      window = {
        completion = {
          border = "rounded";
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None";
          scrollbar = false;
        };
        documentation = {
          border = "rounded";
          winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpBorder,CursorLine:CmpDocSel,Search:None";
        };
      };
      sources = [
        { name = "nvim_lsp"; group_index = 1; priority = 1000; }
        { name = "luasnip"; group_index = 1; priority = 750; }
        {
          name = "path";
          group_index = 1;
          priority = 500;
          option = { keyword_length = 1; };
        }
        {
          name = "buffer";
          group_index = 1;
          priority = 250;
          option = {
            keyword_length = 1;
            keyword_pattern = "\\k\\+";
          };
        }
      ];
      mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-e>" = "cmp.mapping.abort()";
        "<C-n>" = "cmp.mapping.select_next_item()";
        "<C-p>" = "cmp.mapping.select_prev_item()";
        "<CR>" = "cmp.mapping.confirm({ select = false })";
      };
    };
    cmdline = {
      "/" = {
        mapping.__raw = "cmp.mapping.preset.cmdline()";
        sources = [ { name = "buffer"; } ];
      };
      ":" = {
        mapping.__raw = "cmp.mapping.preset.cmdline()";
        sources = [
          { name = "path"; }
          {
            name = "cmdline";
            option.ignore_cmds = [ "Man" "!" ];
          }
        ];
      };
    };
  };

  extraConfigLua = ''
    local function synchronize_cmp_lsp_sources(buf)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      vim.api.nvim_buf_call(buf, function()
        vim.api.nvim_exec_autocmds("InsertEnter", {
          group = "cmp_nvim_lsp",
          buf = buf,
          modeline = false,
        })
      end)
    end

    local cmp_lsp_refresh_group = vim.api.nvim_create_augroup("livara_cmp_lsp_refresh", { clear = true })
    vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
      group = cmp_lsp_refresh_group,
      callback = function(args)
        if args.event == "LspAttach" then
          local client = vim.lsp.get_client_by_id(args.data and args.data.client_id or -1)
          if not client or not client:supports_method("textDocument/completion") then
            return
          end
        end
        vim.schedule(function()
          synchronize_cmp_lsp_sources(args.buf)
        end)
      end,
    })

    local function feed_tab()
      local key = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
      vim.api.nvim_feedkeys(key, "n", false)
    end

    vim.keymap.set("i", "<Tab>", function()
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp and cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        return
      end
      local ok_snip, luasnip = pcall(require, "luasnip")
      if ok_snip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        return
      end
      feed_tab()
    end, { desc = "Expand snippet or continue indentation" })

    _G.livara_completion_report = function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      local rows = {}
      for _, client in ipairs(clients) do
        local provider = client.server_capabilities and client.server_capabilities.completionProvider
        local initialized = client.initialized and "yes" or "no"
        local supports_completion = client.supports_method and client:supports_method("textDocument/completion") or false
        rows[#rows + 1] = string.format(
          "%s: completionProvider=%s supports_completion=%s initialized=%s root=%s",
          client.name,
          provider and "yes" or "no",
          supports_completion and "yes" or "no",
          initialized,
          client.config and client.config.root_dir or "unknown"
        )
      end
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp then
        local source_names = {}
        for _, source in ipairs(cmp.get_config().sources or {}) do
          source_names[#source_names + 1] = source.name
          if source.name == "buffer" then
            local option = source.option or {}
            rows[#rows + 1] = string.format(
              "buffer source: keyword_length=%s pattern=%s",
              tostring(option.keyword_length or "default"),
              tostring(option.keyword_pattern or "default")
            )
          end
        end
        rows[#rows + 1] = "cmp sources: " .. table.concat(source_names, ", ")
        rows[#rows + 1] = "cmp visible: " .. (cmp.visible() and "yes" or "no")
        for _, source in ipairs(cmp.get_registered_sources()) do
          if source.name == "nvim_lsp" then
            local ok_available, available = pcall(function()
              return source:is_available()
            end)
            rows[#rows + 1] = string.format(
              "nvim_lsp registered=%s available=%s debug=%s",
              "yes",
              ok_available and (available and "yes" or "no") or "error",
              source:get_debug_name()
            )
          end
        end
      else
        rows[#rows + 1] = "cmp unavailable"
      end
      if #rows == 0 then
        rows[1] = "No LSP client is attached to the current buffer"
      end
      vim.notify(table.concat(rows, "\n"), vim.log.levels.INFO, { title = "Livara completion report" })
    end
    vim.api.nvim_create_user_command("LivaraCompletionReport", _G.livara_completion_report, {})
    vim.api.nvim_create_user_command("LivaraCmpStatus", function()
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp then
        cmp.status()
      else
        vim.notify("cmp unavailable", vim.log.levels.ERROR, { title = "Livara cmp status" })
      end
    end, {})
  '';
}

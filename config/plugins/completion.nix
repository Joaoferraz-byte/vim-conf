{ ... }:
{
  plugins.luasnip.enable = true;
  plugins.cmp-nvim-lsp.enable = true;

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
      completion.autocomplete = [ "InsertEnter" "TextChanged" ];
      performance = {
        debounce = 100;
        throttle = 50;
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
        # Keep completion selection explicit: Shift+Arrow changes the highlighted
        # item, while Enter confirms only an item the user selected.
        "<S-Right>" = ''cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end, { "i", "s" })'';
        "<S-Left>" = ''cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end, { "i", "s" })'';
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
    local function refresh_jdtls_cmp_source()
      local ok_cmp, cmp = pcall(require, "cmp")
      local ok_lsp_cmp, lsp_cmp = pcall(require, "cmp_nvim_lsp")
      if not ok_cmp or not ok_lsp_cmp or type(lsp_cmp.client_source_map) ~= "table" then
        return
      end
      for client_id, source_id in pairs(lsp_cmp.client_source_map) do
        local client = vim.lsp.get_client_by_id(client_id)
        if not client or client.name == "jdtls" then
          cmp.unregister_source(source_id)
          lsp_cmp.client_source_map[client_id] = nil
        end
      end
      lsp_cmp._on_insert_enter()
    end

    local cmp_lsp_refresh_group = vim.api.nvim_create_augroup("livara_cmp_lsp_refresh", { clear = true })
    vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter" }, {
      group = cmp_lsp_refresh_group,
      callback = function(args)
        if args.event == "BufEnter" or vim.lsp.get_client_by_id(args.data and args.data.client_id or -1) then
          vim.schedule(refresh_jdtls_cmp_source)
        end
      end,
    })

    local function feed_tab()
      local key = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
      vim.api.nvim_feedkeys(key, "n", false)
    end

    local function expand_html_bang()
      local filetype = vim.bo.filetype
      if filetype ~= "php" and filetype ~= "html" then
        return false
      end
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_get_current_line()
      local before_cursor = line:sub(1, col)
      if not before_cursor:match("^%s*!$") then
        return false
      end

      local indent = before_cursor:match("^%s*") or ""
      local template = {
        indent .. "<!DOCTYPE html>",
        indent .. "<html lang=\"en\">",
        indent .. "<head>",
        indent .. "  <meta charset=\"UTF-8\">",
        indent .. "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
        indent .. "  <title>Document</title>",
        indent .. "</head>",
        indent .. "<body>",
        indent .. "</body>",
        indent .. "</html>",
      }
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, template)
      vim.api.nvim_win_set_cursor(0, { row + 7, #indent + 6 })
      return true
    end

    vim.keymap.set("i", "<Tab>", function()
      -- Keep the most useful VS Code behavior: a standalone `!` expands
      -- immediately, while any other visible Emmet/LSP item is accepted.
      if expand_html_bang() then
        return
      end
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp and cmp.visible() then
        if cmp.get_selected_entry() then
          cmp.confirm({ select = false })
        else
          feed_tab()
        end
        return
      end
      local ok_snip, luasnip = pcall(require, "luasnip")
      if ok_snip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        return
      end
      feed_tab()
    end, { desc = "Expand Emmet, snippets, or continue indentation" })

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
      for _, client in ipairs(clients) do
        if client.name == "jdtls" and client.supports_method and client:supports_method("textDocument/completion") then
          local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
          client:request("textDocument/completion", params, function(err, result)
            local items = result and (result.items or result) or {}
            local labels = {}
            for index = 1, math.min(#items, 8) do
              labels[#labels + 1] = items[index].label or "<unlabeled>"
            end
            vim.schedule(function()
              local status = err and ("error=" .. vim.inspect(err)) or ("items=" .. #items)
              local sample = #labels > 0 and (" labels=" .. table.concat(labels, ", ")) or ""
              vim.notify(status .. sample, err and vim.log.levels.ERROR or vim.log.levels.INFO, { title = "JDTLS completion probe" })
            end)
          end, 0)
        end
      end
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

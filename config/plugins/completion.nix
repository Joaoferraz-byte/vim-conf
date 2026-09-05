{ ... }:
{
  plugins.luasnip.enable = true;

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
      completion.autocomplete = [ "require('cmp.types').cmp.TriggerEvent.TextChanged" ];
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
        { name = "path"; group_index = 1; priority = 500; keyword_length = 1; }
        { name = "buffer"; group_index = 1; priority = 250; keyword_length = 1; }
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
        rows[#rows + 1] = string.format("%s: completion=%s root=%s", client.name, provider and "yes" or "no", client.config and client.config.root_dir or "unknown")
      end
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp then
        local source_names = {}
        for _, source in ipairs(cmp.get_config().sources or {}) do
          source_names[#source_names + 1] = source.name
        end
        rows[#rows + 1] = "cmp sources: " .. table.concat(source_names, ", ")
        rows[#rows + 1] = "cmp visible: " .. (cmp.visible() and "yes" or "no")
      else
        rows[#rows + 1] = "cmp unavailable"
      end
      if #rows == 0 then
        rows[1] = "No LSP client is attached to the current buffer"
      end
      vim.notify(table.concat(rows, "\n"), vim.log.levels.INFO, { title = "Livara completion report" })
    end
    vim.api.nvim_create_user_command("LivaraCompletionReport", _G.livara_completion_report, {})
  '';
}

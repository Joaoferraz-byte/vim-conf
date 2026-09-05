{ lib, ... }:
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
      completion.autocomplete = [ "TextChanged" "InsertCharPre" ];
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
      formatting.format = lib.mkForce {
        __raw = ''function(entry, item)
          item = require("lspkind").cmp_format({ mode = "symbol_text" })(entry, item)
          local total = 0
          local ok, cmp = pcall(require, "cmp")
          if ok and cmp.get_entries then
            total = #cmp.get_entries()
          end
          local source = entry.source and entry.source.name or "?"
          item.menu = string.format("[%s %d]", source, total)
          return item
        end'';
      };
      sources = [
        { name = "nvim_lsp"; group_index = 1; }
        { name = "luasnip"; group_index = 1; }
        { name = "path"; group_index = 2; }
        { name = "buffer"; group_index = 2; }
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
  '';
}

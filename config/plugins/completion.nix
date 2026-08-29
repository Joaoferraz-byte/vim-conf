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
        { name = "nvim_lsp"; }
        { name = "luasnip"; }
        { name = "path"; }
        { name = "buffer"; }
      ];
      mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-e>" = "cmp.mapping.abort()";
        "<C-n>" = "cmp.mapping.select_next_item()";
        "<C-p>" = "cmp.mapping.select_prev_item()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
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
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp and cmp.visible() then
        cmp.select_next_item()
        return
      end
      local ok_snip, luasnip = pcall(require, "luasnip")
      if ok_snip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        return
      end
      if expand_html_bang() then
        return
      end
      feed_tab()
    end, { desc = "Expand HTML boilerplate or continue completion" })
  '';
}

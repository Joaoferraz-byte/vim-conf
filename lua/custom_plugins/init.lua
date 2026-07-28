-- O nvim-treesitter v1.0.0 mudou a forma de configuração ou o nome dos módulos.
-- Tentamos carregar o módulo antigo, se falhar, tentamos o novo ou apenas ignoramos.
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    -- Tenta o novo padrão se existir (algumas versões usam nvim-treesitter.config)
    status_ok, configs = pcall(require, "nvim-treesitter.config")
end

if status_ok and configs.setup then
  configs.setup({
    highlight = { enable = true },
    indent = { enable = true },
    -- No NixOS, os parsers são instalados via Nix (nix-conf)
    ensure_installed = {}, 
    sync_install = false,
    auto_install = false,
  })
end

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  })
})

require("nvim-tree").setup({
  view = { width = 30 },
  git = { enable = true },
  renderer = {
    icons = {
      show = { git = true, folder = true, file = true },
      glyphs = {
        default = "",
        symlink = "",
        folder = {
          arrow_open = "",
          arrow_closed = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "",
          staged = "✓",
          untracked = "",
          renamed = "➜",
          unmerged = "",
          deleted = "",
          ignored = "◌",
        },
      },
    },
  },
})

require("lualine").setup({
  options = {
    theme = "github-dark",
    globalstatus = true,
  },
  sections = {
    lualine_a = {"mode"},
    lualine_b = {"branch", "diff", "diagnostics"},
    lualine_c = {"filename"},
    lualine_x = {"encoding", "filetype"},
    lualine_y = {"progress"},
    lualine_z = {"location"}
  },
})

require("which-key").setup()
require("gitsigns").setup()
require("bufferline").setup()

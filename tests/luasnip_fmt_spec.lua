local ok, luasnip = pcall(require, "luasnip")
assert(ok, "LuaSnip must be available in the test runtime")

local fmt = require("luasnip.extras.fmt").fmt
local insert = luasnip.insert_node

local ok_unescaped, unescaped_error = pcall(function()
  fmt("public static void main(String[] args) {\n\t{}\n}", { insert(0) })
end)
assert(not ok_unescaped, "unescaped Java braces must be rejected by LuaSnip fmt")
assert(unescaped_error:find("Found unescaped", 1, true), "unexpected LuaSnip error: " .. tostring(unescaped_error))

local snippet = luasnip.snippet("psvm", fmt("public static void main(String[] args) {{\n\t{}\n}}", { insert(0) }))
luasnip.snip_expand(snippet)

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
assert(lines[1] == "public static void main(String[] args) {", "opening Java brace was not rendered literally")
assert(lines[2] == "\t", "the insert node must remain in the method body")
assert(lines[3] == "}", "closing Java brace was not rendered literally")
print("LuaSnip Java formatter regression passed")
vim.cmd("qa!")

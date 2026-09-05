vim = { uv = {}, loop = {} }
local creator = dofile("lua/project_creator.lua")
assert(#creator._specs >= 8)
local ids = {}
for _, spec in ipairs(creator._specs) do
  ids[spec.id] = true
  assert(spec.name and spec.language and spec.icon and spec.tabler)
  local tree = creator._tree_lines(spec, { name = "demo", package = "com.example.demo" })
  assert(tree:find("demo", 1, true))
  assert(tree:find("\n", 1, true))
end
assert(ids["java-maven"])
assert(ids["java-gradle"])
assert(ids["java-spring"])
assert(ids["python-uv"])
assert(ids["cpp-cmake"])
assert(not ids.html)
assert(not ids.css)
assert(not ids.markdown)
assert(creator._valid_package("com.example.demo"))
assert(not creator._valid_package("com..example"))
assert(creator._join_path("/tmp/", "/demo") == "/tmp/demo")
print("project creator contract passed")

local creator = dofile("lua/project_creator.lua")

local languages = creator._languages()
local language_ids = {}
for _, language in ipairs(languages) do
  language_ids[language.id] = true
  assert(language.name and language.icon)
  local families = creator._families(language.id)
  assert(#families > 0)
  for _, family in ipairs(families) do
    local structures = creator._structures(language.id, family.id)
    assert(#structures > 0)
    assert(family.icon and family.icon ~= language.icon)
    for _, spec in ipairs(structures) do
      assert(spec.name and spec.language and spec.icon)
      assert(spec.display_icon and spec.display_icon ~= language.icon)
      local tree = creator._tree_lines(spec, { name = "demo", package = "com.example.demo" })
      assert(tree:find("demo", 1, true))
      assert(tree:find("", 1, true))
      assert(tree:find("src/", 1, true) or tree:find("main.go", 1, true) or tree:find("main.py", 1, true) or tree:find("manage.py", 1, true) or tree:find("composer.json", 1, true) or tree:find("package.json", 1, true))
      if spec.language == "Java" and spec.family == "Plain application" and spec.name == "Maven" then
        assert(tree:find("com/", 1, true))
        assert(tree:find("example/", 1, true))
        assert(tree:find("demo/", 1, true))
        assert(tree:find("App.java", 1, true))
        assert(tree:find("", 1, true))
      end
      if spec.language == "Java" and spec.family == "Plain application" and spec.name == "Gradle Groovy" then
        assert(spec.dsl == "groovy")
        assert(tree:find("settings.gradle", 1, true))
        assert(tree:find("build.gradle", 1, true))
        assert(tree:find("main/java/com/example/demo/", 1, true))
        assert(not tree:find("main/\n", 1, true))
      end
      assert(not spec.name:find("tabler:", 1, true))
    end
  end
end

assert(language_ids.Java)
assert(language_ids.JavaScript)
assert(language_ids.TypeScript)
assert(language_ids.Go)
assert(language_ids.PHP)
assert(language_ids.Python)
assert(language_ids.C)
assert(language_ids["C++"])
assert(language_ids.Rust)

local function has_family(language, family)
  for _, entry in ipairs(creator._families(language)) do
    if entry.id == family then return true end
  end
  return false
end

assert(has_family("Java", "Spring Boot"))
assert(has_family("Java", "JavaFX desktop"))
assert(has_family("JavaScript", "React"))
assert(has_family("TypeScript", "Angular"))
assert(has_family("TypeScript", "NestJS API"))
assert(has_family("Go", "HTTP/API service"))
assert(has_family("PHP", "Laravel web"))
assert(has_family("Python", "FastAPI API"))
assert(not language_ids.Zig)
assert(not language_ids.HTML)
assert(not language_ids.CSS)
assert(not language_ids.Markdown)
assert(creator._valid_package("com.example.demo"))
assert(not creator._valid_package("com..example"))
assert(creator._join_path("/tmp/", "/demo") == "/tmp/demo")
local title = "Java · Plain application"
local title_box = creator._title_box(title)
local expected_width = vim.fn.strdisplaywidth(title) + 2
assert(vim.fn.strdisplaywidth(title_box[1]) == expected_width)
assert(vim.fn.strdisplaywidth(title_box[2]) == expected_width)
assert(vim.fn.strdisplaywidth(title_box[3]) == expected_width)
assert(title_box[1]:sub(1, 3) == "╭")
assert(title_box[1]:sub(-3) == "╮")
assert(title_box[3]:sub(1, 3) == "╰")
assert(title_box[3]:sub(-3) == "╯")
print("project creator hierarchy contract passed")

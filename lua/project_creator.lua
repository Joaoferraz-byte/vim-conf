local M = {}
local unpack_fn = table.unpack or unpack

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO)
end

local function join_path(...)
  local parts = { ... }
  return table.concat(parts, "/"):gsub("/+", "/")
end

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function valid_identifier(value)
  return value ~= "" and value:match("^[%a_][%w_-]*$") ~= nil
end

local function valid_package(value)
  if value == "" or value:match("^%.") or value:match("%.$") or value:match("%.%.") then
    return false
  end
  for segment in value:gmatch("[^%.]+") do
    if not segment:match("^[%a_][%w_]*$") then
      return false
    end
  end
  return value:match("^[%a_][%w_%.]*$") ~= nil
end

local function package_path(package)
  return package:gsub("%.", "/")
end

local function project_name(value)
  local name = vim.fn.fnamemodify(value, ":t")
  return name:gsub("[^%w_-]", "-"):gsub("^-+", ""):gsub("-+$", "")
end

local function default_project_directory()
  return vim.fn.expand("~/Projects")
end

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function write_file(path, content)
  local parent = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(parent) == 0 then
    vim.fn.mkdir(parent, "p")
  end
  local handle = io.open(path, "w")
  if not handle then
    return false
  end
  handle:write(content)
  handle:close()
  return true
end

local function run(command, options, callback)
  if vim.system then
    return vim.system(command, options or {}, function(value)
      vim.schedule(function()
        callback(value)
      end)
    end)
  end
  local stdout = {}
  local stderr = {}
  local job = vim.fn.jobstart(command, {
    cwd = options and options.cwd or nil,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then vim.list_extend(stdout, data) end
    end,
    on_stderr = function(_, data)
      if data then vim.list_extend(stderr, data) end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        callback({ code = code, stdout = table.concat(stdout, "\n"), stderr = table.concat(stderr, "\n") })
      end)
    end,
  })
  if job <= 0 then
    callback({ code = 127, stdout = "", stderr = "Unable to start command" })
  end
  return job
end

local function finish(result, label, path)
  if result.code ~= 0 then
    local detail = trim(result.stderr or result.stdout or "")
    notify(label .. " failed" .. (detail ~= "" and ": " .. detail or ""), vim.log.levels.ERROR)
    return false
  end
  notify(label .. " created at " .. path)
  vim.cmd("cd " .. vim.fn.fnameescape(path))
  vim.cmd("Oil " .. vim.fn.fnameescape(path))
  return true
end

local function create_files(path, files, callback)
  for relative, content in pairs(files) do
    if not write_file(join_path(path, relative), content) then
      notify("Unable to write the generated project", vim.log.levels.ERROR)
      callback({ code = 1, stdout = "", stderr = "Unable to write generated project file" })
      return
    end
  end
  callback({ code = 0, stdout = "", stderr = "" })
end

local function ensure_empty_directory(path, callback)
  if vim.fn.isdirectory(path) == 1 then
    local entries = vim.fn.readdir(path)
    if #entries > 0 then
      vim.ui.select({ "Use existing directory", "Cancel" }, {
        prompt = "Destination is not empty: " .. path,
      }, function(choice)
        callback(choice == "Use existing directory")
      end)
      return
    end
  end
  callback(true)
end

local function path_icon(path, is_directory)
  if is_directory then return "" end
  local icons = {
    [".java"] = "",
    [".kt"] = "",
    [".kts"] = "",
    [".py"] = "",
    [".js"] = "",
    [".jsx"] = "",
    [".ts"] = "",
    [".tsx"] = "",
    [".go"] = "󰟓",
    [".php"] = "",
    [".rs"] = "",
    [".c"] = "",
    [".cpp"] = "",
    [".h"] = "",
    [".hpp"] = "",
    [".json"] = "",
    [".xml"] = "󰗀",
    [".toml"] = "󰰮",
    [".css"] = "",
    [".html"] = "",
    [".md"] = "",
    ["CMakeLists.txt"] = "",
  }
  if icons[path] then return icons[path] end
  for extension, icon in pairs(icons) do
    if extension:sub(1, 1) == "." and path:sub(-#extension) == extension then return icon end
  end
  return "󰈔"
end

local function tree_lines(spec, values)
  values = values or {}
  local name = values.name or "project-name"
  local package = values.package or "com.example.app"
  local package_dir = package_path(package)
  local root = { label = name .. "/", directory = true, children = {} }
  local stack = { [0] = root }
  local function child_node(parent, segment, directory)
    local label = segment .. (directory and "/" or "")
    for _, child in ipairs(parent.children) do
      if child.label == label then return child end
    end
    local node = { label = label, directory = directory, children = {} }
    parent.children[#parent.children + 1] = node
    return node
  end
  for _, entry in ipairs(spec.tree or {}) do
    local raw = entry:gsub("{name}", name):gsub("{package}", package):gsub("{package_dir}", package_dir)
    local spaces, path = raw:match("^(%s*)(.*)$")
    local level = math.floor(#spaces / 2)
    local segments = {}
    for segment in path:gmatch("[^/]+") do segments[#segments + 1] = segment end
    local parent = stack[level] or root
    for index, segment in ipairs(segments) do
      local directory = index < #segments or path:sub(-1) == "/"
      parent = child_node(parent, segment, directory)
    end
    stack[level + 1] = parent
    for index = level + 2, 32 do stack[index] = nil end
  end
  local function compact(node)
    for _, child in ipairs(node.children) do compact(child) end
    while node.directory and #node.children == 1 and node.children[1].directory do
      local child = node.children[1]
      node.label = node.label .. child.label
      node.children = child.children
    end
  end
  compact(root)
  local lines = { path_icon(root.label, true) .. " " .. root.label }
  local function render(node, prefix, last)
    local branch = last and "└── " or "├── "
    lines[#lines + 1] = prefix .. branch .. path_icon(node.label:gsub("/$", ""), node.directory) .. " " .. node.label
    local child_prefix = prefix .. (last and "    " or "│   ")
    for index, child in ipairs(node.children) do
      render(child, child_prefix, index == #node.children)
    end
  end
  for index, child in ipairs(root.children) do
    render(child, "", index == #root.children)
  end
  return table.concat(lines, "\n")
end

local function title_box(title)
  local width = vim.fn.strdisplaywidth(title)
  local horizontal = string.rep("─", width)
  return {
    "╭" .. horizontal .. "╮",
    "│" .. title .. "│",
    "╰" .. horizontal .. "╯",
  }
end

local function preview(spec, values)
  local title = spec.language .. " · " .. spec.family
  local header = title_box(title)
  header[#header + 1] = "  " .. spec.name
  header[#header + 1] = ""
  return { text = table.concat(header, "\n") .. "\n" .. tree_lines(spec, values), ft = "text", loc = false }
end

local function list_preview(title, entries)
  local title_width = vim.fn.strdisplaywidth(title)
  local lines = {
    "  " .. title,
    "  " .. string.rep("─", title_width),
    "",
  }
  for index, entry in ipairs(entries) do
    local icon = type(entry) == "table" and (entry.display_icon or entry.icon) or "•"
    local label = type(entry) == "table" and entry.name or entry
    lines[#lines + 1] = string.format("%2d  %s  %s", index, icon, label)
  end
  return { text = table.concat(lines, "\n"), ft = "text", loc = false }
end

local function family_icon(family)
  local icons = {
    ["Plain application"] = "󰆍",
    ["Spring Boot"] = "󰏗",
    ["JavaFX desktop"] = "󰍹",
    ["Vanilla web"] = "󰖟",
    ["React"] = "",
    ["Vue"] = "󰡄",
    ["Svelte"] = "",
    ["Next.js"] = "",
    ["Angular"] = "",
    ["NestJS API"] = "󰓫",
    ["FastAPI API"] = "󰓫",
    ["Django web"] = "󰖟",
    ["HTTP/API service"] = "󰓫",
    ["Laravel web"] = "󰖟",
    ["C application"] = "󰆍",
    ["C++ application"] = "󰆍",
  }
  return icons[family] or "󰘧"
end

local function structure_icon(spec)
  local icons = {
    ["Maven"] = "󰏗",
    ["Gradle Kotlin"] = "󰏗",
    ["Gradle Groovy"] = "󰏗",
    ["Vite vanilla"] = "󰜈",
    ["React via Vite"] = "",
    ["Vue via Vite"] = "󰡄",
    ["Svelte via Vite"] = "",
    ["Next.js"] = "",
    ["Angular CLI"] = "",
    ["NestJS"] = "󰓫",
    ["uv application"] = "󰆍",
    ["FastAPI via uv"] = "󰓫",
    ["Django via uv"] = "󰖟",
    ["Go module"] = "󰆍",
    ["Gin API"] = "󰓫",
    ["Chi API"] = "󰓫",
    ["Composer package"] = "󰏗",
    ["Laravel"] = "󰖟",
    ["CMake application"] = "󰆍",
    ["Cargo binary"] = "󰏗",
  }
  return icons[spec.name] or "󰘧"
end

local function pick(title, entries, preview_fn, callback)
  local items = {}
  for _, entry in ipairs(entries) do
    items[#items + 1] = {
      text = (entry.display_icon or entry.icon) .. "  " .. entry.name,
      entry = entry,
      preview = preview_fn(entry),
    }
  end
  Snacks.picker.pick({
    title = title,
    items = items,
    format = "text",
    preview = "preview",
    layout = { preset = "default", width = 0.94, height = 0.90, backdrop = false },
    win = { preview = { border = "rounded" } },
    confirm = function(picker, item)
      picker:close()
      if item and item.entry then callback(item.entry) end
    end,
  })
end

local function java_values(callback)
  vim.ui.select({ "17", "21", "25" }, { prompt = "Java version:" }, function(version)
    if not version then return end
    vim.ui.input({ prompt = "Group ID: ", default = "com.example" }, function(group)
      group = trim(group)
      if not valid_package(group) then
        notify("Invalid Java group ID", vim.log.levels.ERROR)
        return
      end
      callback({ java_version = version, package = group })
    end)
  end)
end

local function spring_metadata(callback)
  if not executable("curl") then
    notify("Spring Initializr requires curl", vim.log.levels.ERROR)
    return
  end
  run({ "curl", "-fsSL", "--max-time", "20", "https://start.spring.io/metadata/client" }, { text = true }, function(result)
    if result.code ~= 0 then
      notify("Spring Initializr metadata request failed", vim.log.levels.ERROR)
      return
    end
    local ok, metadata = pcall(vim.json.decode, result.stdout)
    if not ok or type(metadata) ~= "table" then
      notify("Spring Initializr metadata is invalid", vim.log.levels.ERROR)
      return
    end
    callback(metadata)
  end)
end

local function metadata_values(metadata, key, fallback)
  local node = metadata[key]
  if type(node) ~= "table" or type(node.values) ~= "table" then return fallback end
  local values = {}
  for _, item in ipairs(node.values) do
    if type(item) == "table" and item.id then
      values[#values + 1] = { id = item.id, label = item.name or item.id }
    elseif type(item) == "string" then
      values[#values + 1] = { id = item, label = item }
    end
  end
  return #values > 0 and values or fallback
end

local function select_metadata(metadata, key, prompt, fallback, callback)
  local values = metadata_values(metadata, key, fallback)
  local labels = {}
  for _, item in ipairs(values) do labels[#labels + 1] = item.label end
  vim.ui.select(labels, { prompt = prompt }, function(label, index)
    if label and index then callback(values[index].id) end
  end)
end

local function create_spring(spec, values, path)
  if not executable("curl") or not executable("tar") then
    notify("Spring Initializr requires curl and tar", vim.log.levels.ERROR)
    return
  end
  spring_metadata(function(metadata)
    select_metadata(metadata, "packaging", "Packaging:", { { id = "jar", label = "Jar" }, { id = "war", label = "War" } }, function(packaging)
      select_metadata(metadata, "bootVersion", "Spring Boot version:", {}, function(boot_version)
        local tmp = vim.fn.tempname() .. ".tgz"
        local args = {
          "curl", "-fsSL", "--max-time", "60", "-o", tmp, "https://start.spring.io/starter.tgz",
          "-d", "type=" .. spec.initializr_type, "-d", "language=java",
          "-d", "javaVersion=" .. values.java_version, "-d", "packaging=" .. packaging,
          "-d", "bootVersion=" .. boot_version, "-d", "groupId=" .. values.package,
          "-d", "artifactId=" .. values.name, "-d", "name=" .. values.name,
          "-d", "packageName=" .. values.package, "-d", "baseDir=" .. values.name,
        }
        run(args, { text = true }, function(result)
          if result.code ~= 0 then
            notify("Spring Initializr generation failed", vim.log.levels.ERROR)
            return
          end
          run({ "tar", "-xzf", tmp, "-C", path }, { text = true }, function(extract_result)
            os.remove(tmp)
            finish(extract_result, spec.name, join_path(path, values.name))
          end)
        end)
      end)
    end)
  end)
end

local function create_gradle(spec, values, path)
  if not executable("gradle") then
    notify("Gradle is not available", vim.log.levels.ERROR)
    return
  end
  local destination = join_path(path, values.name)
  vim.fn.mkdir(destination, "p")
  run({ "gradle", "init", "--type", spec.gradle_type, "--dsl", spec.dsl, "--test-framework", "junit-jupiter", "--package", values.package, "--project-name", values.name, "--java-version", values.java_version, "--no-split-project" }, { cwd = destination, text = true }, function(result)
    finish(result, spec.name, destination)
  end)
end

local function create_maven(spec, values, path)
  if not executable("mvn") then
    notify("Maven is not available", vim.log.levels.ERROR)
    return
  end
  run({ "mvn", "-B", "org.apache.maven.plugins:maven-archetype-plugin:3.4.1:generate", "-DarchetypeGroupId=org.apache.maven.archetypes", "-DarchetypeArtifactId=maven-archetype-quickstart", "-DarchetypeVersion=1.5", "-DgroupId=" .. values.package, "-DartifactId=" .. values.name, "-Dversion=1.0-SNAPSHOT", "-Dmaven.compiler.release=" .. values.java_version, "-DinteractiveMode=false" }, { cwd = path, text = true }, function(result)
    finish(result, spec.name, join_path(path, values.name))
  end)
end

local function create_javafx(spec, values, path)
  local destination = join_path(path, values.name)
  if spec.build_system == "maven" then
    if not executable("mvn") then notify("Maven is not available", vim.log.levels.ERROR) return end
    local files = {
      ["pom.xml"] = "<project xmlns=\"http://maven.apache.org/POM/4.0.0\"><modelVersion>4.0.0</modelVersion><groupId>" .. values.package .. "</groupId><artifactId>" .. values.name .. "</artifactId><version>1.0-SNAPSHOT</version><properties><maven.compiler.release>" .. values.java_version .. "</maven.compiler.release><javafx.version>21</javafx.version></properties><dependencies><dependency><groupId>org.openjfx</groupId><artifactId>javafx-controls</artifactId><version>${javafx.version}</version></dependency></dependencies><build><plugins><plugin><groupId>org.openjfx</groupId><artifactId>javafx-maven-plugin</artifactId><version>0.0.8</version><configuration><mainClass>" .. values.package .. ".App</mainClass></configuration></plugin></plugins></build></project>\n",
      ["src/main/java/" .. package_path(values.package) .. "/App.java"] = "package " .. values.package .. ";\n\nimport javafx.application.Application;\nimport javafx.scene.Scene;\nimport javafx.scene.control.Label;\nimport javafx.stage.Stage;\n\npublic class App extends Application {\n  public void start(Stage stage) { stage.setScene(new Scene(new Label(\"Hello JavaFX\"), 640, 400)); stage.show(); }\n  public static void main(String[] args) { launch(); }\n}\n",
    }
    create_files(destination, files, function(result) finish(result, spec.name, destination) end)
    return
  end
  if not executable("gradle") then notify("Gradle is not available", vim.log.levels.ERROR) return end
  vim.fn.mkdir(destination, "p")
  run({ "gradle", "init", "--type", "java-application", "--dsl", spec.dsl, "--test-framework", "junit-jupiter", "--package", values.package, "--project-name", values.name, "--java-version", values.java_version, "--no-split-project" }, { cwd = destination, text = true }, function(result) finish(result, spec.name, destination) end)
end

local function create_uv(spec, values, path)
  if not executable("uv") then notify("uv is not available", vim.log.levels.ERROR) return end
  local destination = join_path(path, values.name)
  run({ "uv", "init", "--app", "--python", values.python_version, "--name", values.name, destination }, { text = true }, function(result) finish(result, spec.name, destination) end)
end

local function create_fastapi(spec, values, path)
  if not executable("uv") then notify("uv is not available", vim.log.levels.ERROR) return end
  local destination = join_path(path, values.name)
  vim.fn.mkdir(destination, "p")
  create_files(destination, {
    ["app/__init__.py"] = "",
    ["app/main.py"] = "from fastapi import FastAPI\n\napp = FastAPI()\n\n@app.get(\"/health\")\ndef health():\n    return {\"status\": \"ok\"}\n",
    ["app/routers/__init__.py"] = "",
    ["app/routers/health.py"] = "",
  }, function(result)
    run({ "uv", "init", "--no-package" }, { cwd = destination, text = true }, function(init_result)
      if init_result.code ~= 0 then finish(init_result, spec.name, destination) return end
      run({ "uv", "add", "fastapi", "--extra", "standard" }, { cwd = destination, text = true }, function(add_result) finish(add_result, spec.name, destination) end)
    end)
  end)
end

local function create_django(spec, values, path)
  if not executable("uv") then notify("uv is not available", vim.log.levels.ERROR) return end
  local destination = join_path(path, values.name)
  vim.fn.mkdir(destination, "p")
  run({ "uv", "init", "--name", values.name }, { cwd = destination, text = true }, function(init_result)
    if init_result.code ~= 0 then finish(init_result, spec.name, destination) return end
    run({ "uv", "add", "django" }, { cwd = destination, text = true }, function(add_result)
      if add_result.code ~= 0 then finish(add_result, spec.name, destination) return end
      run({ "uv", "run", "django-admin", "startproject", "config", "." }, { cwd = destination, text = true }, function(result) finish(result, spec.name, destination) end)
    end)
  end)
end

local function install_node_dependencies(manager, destination, spec, callback)
  local command = manager == "pnpm" and { "pnpm", "install" } or { "npm", "install" }
  run(command, { cwd = destination, text = true }, function(result)
    if result.code ~= 0 then
      notify(spec.name .. " was generated but dependency installation failed", vim.log.levels.ERROR)
      return
    end
    callback(result)
  end)
end

local function create_vite(spec, values, path)
  local manager = executable("pnpm") and "pnpm" or executable("npm") and "npm" or nil
  if not manager then notify("pnpm or npm is not available", vim.log.levels.ERROR) return end
  local command = manager == "pnpm" and { "pnpm", "create", "vite", values.name, "--template", spec.template } or { "npm", "create", "vite@latest", values.name, "--", "--template", spec.template }
  local destination = join_path(path, values.name)
  run(command, { cwd = path, text = true }, function(result)
    if result.code ~= 0 then finish(result, spec.name, destination) return end
    install_node_dependencies(manager, destination, spec, function(install_result) finish(install_result, spec.name, destination) end)
  end)
end

local function create_next(spec, values, path)
  local manager = executable("pnpm") and "pnpm" or executable("npm") and "npm" or nil
  if not manager then notify("pnpm or npm is not available", vim.log.levels.ERROR) return end
  local command = manager == "pnpm" and { "pnpm", "create", "next-app@latest", values.name, spec.typescript and "--ts" or "--js", "--eslint", "--app", "--src-dir", "--use-pnpm", "--yes" } or { "npx", "create-next-app@latest", values.name, spec.typescript and "--ts" or "--js", "--eslint", "--app", "--src-dir", "--use-npm", "--yes" }
  run(command, { cwd = path, text = true }, function(result) finish(result, spec.name, join_path(path, values.name)) end)
end

local function create_angular(spec, values, path)
  if not executable("npx") then notify("npx is not available", vim.log.levels.ERROR) return end
  run({ "npx", "-y", "@angular/cli", "new", values.name, "--routing", "--style", "css", "--package-manager", executable("pnpm") and "pnpm" or "npm", "--skip-git" }, { cwd = path, text = true }, function(result) finish(result, spec.name, join_path(path, values.name)) end)
end

local function create_nest(spec, values, path)
  if not executable("npx") then notify("npx is not available", vim.log.levels.ERROR) return end
  run({ "npx", "-y", "@nestjs/cli", "new", values.name, "--strict", "--skip-git", "--package-manager", executable("pnpm") and "pnpm" or "npm" }, { cwd = path, text = true }, function(result) finish(result, spec.name, join_path(path, values.name)) end)
end

local function create_go(spec, values, path)
  if not executable("go") then notify("Go is not available", vim.log.levels.ERROR) return end
  local destination = join_path(path, values.name)
  vim.fn.mkdir(destination, "p")
  run({ "go", "mod", "init", values.module }, { cwd = destination, text = true }, function(result)
    if result.code ~= 0 then finish(result, spec.name, destination) return end
    local files = { ["main.go"] = "package main\n\nimport \"fmt\"\n\nfunc main() {\n  fmt.Println(\"Hello, world\")\n}\n" }
    if spec.framework == "gin" then
      files["main.go"] = "package main\n\nimport \"github.com/gin-gonic/gin\"\n\nfunc main() {\n  router := gin.Default()\n  router.GET(\"/ping\", func(c *gin.Context) { c.JSON(200, gin.H{\"message\": \"pong\"}) })\n  router.Run()\n}\n"
    elseif spec.framework == "chi" then
      files["main.go"] = "package main\n\nimport (\n  \"net/http\"\n  \"github.com/go-chi/chi/v5\"\n)\n\nfunc main() {\n  router := chi.NewRouter()\n  router.Get(\"/health\", func(w http.ResponseWriter, _ *http.Request) { w.Write([]byte(\"ok\")) })\n  http.ListenAndServe(\":8080\", router)\n}\n"
    end
    create_files(destination, files, function(file_result)
      if file_result.code ~= 0 then finish(file_result, spec.name, destination) return end
      if spec.framework then
        local dependency = spec.framework == "gin" and "github.com/gin-gonic/gin" or "github.com/go-chi/chi/v5"
        run({ "go", "get", dependency }, { cwd = destination, text = true }, function(get_result) finish(get_result, spec.name, destination) end)
      else
        finish(file_result, spec.name, destination)
      end
    end)
  end)
end

local function create_composer(spec, values, path)
  if not executable("composer") then notify("Composer is not available", vim.log.levels.ERROR) return end
  if spec.framework == "laravel" then
    run({ "composer", "create-project", "laravel/laravel", values.name, "--no-interaction" }, { cwd = path, text = true }, function(result) finish(result, spec.name, join_path(path, values.name)) end)
    return
  end
  local destination = join_path(path, values.name)
  vim.fn.mkdir(destination, "p")
  run({ "composer", "init", "--name", values.package, "--no-interaction" }, { cwd = destination, text = true }, function(result) finish(result, spec.name, destination) end)
end

local function create_cmake(spec, values, path)
  local destination = join_path(path, values.name)
  local source = spec.language == "C" and "main.c" or "main.cpp"
  local header = spec.language == "C" and "app.h" or "app.hpp"
  local include = spec.language == "C" and "#include <stdio.h>\n#include \"app.h\"\n\nint main(void) {\n  puts(APP_MESSAGE);\n  return 0;\n}\n" or "#include <iostream>\n#include \"app.hpp\"\n\nint main() {\n  std::cout << APP_MESSAGE << std::endl;\n}\n"
  local header_body = spec.language == "C" and "#pragma once\n#define APP_MESSAGE \"Hello, world\"\n" or "#pragma once\n#define APP_MESSAGE \"Hello, world\"\n"
  local cmake_language = spec.language == "C" and "C" or "CXX"
  local project = "cmake_minimum_required(VERSION 3.20)\nproject(" .. values.name .. " LANGUAGES " .. cmake_language .. ")\nadd_executable(" .. values.name .. " src/" .. source .. ")\ntarget_include_directories(" .. values.name .. " PRIVATE include)\n"
  create_files(destination, {
    ["CMakeLists.txt"] = project,
    ["src/" .. source] = include,
    ["include/" .. header] = header_body,
  }, function(result)
    if executable("cmake") then
      run({ "cmake", "-S", destination, "-B", join_path(destination, "build") }, { text = true }, function(check_result)
        if check_result.code ~= 0 then notify(spec.name .. " generated, but CMake validation failed", vim.log.levels.WARN) end
        finish(result, spec.name, destination)
      end)
    else
      finish(result, spec.name, destination)
    end
  end)
end

local function configure_empty(callback)
  callback({})
end

local function java_spec(id, name, family, build_system, tree, create, dsl)
  return { id = id, name = name, family = family, language = "Java", icon = "󰬷", build_system = build_system, dsl = dsl or "kotlin", tree = tree, configure = java_values, create = create }
end

local function vite_spec(id, name, language, template)
  return { id = id, name = name, family = name:gsub(" ·.*", ""), language = language, icon = language == "JavaScript" and "󰌞" or "", template = template, tree = { "package.json", "index.html", "  src/", "    main.{ext}", "    App.{ext}" }, configure = configure_empty, create = create_vite }
end

local specs = {
  java_spec("java-maven", "Maven", "Plain application", "maven", { "pom.xml", "src/", "  main/", "    java/", "      {package_dir}/", "        App.java", "  test/", "    java/", "      {package_dir}/", "        AppTest.java" }, create_maven),
  java_spec("java-gradle", "Gradle Kotlin", "Plain application", "gradle", { "settings.gradle.kts", "build.gradle.kts", "src/", "  main/", "    java/", "      {package_dir}/", "        App.java", "  test/", "    java/", "      {package_dir}/", "        AppTest.java" }, create_gradle),
  java_spec("java-gradle-groovy", "Gradle Groovy", "Plain application", "gradle", { "settings.gradle", "build.gradle", "src/", "  main/", "    java/", "      {package_dir}/", "        App.java", "  test/", "    java/", "      {package_dir}/", "        AppTest.java" }, create_gradle, "groovy"),
  { id = "spring-maven", name = "Maven", family = "Spring Boot", language = "Java", icon = "󰬷", initializr_type = "maven-project", tree = { "pom.xml", "src/", "  main/", "    java/", "      {package_dir}/", "        {name}Application.java", "    resources/", "      application.properties", "  test/", "    java/", "      {package_dir}/", "        {name}ApplicationTests.java" }, configure = java_values, create = create_spring },
  { id = "spring-gradle", name = "Gradle Kotlin", family = "Spring Boot", language = "Java", icon = "󰬷", initializr_type = "gradle-project-kotlin", tree = { "settings.gradle.kts", "build.gradle.kts", "src/", "  main/", "    java/", "      {package_dir}/", "        {name}Application.java", "    resources/", "      application.properties", "  test/", "    java/", "      {package_dir}/", "        {name}ApplicationTests.java" }, configure = java_values, create = create_spring },
  { id = "spring-gradle-groovy", name = "Gradle Groovy", family = "Spring Boot", language = "Java", icon = "󰬷", initializr_type = "gradle-project", tree = { "settings.gradle", "build.gradle", "src/", "  main/", "    java/", "      {package_dir}/", "        {name}Application.java", "    resources/", "      application.properties", "  test/", "    java/", "      {package_dir}/", "        {name}ApplicationTests.java" }, configure = java_values, create = create_spring },
  { id = "javafx-maven", name = "Maven", family = "JavaFX desktop", language = "Java", icon = "󰬷", build_system = "maven", tree = { "pom.xml", "src/", "  main/", "    java/", "      {package_dir}/", "        App.java" }, configure = java_values, create = create_javafx },
  { id = "javafx-gradle", name = "Gradle Kotlin", family = "JavaFX desktop", language = "Java", icon = "󰬷", build_system = "gradle", tree = { "settings.gradle.kts", "build.gradle.kts", "src/", "  main/", "    java/", "      {package_dir}/", "        App.java" }, configure = java_values, create = create_javafx },
  { id = "javafx-gradle-groovy", name = "Gradle Groovy", family = "JavaFX desktop", language = "Java", icon = "󰬷", build_system = "gradle", dsl = "groovy", tree = { "settings.gradle", "build.gradle", "src/", "  main/", "    java/", "      {package_dir}/", "        App.java" }, configure = java_values, create = create_javafx },
  { id = "javascript-vite", name = "Vite vanilla", family = "Vanilla web", language = "JavaScript", icon = "󰌞", template = "vanilla", tree = { "package.json", "index.html", "src/", "  main.js", "  style.css" }, configure = configure_empty, create = create_vite },
  { id = "javascript-react", name = "React via Vite", family = "React", language = "JavaScript", icon = "󰌞", template = "react", tree = { "package.json", "index.html", "src/", "  main.jsx", "  App.jsx" }, configure = configure_empty, create = create_vite },
  { id = "javascript-vue", name = "Vue via Vite", family = "Vue", language = "JavaScript", icon = "󰌞", template = "vue", tree = { "package.json", "index.html", "src/", "  main.js", "  App.vue" }, configure = configure_empty, create = create_vite },
  { id = "javascript-svelte", name = "Svelte via Vite", family = "Svelte", language = "JavaScript", icon = "󰌞", template = "svelte", tree = { "package.json", "index.html", "src/", "  main.js", "  App.svelte" }, configure = configure_empty, create = create_vite },
  { id = "javascript-next", name = "Next.js", family = "Next.js", language = "JavaScript", icon = "󰌞", typescript = false, tree = { "package.json", "next.config.ts", "src/", "  app/", "    layout.js", "    page.js" }, configure = configure_empty, create = create_next },
  { id = "typescript-vite-react", name = "React via Vite", family = "React", language = "TypeScript", icon = "", template = "react-ts", tree = { "package.json", "index.html", "src/", "  main.tsx", "  App.tsx" }, configure = configure_empty, create = create_vite },
  { id = "typescript-vite-vue", name = "Vue via Vite", family = "Vue", language = "TypeScript", icon = "", template = "vue-ts", tree = { "package.json", "index.html", "src/", "  main.ts", "  App.vue" }, configure = configure_empty, create = create_vite },
  { id = "typescript-angular", name = "Angular CLI", family = "Angular", language = "TypeScript", icon = "󰚲", tree = { "package.json", "angular.json", "src/", "  main.ts", "  app/", "    app.component.ts", "    app.routes.ts" }, configure = configure_empty, create = create_angular },
  { id = "typescript-next", name = "Next.js", family = "Next.js", language = "TypeScript", icon = "", typescript = true, tree = { "package.json", "next.config.ts", "src/", "  app/", "    layout.tsx", "    page.tsx" }, configure = configure_empty, create = create_next },
  { id = "typescript-nest", name = "NestJS", family = "NestJS API", language = "TypeScript", icon = "", tree = { "package.json", "src/", "  main.ts", "  app.controller.ts", "  app.module.ts", "  app.service.ts" }, configure = configure_empty, create = create_nest },
  { id = "python-uv", name = "uv application", family = "Plain application", language = "Python", icon = "", tree = { "pyproject.toml", "main.py" }, configure = configure_empty, create = create_uv },
  { id = "python-fastapi", name = "FastAPI via uv", family = "FastAPI API", language = "Python", icon = "", tree = { "pyproject.toml", "app/", "  __init__.py", "  main.py", "  routers/", "    __init__.py", "    health.py" }, configure = configure_empty, create = create_fastapi },
  { id = "python-django", name = "Django via uv", family = "Django web", language = "Python", icon = "", tree = { "pyproject.toml", "manage.py", "config/", "  __init__.py", "  settings.py", "  urls.py", "  wsgi.py" }, configure = configure_empty, create = create_django },
  { id = "go-module", name = "Go module", family = "Plain module", language = "Go", icon = "󰟓", framework = false, tree = { "go.mod", "main.go" }, configure = function(callback) vim.ui.input({ prompt = "Go module: ", default = "example.com/project" }, function(module) if trim(module) ~= "" then callback({ module = trim(module) }) end end) end, create = create_go },
  { id = "go-gin", name = "Gin API", family = "HTTP/API service", language = "Go", icon = "󰟓", framework = "gin", tree = { "go.mod", "main.go" }, configure = function(callback) vim.ui.input({ prompt = "Go module: ", default = "example.com/project" }, function(module) if trim(module) ~= "" then callback({ module = trim(module) }) end end) end, create = create_go },
  { id = "go-chi", name = "Chi API", family = "HTTP/API service", language = "Go", icon = "󰟓", framework = "chi", tree = { "go.mod", "main.go" }, configure = function(callback) vim.ui.input({ prompt = "Go module: ", default = "example.com/project" }, function(module) if trim(module) ~= "" then callback({ module = trim(module) }) end end) end, create = create_go },
  { id = "php-composer", name = "Composer package", family = "Plain application", language = "PHP", icon = "", package = "vendor/project", tree = { "composer.json", "src/", "  .gitkeep", "tests/", "  .gitkeep" }, configure = function(callback) vim.ui.input({ prompt = "Package name: ", default = "vendor/project" }, function(package) if package and package:match("^[%w_.-]+/[%w_.-]+$") then callback({ package = package }) end end) end, create = create_composer },
  { id = "php-laravel", name = "Laravel", family = "Laravel web", language = "PHP", icon = "", framework = "laravel", tree = { "composer.json", "artisan", "app/", "  Http/", "  Models/", "routes/", "  web.php", "resources/", "  views/", "database/", "  database.sqlite" }, configure = configure_empty, create = create_composer },
  { id = "c-cmake", name = "CMake application", family = "C application", language = "C", icon = "", tree = { "CMakeLists.txt", "src/", "  main.c", "include/", "  app.h", "build/" }, configure = configure_empty, create = create_cmake },
  { id = "cpp-cmake", name = "CMake application", family = "C++ application", language = "C++", icon = "", tree = { "CMakeLists.txt", "src/", "  main.cpp", "include/", "  app.hpp", "build/" }, configure = configure_empty, create = create_cmake },
  { id = "rust-cargo", name = "Cargo binary", family = "Plain application", language = "Rust", icon = "", tree = { "Cargo.toml", "src/", "  main.rs" }, configure = configure_empty, create = function(spec, values, path) if not executable("cargo") then notify("Cargo is not available", vim.log.levels.ERROR) return end run({ "cargo", "new", "--bin", "--name", values.name, join_path(path, values.name) }, { text = true }, function(result) finish(result, spec.name, join_path(path, values.name)) end) end },
}

local function language_entries()
  local languages = {}
  local seen = {}
  for _, spec in ipairs(specs) do
    if not seen[spec.language] then
      seen[spec.language] = true
      languages[#languages + 1] = { id = spec.language, name = spec.language, icon = spec.icon }
    end
  end
  return languages
end

local function family_entries(language)
  local families = {}
  local seen = {}
  for _, spec in ipairs(specs) do
    if spec.language == language and not seen[spec.family] then
      seen[spec.family] = true
      families[#families + 1] = { id = spec.family, name = spec.family, icon = family_icon(spec.family) }
    end
  end
  return families
end

local function structure_entries(language, family)
  local entries = {}
  for _, spec in ipairs(specs) do
    if spec.language == language and spec.family == family then
      spec.display_icon = structure_icon(spec)
      entries[#entries + 1] = spec
    end
  end
  return entries
end

local function create_project(spec)
  vim.ui.input({ prompt = "Project name: ", default = project_name(vim.fn.getcwd()) }, function(name)
    name = trim(name)
    if not valid_identifier(name:gsub("-", "_")) then
      notify("Project name must contain letters, numbers, underscores, or hyphens", vim.log.levels.ERROR)
      return
    end
    local values = { name = name }
    if spec.language == "Java" then values.package = "com.example." .. name:gsub("-", "") end
    if spec.language == "Python" then values.python_version = "3.13" end
      local default_root = default_project_directory()
      vim.ui.input({ prompt = "Destination directory: ", default = default_root }, function(root)
      root = vim.fn.expand(trim(root))
      if root == "" then
        notify("Destination directory is required", vim.log.levels.ERROR)
        return
      end
      if vim.fn.isdirectory(root) == 0 then
        if root == default_root then
          vim.fn.mkdir(root, "p")
        else
          notify("Destination directory does not exist", vim.log.levels.ERROR)
          return
        end
      end
      local destination = join_path(root, name)
      ensure_empty_directory(destination, function(allowed)
        if not allowed then return end
        spec.configure(function(configured)
          configured = configured or {}
          for key, value in pairs(values) do configured[key] = value end
          spec.create(spec, configured, root)
        end)
      end)
    end)
  end)
end

function M.select()
  pick("Create project · language", language_entries(), function(language)
    return list_preview(language.name, family_entries(language.id))
  end, function(language)
    pick("Create project · " .. language.name .. " · framework or type", family_entries(language.id), function(family)
      local structures = structure_entries(language.id, family.name)
      return list_preview(family.name, structures)
    end, function(family)
      pick("Create project · " .. language.name .. " · " .. family.name .. " · structure", structure_entries(language.id, family.name), function(spec)
        return preview(spec, { name = "project-name", package = "com.example.app" })
      end, create_project)
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("ProjectCreate", M.select, {})
  _G.project_creator = M.select
  vim.api.nvim_set_hl(0, "SnacksPickerInput", { bold = true })
  vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bold = true })
end

M._specs = specs
M._languages = language_entries
M._families = family_entries
M._structures = structure_entries
M._tree_lines = tree_lines
M._title_box = title_box
M._valid_package = valid_package
M._join_path = join_path

return M

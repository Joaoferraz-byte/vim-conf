local M = {}

local uv = vim.uv or vim.loop
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

local function current_directory()
  local directory = vim.fn.expand("%:p:h")
  if directory == "" or directory == "." then
    return vim.fn.getcwd()
  end
  return directory
end

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function read_file(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  return table.concat(vim.fn.readfile(path), "\n")
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

local function tree_lines(spec, values)
  values = values or {}
  local name = values.name or "project-name"
  local package = values.package or "com.example.app"
  local root = values.root or "/path/to/Projects"
  local package_dir = package_path(package)
  local source = {
    " " .. name .. "/",
  }
  for _, entry in ipairs(spec.tree or {}) do
    local path = entry:gsub("{name}", name):gsub("{package}", package):gsub("{package_dir}", package_dir):gsub("{root}", root)
    source[#source + 1] = entry:match("^%s") and path or "├── " .. path
  end
  return table.concat(source, "\n")
end

local function preview(spec)
  return {
    text = tree_lines(spec),
    ft = "text",
    loc = false,
  }
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

local function run(command, options, callback)
  local result
  if vim.system then
    result = vim.system(command, options or {}, function(value)
      vim.schedule(function()
        callback(value)
      end)
    end)
    return result
  end
  local stdout = {}
  local stderr = {}
  local job = vim.fn.jobstart(command, {
    cwd = options and options.cwd or nil,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(stdout, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(stderr, data)
      end
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
  local valid = true
  for relative, content in pairs(files) do
    if not write_file(join_path(path, relative), content) then
      valid = false
      break
    end
  end
  if not valid then
    notify("Unable to write the generated project", vim.log.levels.ERROR)
    return
  end
  callback({ code = 0, stdout = "", stderr = "" })
end

local function java_values(callback)
  vim.ui.select({ "8", "11", "17", "21", "25" }, {
    prompt = "Java version:",
  }, function(version)
    if not version then
      return
    end
    vim.ui.input({ prompt = "Group ID: ", default = "com.example" }, function(group)
      group = trim(group)
      if not group or not valid_package(group) then
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
  notify("Loading Spring Initializr metadata")
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
  if type(node) ~= "table" or type(node.values) ~= "table" then
    return fallback
  end
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
  for _, item in ipairs(values) do
    labels[#labels + 1] = item.label
  end
  vim.ui.select(labels, { prompt = prompt }, function(label, index)
    if not label or not index then
      return
    end
    callback(values[index].id)
  end)
end

local function create_spring(spec, values, path)
  if not executable("curl") or not executable("tar") then
    notify("Spring Initializr requires curl and tar", vim.log.levels.ERROR)
    return
  end
  spring_metadata(function(metadata)
    select_metadata(metadata, "type", "Build system:", { { id = "maven-project", label = "Maven" }, { id = "gradle-project", label = "Gradle" } }, function(type)
      select_metadata(metadata, "language", "Language:", { { id = "java", label = "Java" } }, function(language)
        select_metadata(metadata, "javaVersion", "Java version:", { { id = "21", label = "21" } }, function(java_version)
          select_metadata(metadata, "packaging", "Packaging:", { { id = "jar", label = "Jar" }, { id = "war", label = "War" } }, function(packaging)
            select_metadata(metadata, "bootVersion", "Spring Boot version:", {}, function(boot_version)
              local tmp = vim.fn.tempname() .. ".tgz"
              local archive = "starter.tgz"
              local args = {
                "curl", "-fsSL", "--max-time", "60",
                "-o", tmp,
                "https://start.spring.io/starter.tgz",
                "-d", "type=" .. type,
                "-d", "language=" .. language,
                "-d", "javaVersion=" .. java_version,
                "-d", "packaging=" .. packaging,
                "-d", "bootVersion=" .. boot_version,
                "-d", "groupId=" .. values.package,
                "-d", "artifactId=" .. values.name,
                "-d", "name=" .. values.name,
                "-d", "packageName=" .. values.package,
                "-d", "baseDir=" .. values.name,
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
  local command = {
    "gradle", "init",
    "--type", spec.gradle_type,
    "--dsl", spec.dsl,
    "--test-framework", "junit-jupiter",
    "--package", values.package,
    "--project-name", values.name,
    "--java-version", values.java_version,
    "--no-split-project",
  }
  run(command, { cwd = destination, text = true }, function(result)
    finish(result, spec.name, destination)
  end)
end

local function create_maven(spec, values, path)
  if not executable("mvn") then
    notify("Maven is not available", vim.log.levels.ERROR)
    return
  end
  local command = {
    "mvn", "-B", "org.apache.maven.plugins:maven-archetype-plugin:3.4.1:generate",
    "-DarchetypeGroupId=org.apache.maven.archetypes",
    "-DarchetypeArtifactId=maven-archetype-quickstart",
    "-DarchetypeVersion=1.5",
    "-DgroupId=" .. values.package,
    "-DartifactId=" .. values.name,
    "-Dversion=1.0-SNAPSHOT",
    "-Dmaven.compiler.release=" .. values.java_version,
    "-DinteractiveMode=false",
  }
  run(command, { cwd = path, text = true }, function(result)
    finish(result, spec.name, join_path(path, values.name))
  end)
end

local function create_uv(spec, values, path)
  if not executable("uv") then
    notify("uv is not available", vim.log.levels.ERROR)
    return
  end
  run({ "uv", "init", "--app", "--python", values.python_version, "--name", values.name, join_path(path, values.name) }, { text = true }, function(result)
    finish(result, spec.name, join_path(path, values.name))
  end)
end

local function create_poetry(spec, values, path)
  if not executable("poetry") then
    notify("Poetry is not available", vim.log.levels.ERROR)
    return
  end
  run({ "poetry", "new", "--name", values.package, join_path(path, values.name) }, { text = true }, function(result)
    finish(result, spec.name, join_path(path, values.name))
  end)
end

local function create_cargo(spec, values, path)
  if not executable("cargo") then
    notify("Cargo is not available", vim.log.levels.ERROR)
    return
  end
  run({ "cargo", "new", "--bin", "--name", values.name, join_path(path, values.name) }, { text = true }, function(result)
    finish(result, spec.name, join_path(path, values.name))
  end)
end

local function create_go(spec, values, path)
  if not executable("go") then
    notify("Go is not available", vim.log.levels.ERROR)
    return
  end
  local destination = join_path(path, values.name)
  vim.fn.mkdir(destination, "p")
  run({ "go", "mod", "init", values.module }, { cwd = destination, text = true }, function(result)
    if result.code ~= 0 then
      finish(result, spec.name, destination)
      return
    end
    create_files(destination, {
      ["main.go"] = "package main\n\nimport \"fmt\"\n\nfunc main() {\n\tfmt.Println(\"Hello, world\")\n}\n",
    }, function(file_result)
      finish(file_result, spec.name, destination)
    end)
  end)
end

local function create_zig(spec, values, path)
  if not executable("zig") then
    notify("Zig is not available", vim.log.levels.ERROR)
    return
  end
  local destination = join_path(path, values.name)
  vim.fn.mkdir(destination, "p")
  run({ "zig", "init" }, { cwd = destination, text = true }, function(result)
    finish(result, spec.name, destination)
  end)
end

local function create_cmake(spec, values, path)
  local destination = join_path(path, values.name)
  local source = spec.language == "C" and "main.c" or "main.cpp"
  local body = spec.language == "C" and "#include <stdio.h>\n\nint main(void) {\n    puts(\"Hello, world\");\n    return 0;\n}\n" or "#include <iostream>\n\nint main() {\n    std::cout << \"Hello, world\\n\";\n    return 0;\n}\n"
  local project = "cmake_minimum_required(VERSION 3.20)\nproject(" .. values.name .. " LANGUAGES " .. spec.language .. ")\nset(CMAKE_CXX_STANDARD 20)\nset(CMAKE_CXX_STANDARD_REQUIRED ON)\nadd_executable(" .. values.name .. " " .. source .. ")\n"
  create_files(destination, {
    ["CMakeLists.txt"] = project,
    [source] = body,
  }, function(result)
    if executable("cmake") then
      run({ "cmake", "-S", destination, "-B", join_path(destination, "build") }, { text = true }, function(check_result)
        if check_result.code ~= 0 then
          notify(spec.name .. " generated, but CMake validation failed", vim.log.levels.WARN)
        end
        finish(result, spec.name, destination)
      end)
      return
    end
    finish(result, spec.name, destination)
  end)
end

local function create_vite(spec, values, path)
  local manager = executable("pnpm") and "pnpm" or "npm"
  local command = manager == "pnpm" and { "pnpm", "create", "vite", values.name, "--template", "vanilla-ts" } or { "npm", "create", "vite@latest", values.name, "--", "--template", "vanilla-ts" }
  run(command, { cwd = path, text = true }, function(result)
    finish(result, spec.name, join_path(path, values.name))
  end)
end

local specs = {
  {
    id = "java-maven",
    name = "Java application · Maven",
    language = "Java",
    icon = "󰬷",
    tabler = "brand-java",
    tree = { "pom.xml", "src/main/java/{package_dir}/App.java", "src/test/java/{package_dir}/AppTest.java" },
    configure = java_values,
    create = create_maven,
  },
  {
    id = "java-gradle",
    name = "Java application · Gradle Kotlin DSL",
    language = "Java",
    icon = "󰬷",
    tabler = "brand-java",
    tree = { "settings.gradle.kts", "build.gradle.kts", "src/main/java/{package_dir}/App.java", "src/test/java/{package_dir}/AppTest.java" },
    gradle_type = "java-application",
    dsl = "kotlin",
    configure = java_values,
    create = create_gradle,
  },
  {
    id = "java-spring",
    name = "Java application · Spring Initializr",
    language = "Java",
    icon = "󰬷",
    tabler = "brand-java",
    tree = { "pom.xml or build.gradle", "src/main/java/{package_dir}/{name}Application.java", "src/test/java/{package_dir}/{name}ApplicationTests.java" },
    configure = java_values,
    create = create_spring,
  },
  {
    id = "python-uv",
    name = "Python application · uv",
    language = "Python",
    icon = "",
    tabler = "brand-python",
    tree = { "pyproject.toml", "src/{name}/__init__.py", "src/{name}/__main__.py" },
    configure = function(callback)
      vim.ui.select({ "3.11", "3.12", "3.13", "3.14" }, { prompt = "Python version:" }, function(version)
        if version then
          callback({ python_version = version, package = "src." .. project_name(vim.fn.getcwd()) })
        end
      end)
    end,
    create = create_uv,
  },
  {
    id = "python-poetry",
    name = "Python library · Poetry",
    language = "Python",
    icon = "",
    tabler = "brand-python",
    tree = { "pyproject.toml", "{name}/__init__.py", "tests/" },
    configure = function(callback)
      vim.ui.input({ prompt = "Python package: ", default = "package_name" }, function(package)
        package = trim(package)
        if package ~= "" and valid_identifier(package:gsub("-", "_")) then
          callback({ package = package:gsub("-", "_") })
        end
      end)
    end,
    create = create_poetry,
  },
  {
    id = "rust-cargo",
    name = "Rust application · Cargo",
    language = "Rust",
    icon = "",
    tabler = "brand-rust",
    tree = { "Cargo.toml", "src/main.rs" },
    configure = function(callback)
      callback({})
    end,
    create = create_cargo,
  },
  {
    id = "go-module",
    name = "Go module",
    language = "Go",
    icon = "󰟓",
    tabler = "brand-golang",
    tree = { "go.mod", "main.go" },
    configure = function(callback)
      vim.ui.input({ prompt = "Go module: ", default = "example.com/project" }, function(module)
        module = trim(module)
        if module ~= "" then
          callback({ module = module })
        end
      end)
    end,
    create = create_go,
  },
  {
    id = "cpp-cmake",
    name = "C++ application · CMake",
    language = "C++",
    icon = "",
    tabler = "brand-cpp",
    tree = { "CMakeLists.txt", "main.cpp", "build/" },
    configure = function(callback)
      callback({})
    end,
    create = create_cmake,
  },
  {
    id = "c-cmake-embedded",
    name = "C application · CMake embedded starter",
    language = "C",
    icon = "",
    tabler = "brand-c",
    tree = { "CMakeLists.txt", "main.c", "build/" },
    configure = function(callback)
      callback({})
    end,
    create = create_cmake,
  },
  {
    id = "zig-executable",
    name = "Zig executable",
    language = "Zig",
    icon = "",
    tabler = "brand-zig",
    tree = { "build.zig", "build.zig.zon", "src/main.zig" },
    configure = function(callback)
      callback({})
    end,
    create = create_zig,
  },
  {
    id = "typescript-vite",
    name = "TypeScript application · Vite",
    language = "TypeScript",
    icon = "",
    tabler = "brand-typescript",
    tree = { "package.json", "index.html", "src/main.ts" },
    configure = function(callback)
      callback({})
    end,
    create = create_vite,
  },
}

local function apply_values(spec, values, callback)
  vim.ui.input({ prompt = "Project name: ", default = project_name(vim.fn.getcwd()) }, function(name)
    name = trim(name)
    if not valid_identifier(name:gsub("-", "_")) then
      notify("Project name must contain letters, numbers, underscores, or hyphens", vim.log.levels.ERROR)
      return
    end
    local defaults = values or {}
    defaults.name = name
    if spec.language == "Java" and not defaults.package then
      defaults.package = "com.example." .. name:gsub("-", "")
    end
    vim.ui.input({ prompt = "Destination directory: ", default = current_directory() }, function(root)
      root = vim.fn.expand(trim(root))
      if root == "" or vim.fn.isdirectory(root) == 0 then
        notify("Destination directory does not exist", vim.log.levels.ERROR)
        return
      end
      local destination = join_path(root, name)
      ensure_empty_directory(destination, function(allowed)
        if not allowed then
          return
        end
        callback(defaults, root)
      end)
    end)
  end)
end

function M.create(spec)
  apply_values(spec, {}, function(values, root)
    spec.configure(function(configured)
      configured = configured or {}
      for key, value in pairs(values) do
        configured[key] = value
      end
      spec.create(spec, configured, root)
    end)
  end)
end

function M.select()
  local items = {}
  for _, spec in ipairs(specs) do
    items[#items + 1] = {
      text = spec.icon .. "  " .. spec.name .. "  [tabler:" .. spec.tabler .. "]",
      spec = spec,
      preview = preview(spec),
    }
  end
  Snacks.picker.pick({
    title = "Create project",
    items = items,
    format = "text",
    preview = "preview",
    layout = { preset = "default" },
    confirm = function(picker, item)
      picker:close()
      if item and item.spec then
        M.create(item.spec)
      end
    end,
  })
end

function M.setup()
  vim.api.nvim_create_user_command("ProjectCreate", M.select, {})
  _G.project_creator = M.select
end

M._specs = specs
M._tree_lines = tree_lines
M._valid_package = valid_package
M._metadata_values = metadata_values
M._join_path = join_path

return M

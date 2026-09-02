local M = {}

local uv = vim.uv or vim.loop
local state = {
  source_roots = { "src/main/java", "src/test/java", "src" },
  root_markers = {
    "pom.xml",
    "mvnw",
    "build.gradle",
    "build.gradle.kts",
    "gradlew",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
  },
}

local function normalize(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function existing_path(path)
  local candidate = normalize(path)
  while candidate ~= "/" do
    local resolved = uv.fs_realpath(candidate)
    if resolved then
      local suffix = normalize(path):sub(#candidate + 1)
      return normalize(resolved .. suffix)
    end
    candidate = vim.fn.fnamemodify(candidate, ":h")
  end
  return normalize(path)
end

local function is_dir(path)
  return vim.fn.isdirectory(path) == 1
end

local function current_dir()
  if type(vim.b.oil_current_dir) == "string" and vim.b.oil_current_dir ~= "" then
    return normalize(vim.b.oil_current_dir)
  end
  local name = vim.api.nvim_buf_get_name(0)
  if vim.startswith(name, "oil://") then
    name = name:sub(7)
  end
  if name ~= "" then
    local absolute = normalize(name)
    if is_dir(absolute) then
      return absolute
    end
    return vim.fn.fnamemodify(absolute, ":h")
  end
  return normalize(vim.fn.getcwd())
end

local function contains(root, path)
  root = existing_path(root):gsub("/$", "")
  path = existing_path(path):gsub("/$", "")
  return path == root or vim.startswith(path, root .. "/")
end

local function find_root(start)
  local markers = vim.fs.find(state.root_markers, {
    path = start,
    upward = true,
  })
  if #markers > 0 then
    return vim.fn.fnamemodify(markers[1], ":h")
  end
  return start
end

local function source_context(base_dir, root)
  for _, relative in ipairs(state.source_roots) do
    local source_root = normalize(vim.fs.joinpath(root, relative))
    if contains(source_root, base_dir) then
      local relative_path = base_dir:sub(#source_root + 2)
      local package = relative_path:gsub("/", ".")
      return source_root, package ~= "" and package or nil
    end
  end
  if base_dir == normalize(root) then
    local main_source = normalize(vim.fs.joinpath(root, state.source_roots[1]))
    if is_dir(main_source) then
      return main_source, nil
    end
  end
  return base_dir, nil
end

local function valid_package(package)
  if package == "" then
    return true
  end
  local segments = 0
  for segment in package:gmatch("[^%.]+") do
    segments = segments + 1
    if not segment:match("^[a-z][a-z0-9_]*$") then
      return false
    end
  end
  return segments > 0 and not package:match("%.%.") and package:sub(1, 1) ~= "." and package:sub(-1) ~= "."
end

local function valid_class_name(name)
  return name ~= nil and name:match("^[A-Z][A-Za-z0-9_]*$") ~= nil
end

local function render(package, class_name)
  local header = package ~= "" and ("package " .. package .. ";\n\n") or ""
  return header .. "public class " .. class_name .. " {\n}\n"
end

local function atomic_write(path, content)
  local parent = vim.fn.fnamemodify(path, ":h")
  local temporary = vim.fs.joinpath(parent, "." .. vim.fn.fnamemodify(path, ":t") .. ".tmp-" .. vim.fn.getpid())
  local fd, open_err = uv.fs_open(temporary, "w", 420)
  if not fd then
    return false, open_err or "could not open temporary file"
  end
  local ok, write_err = pcall(function()
    assert(uv.fs_write(fd, content, -1))
    if uv.fs_fsync then
      assert(uv.fs_fsync(fd))
    end
  end)
  uv.fs_close(fd)
  if not ok then
    uv.fs_unlink(temporary)
    return false, write_err
  end
  local renamed, rename_err = uv.fs_rename(temporary, path)
  if not renamed then
    uv.fs_unlink(temporary)
    return false, rename_err or "could not rename temporary file"
  end
  return true
end

local function refresh_explorers()
  vim.api.nvim_exec_autocmds("User", { pattern = "JavaScaffoldCreated" })
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Java scaffold" })
end

function M.setup(opts)
  opts = opts or {}
  if opts.source_roots then
    state.source_roots = vim.deepcopy(opts.source_roots)
  end
  if opts.root_markers then
    state.root_markers = vim.deepcopy(opts.root_markers)
  end
  if vim.fn.exists(":JavaScaffold") == 0 then
    vim.api.nvim_create_user_command("JavaScaffold", function(command)
      M.create({ base_dir = command.args ~= "" and command.args or nil })
    end, { nargs = "?", complete = "dir" })
  end
  _G.java_scaffold_create = function(base_dir)
    return M.create({ base_dir = base_dir })
  end
end

function M.create(opts)
  opts = opts or {}
  local base_dir = normalize(opts.base_dir or current_dir())
  if not is_dir(base_dir) then
    notify("Selected location is not a directory", vim.log.levels.ERROR)
    return false
  end

  local root = find_root(base_dir)
  local source_root, inferred_package = source_context(base_dir, root)
  local default_package = inferred_package or "com.example"
  local default_class = "Main"

  vim.ui.input({ prompt = "Java package: ", default = default_package }, function(package)
    if package == nil then
      return
    end
    vim.ui.input({ prompt = "Java class: ", default = default_class }, function(class_name)
      if class_name == nil then
        return
      end
      package = vim.trim(package)
      class_name = vim.trim(class_name)
      if not valid_package(package) then
        notify("Invalid Java package", vim.log.levels.ERROR)
        return
      end
      if not valid_class_name(class_name) then
        notify("Class name must start with an uppercase letter", vim.log.levels.ERROR)
        return
      end

      local package_path = package:gsub("%.", "/")
      local target_dir = package == "" and source_root or vim.fs.joinpath(source_root, package_path)
      local target = vim.fs.joinpath(target_dir, class_name .. ".java")
      if not contains(root, target) then
        notify("Target escapes the project root", vim.log.levels.ERROR)
        return
      end
      if uv.fs_stat(target) then
        vim.ui.select({ "Open existing", "Cancel" }, { prompt = "Java file already exists: " .. target }, function(choice)
          if choice == "Open existing" then
            vim.cmd("edit " .. vim.fn.fnameescape(target))
          end
        end)
        return
      end

      if vim.fn.mkdir(target_dir, "p") ~= 1 and not is_dir(target_dir) then
        notify("Could not create package directory", vim.log.levels.ERROR)
        return
      end
      local ok, err = atomic_write(target, render(package, class_name))
      if not ok then
        notify("Could not create " .. target .. ": " .. tostring(err), vim.log.levels.ERROR)
        return
      end
      vim.cmd("edit " .. vim.fn.fnameescape(target))
      vim.bo.filetype = "java"
      refresh_explorers()
      notify("Created " .. target)
    end)
  end)
  return true
end

M._valid_package = valid_package
M._valid_class_name = valid_class_name
M._render = render
M._contains = contains

return M

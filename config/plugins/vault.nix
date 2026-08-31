{ ... }:
{
  extraConfigLua = ''
    local vault_root = vim.fn.expand("$HOME/Vault")

    local function notify(message, level)
      vim.notify(message, level or vim.log.levels.INFO)
    end

    local function resolve_vault_segment(parent, segment)
      local direct = parent .. "/" .. segment
      if vim.fn.isdirectory(direct) == 1 or vim.fn.filereadable(direct) == 1 then
        return direct
      end
      for _, path in ipairs(vim.fn.glob(parent .. "/*", false, true)) do
        local basename = vim.fn.fnamemodify(path, ":t")
        if basename:match("^%d%d%s*%-%s*" .. vim.pesc(segment) .. "$") then
          return path
        end
      end
      return direct
    end

    local function vault_area(relative)
      local current = vault_root
      for segment in relative:gmatch("[^/]+") do
        current = resolve_vault_segment(current, segment)
      end
      return current
    end

    local function sync_vault()
      if vim.fn.executable("livara-vault-sync") ~= 1 then
        notify("Vault sync helper is not installed", vim.log.levels.ERROR)
        return false
      end
      vim.fn.system({ "livara-vault-sync" })
      if vim.v.shell_error ~= 0 then
        notify("Vault sync failed; local checkout opened", vim.log.levels.WARN)
        return false
      end
      return true
    end

    local function open_vault()
      sync_vault()
      if vim.fn.isdirectory(vault_root) == 0 then
        notify("Vault not found: " .. vault_root, vim.log.levels.ERROR)
        return
      end
      vim.cmd("Oil " .. vim.fn.fnameescape(vault_root))
    end

    _G.sync_livara_vault = sync_vault
    _G.open_livara_vault = open_vault

    local function slugify(value)
      value = value:lower():gsub("[^%w%s%-]", ""):gsub("%s+", "-"):gsub("%-+", "-")
      return value:gsub("^%-", ""):gsub("%-$", "")
    end

    local function title_or_default(prompt, default)
      local value = vim.fn.input(prompt, default or "")
      return vim.trim(value)
    end

    local function make_note(kind)
      if kind == "daily" then
        local output = vim.fn.system({ "livara-daily-note", "--no-open" })
        if vim.v.shell_error ~= 0 then
          notify("Could not create today's Daily Note", vim.log.levels.ERROR)
          return
        end
        local path = vim.trim(output)
        if path ~= "" then
          vim.cmd("edit " .. vim.fn.fnameescape(path))
          notify("Opened: " .. path)
        end
        return
      end

      if vim.fn.isdirectory(vault_root) == 0 then
        notify("Vault not found: " .. vault_root, vim.log.levels.ERROR)
        return
      end

      local today = os.date("%Y-%m-%d")
      local now = os.date("%Y-%m-%dT%H:%M:%S%z")
      local title = title_or_default("Title: ", kind == "daily" and today or "")
      if title == "" then
        return
      end

      local definitions = {
        daily = {
          area = "03 - Daily Notes",
          filename = today .. ".md",
          lines = {
            "---", "title: " .. title, "tags:", "  - daily", "area: daily", "status: active",
            "created: " .. now, "updated: " .. now, "---", "# " .. title, "",
            "## Focus", "", "## Tasks", "- [ ] ", "", "## Notes", "",
          },
        },
        source = {
          area = "01 - Source Notes",
          filename = slugify(title) .. ".md",
          lines = {
            "---", "title: " .. title, "tags:", "  - source-note", "area: source-notes",
            "status: draft", "source_status: needs-review", "source: ", "created: " .. now,
            "updated: " .. now, "---", "# " .. title, "", "## Content", "", "## Open questions", "", "## Sources", "- ",
          },
        },
        concept = {
          area = "01 - Source Notes",
          filename = slugify(title) .. ".md",
          lines = {
            "---", "title: " .. title, "tags:", "  - concept", "area: source-notes",
            "status: draft", "source_status: verified", "created: " .. now, "updated: " .. now,
            "---", "# " .. title, "", "## Definition", "", "## Intuition", "", "## Key points",
            "- ", "", "## Examples", "", "## Relations", "- ", "", "## Sources", "- ",
          },
        },
        book = {
          area = "05 - References/Books",
          filename = slugify(title) .. ".md",
          lines = {
            "---", "title: " .. title, "type: book", "tags:", "  - reference", "  - book",
            "area: references/books", "status: draft", "source_status: needs-review", "author: ",
            "published: ", "created: " .. now, "updated: " .. now, "---", "# " .. title, "",
            "## Summary", "", "## Key passages", "", "## Notes", "", "## Citation", "",
          },
        },
        quick_capture = {
          area = "00 - Black Box/Quick Capture",
          filename = "Inbox.md",
          lines = { "---", "title: Quick Capture Inbox", "tags:", "  - inbox", "  - quick-capture", "area: black-box/quick-capture", "status: active", "source_status: needs-review", "---", "# Quick Capture Inbox", "", "## Inbox", "- " .. title, "", },
        },
      }

      local definition = definitions[kind]
      if not definition then
        notify("Unknown Vault template: " .. kind, vim.log.levels.ERROR)
        return
      end

      local path = vault_area(definition.area) .. "/" .. definition.filename
      if kind == "quick_capture" and vim.fn.filereadable(path) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        vim.fn.append(vim.fn.line("$") - 1, "- " .. title)
        vim.cmd("write")
        notify("Captured in: " .. path)
        return
      end
      if vim.fn.filereadable(path) == 1 then
        notify("Vault note already exists: " .. path, vim.log.levels.WARN)
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        return
      end

      vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
      vim.fn.writefile(definition.lines, path)
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      notify("Created: " .. path)
    end

    vim.api.nvim_create_user_command("LivaraVaultSync", function() sync_vault() end, {})
    vim.api.nvim_create_user_command("LivaraVaultDaily", function() make_note("daily") end, {})
    vim.api.nvim_create_user_command("LivaraVaultSource", function() make_note("source") end, {})
    vim.api.nvim_create_user_command("LivaraVaultConcept", function() make_note("concept") end, {})
    vim.api.nvim_create_user_command("LivaraVaultBook", function() make_note("book") end, {})
    vim.api.nvim_create_user_command("LivaraVaultCapture", function() make_note("quick_capture") end, {})

    local function route_xopp(args)
      if vim.b[args.buf].livara_xopp_routed then return end
      vim.b[args.buf].livara_xopp_routed = true

      local file = vim.fn.fnamemodify(args.file, ":p")
      local launched_as_file = vim.fn.argc() == 1
        and vim.fn.fnamemodify(vim.fn.argv(0), ":p") == file

      local function close_editor_buffer()
        if launched_as_file then
          -- When `nvim note.xopp` starts a new editor, leaving an empty Nvim
          -- window open is the reported double-open. Keep only Xournal++.
          vim.cmd("silent! qa!")
        elseif vim.api.nvim_buf_is_valid(args.buf) then
          -- Oil/Neo-tree and other explorers may edit through Nvim. Preserve
          -- that session, but never leave the journal as a text buffer.
          vim.api.nvim_buf_delete(args.buf, { force = true })
        end
      end

      if vim.fn.executable("xournalpp") ~= 1 then
        notify("Cannot open .xopp: xournalpp is not installed", vim.log.levels.ERROR)
        vim.schedule(close_editor_buffer)
        return
      end

      local job = vim.fn.jobstart({ "xournalpp", file }, { detach = true })
      if job <= 0 then
        notify("Cannot open .xopp: failed to launch xournalpp", vim.log.levels.ERROR)
      end
      vim.schedule(close_editor_buffer)
    end

    vim.api.nvim_create_autocmd({ "BufReadCmd", "BufNewFile" }, {
      pattern = "*.xopp",
      callback = route_xopp,
    })
  '';
}

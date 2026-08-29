{ ... }:
{
  extraConfigLua = ''
    local vault_root = vim.fn.expand("$HOME/Vault")

    local function notify(message, level)
      vim.notify(message, level or vim.log.levels.INFO)
    end

    local function vault_area(name)
      local direct = vault_root .. "/" .. name
      if vim.fn.isdirectory(direct) == 1 then
        return direct
      end
      for _, path in ipairs(vim.fn.glob(vault_root .. "/*", false, true)) do
        local basename = vim.fn.fnamemodify(path, ":t")
        if basename:match("^%d%d%s*%-%s*" .. vim.pesc(name) .. "$") then
          return path
        end
      end
      return direct
    end

    local function slugify(value)
      value = value:lower():gsub("[^%w%s%-]", ""):gsub("%s+", "-"):gsub("%-+", "-")
      return value:gsub("^%-", ""):gsub("%-$", "")
    end

    local function title_or_default(prompt, default)
      local value = vim.fn.input(prompt, default or "")
      return vim.trim(value)
    end

    local function make_note(kind)
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
          area = "Daily Notes",
          filename = today .. ".md",
          lines = {
            "---", "title: " .. title, "tags:", "  - daily", "area: daily", "status: active",
            "created: " .. now, "updated: " .. now, "---", "# " .. title, "",
            "## Focus", "", "## Tasks", "- [ ] ", "", "## Log", "", "## Notes", "",
            "> [!note]- Handwritten page", "> Open the matching .xopp file with Xournal++.", "",
          },
        },
        source = {
          area = "Source Notes",
          filename = slugify(title) .. ".md",
          lines = {
            "---", "title: " .. title, "tags:", "  - source-note", "area: source-notes",
            "status: draft", "source_status: needs-review", "source: ", "created: " .. now,
            "updated: " .. now, "---", "# " .. title, "", "## Claim", "", "## Evidence", "",
            "## Interpretation", "", "## Open questions", "", "## Sources", "- ",
          },
        },
        concept = {
          area = "Source Notes",
          filename = slugify(title) .. ".md",
          lines = {
            "---", "title: " .. title, "tags:", "  - concept", "area: source-notes",
            "status: draft", "source_status: verified", "created: " .. now, "updated: " .. now,
            "---", "# " .. title, "", "## Definition", "", "## Intuition", "", "## Key points",
            "- ", "", "## Examples", "", "## Relations", "- ", "", "## Sources", "- ",
          },
        },
        book = {
          area = "References/Books",
          filename = slugify(title) .. ".md",
          lines = {
            "---", "title: " .. title, "type: book", "tags:", "  - reference", "  - book",
            "area: references/books", "status: draft", "source_status: needs-review", "author: ",
            "published: ", "created: " .. now, "updated: " .. now, "---", "# " .. title, "",
            "## Summary", "", "## Key passages", "", "## Notes", "", "## Citation", "",
          },
        },
        quick_capture = {
          area = "Black Box/Quick Capture",
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

    vim.api.nvim_create_user_command("LivaraVaultDaily", function() make_note("daily") end, {})
    vim.api.nvim_create_user_command("LivaraVaultSource", function() make_note("source") end, {})
    vim.api.nvim_create_user_command("LivaraVaultConcept", function() make_note("concept") end, {})
    vim.api.nvim_create_user_command("LivaraVaultBook", function() make_note("book") end, {})
    vim.api.nvim_create_user_command("LivaraVaultCapture", function() make_note("quick_capture") end, {})
  '';
}

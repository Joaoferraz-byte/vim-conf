{ ... }:
{
  # Indentation policy is editor behavior; formatter ownership lives in
  # languages/tooling.nix and delegates style to each project's config.
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "c", "cpp" },
      callback = function(args)
        vim.bo[args.buf].autoindent = true
        vim.bo[args.buf].smartindent = false
        vim.bo[args.buf].cindent = true
        vim.bo[args.buf].indentexpr = ""
        vim.bo[args.buf].cinoptions = ":1,=s"
      end,
    })
  '';
}

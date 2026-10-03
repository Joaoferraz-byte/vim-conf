{ ... }:
{
  # Keep insertion indentation aligned with the clang-format fallback policy.
  # Formatting itself remains owned by conform.nvim and project .clang-format.
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "c", "cpp" },
      callback = function(args)
        local buffer = vim.bo[args.buf]
        buffer.expandtab = true
        buffer.shiftwidth = 2
        buffer.tabstop = 2
        buffer.softtabstop = 2
        buffer.autoindent = true
        buffer.smartindent = false
        buffer.cindent = false
      end,
    })
  '';
}

{ pkgs, ... }:
{
  plugins.lsp.servers.asm_lsp = {
    enable = true;
    filetypes = [ "asm" "vmasm" ];
    rootMarkers = [ ".asm-lsp.toml" ".git" ];
  };

  extraPackages = with pkgs; [ binutils llvm gdb lldb ];
}

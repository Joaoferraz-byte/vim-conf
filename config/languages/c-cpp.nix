{ pkgs, ... }:
{
  plugins.lsp.servers.clangd = {
    enable = true;
    filetypes = [ "c" "cpp" "objc" "objcpp" "cuda" ];
    rootMarkers = [
      ".clangd" ".clang-format" ".clang-tidy" "compile_commands.json"
      "compile_flags.txt" "CMakePresets.json" "meson.build" "build.ninja"
      "Makefile" ".git"
    ];
    extraOptions = {
      cmd = [ "clangd" "--background-index" "--completion-style=detailed" ];
    };
  };

  plugins.cmake-tools.enable = true;

  extraConfigLua = ''
    vim.api.nvim_create_user_command("LivaraCompileCommands", function()
      vim.notify("Use CMAKE_EXPORT_COMPILE_COMMANDS=ON ou bear -- make; flags pertencem ao projeto.", vim.log.levels.INFO)
    end, {})
  '';

  extraPackages = with pkgs; [ clang-tools cmake ninja gdb lldb bear cppcheck ];
}

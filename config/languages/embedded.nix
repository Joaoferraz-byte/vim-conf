{ pkgs, ... }:
{
  plugins.cmake-tools.enable = true;

  extraPackages = with pkgs; [
    clang-tools
    cmake
    ninja
    gdb
    openocd
    cppcheck
  ];
}

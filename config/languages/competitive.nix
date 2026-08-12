{ pkgs, ... }:
{
  plugins.competitest.enable = true;

  extraPackages = with pkgs; [
    clang
    clang-tools
    gcc
  ];
}

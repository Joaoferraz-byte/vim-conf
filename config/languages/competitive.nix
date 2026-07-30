{ pkgs, ... }:
{
  # Competitive programming workflow for C/C++.
  plugins.competitest.enable = true;

  extraPackages = with pkgs; [
    clang
    clang-tools
    gcc
  ];
}

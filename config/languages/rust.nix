{ pkgs, ... }:
{
  # Conservative owner for the current Nvim matrix: rust-analyzer.
  # rustaceanvim must not be enabled alongside this client.
  plugins.lsp.servers.rust_analyzer = {
    enable = true;
    installCargo = false;
    installRustc = false;
    rootMarkers = [ "Cargo.toml" "rust-project.json" ".git" ];
    settings = {
      "rust-analyzer" = {
        cargo.allFeatures = false;
        checkOnSave.command = "clippy";
        procMacro.enable = true;
      };
    };
  };

  extraPackages = with pkgs; [ rustc cargo rust-analyzer rustfmt clippy ];
}

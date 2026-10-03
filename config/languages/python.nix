{ pkgs, ... }:
{
  plugins.lsp.servers.pyright = {
    enable = true;
    rootMarkers = [ "pyproject.toml" "uv.lock" "pyrightconfig.json" ".git" ];
  };
  plugins.lsp.servers.ruff = {
    enable = true;
    filetypes = [ "python" ];
    extraOptions = { init_options = { settings = { lineLength = 88; }; }; };
  };


  extraConfigLua = ''
    vim.api.nvim_create_user_command("LivaraPythonProject", function()
      vim.notify("Use uv run para Manim, pytest, debugpy e ML; o venv deve ser do projeto.", vim.log.levels.INFO)
    end, {})
  '';

  extraPackages = with pkgs; [ python3 uv ruff pyright ];
}

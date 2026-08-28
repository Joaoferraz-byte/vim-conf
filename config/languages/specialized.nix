{
  # PHP projects, including Composer-based applications and frameworks.
  plugins.lsp.servers.phpactor.enable = true;

  # PostgreSQL-aware SQL completion, diagnostics and hover. It owns the
  # `sql` filetype so a generic SQL server is not attached concurrently.
  plugins.lsp.servers.postgres_lsp.enable = true;

  # XML, XSD, XSLT and SVG documents.
  plugins.lsp.servers.lemminx.enable = true;
}

# Avaliação do IntelliJ LSP para o workflow Java do NixVim

**Data da avaliação:** 1º de setembro de 2026.  
**Escopo:** verificar se o JDTLS atual pode ser substituído pelo novo caminho Java/Kotlin baseado em IntelliJ sem comprometer imports, completion, Lombok, testes, DAP, reprodutibilidade NixOS ou licenciamento.

## Conclusão executiva

A substituição direta **não é viável neste repositório neste momento**. A oferta Java/Kotlin divulgada pela JetBrains é uma extensão para editores do ecossistema VS Code, Cursor e fluxos agênticos, distribuída por Visual Studio Marketplace/Open VSX, e não um servidor standalone documentado para ser lançado diretamente pelo cliente `vim.lsp` do Neovim [1]. O preview é gratuito por build, mas limitado a 30 dias; após esse período, o anúncio informa que será necessária uma assinatura IntelliJ IDEA Ultimate [1].

O Kotlin LSP separado é uma alternativa mais aberta para projetos Kotlin: a documentação oficial o classifica como **Alpha**, disponibiliza-o com licença Apache 2.0 e o direciona a editores compatíveis com LSP [2]. Isso não resolve o caso deste repositório, cujo workflow prioritário é Java/Spring com JDTLS, Maven/Gradle, Lombok, imports específicos do `nvim-jdtls`, Neotest e DAP.

A decisão aplicada é, portanto, **manter JDTLS**. O repositório já usa o servidor empacotado pelo Nix, um workspace por projeto, runtimes Java 8/21, importação Maven/Gradle, `nvim-cmp` e um agente Lombok determinístico. O problema observado com getters/setters não é evidência suficiente para trocar de servidor: métodos gerados só aparecem quando a dependência Lombok está no classpath do projeto, o agente está ativo durante a inicialização do JDTLS e o índice do workspace está atualizado.

## O que foi verificado

| Critério | Situação do IntelliJ Java/Kotlin LSP | Impacto no repositório |
|---|---|---|
| Distribuição | Extensão para VS Code/Cursor/Open VSX durante o preview; não há pacote standalone documentado para Neovim [1] | Não existe hoje um `package` Nix reproduzível e um `cmd` LSP suportado para substituir `jdtls` |
| Licença | Preview gratuito limitado; depois exige IntelliJ IDEA Ultimate [1] | Introduz dependência comercial e uma política de renovação incompatível com o atual fluxo open/reproducible-first |
| Protocolo | A documentação de plataforma descreve uma API LSP para plugins dentro de IDEs IntelliJ comerciais, não um servidor externo autônomo [3] | Seria necessário descobrir e manter um launcher/protocolo não documentado para Neovim |
| Java/Spring | O anúncio apresenta inteligência Java/Kotlin e integração de projetos, mas pelo canal da extensão VS Code [1] | Não há garantia pública de paridade com o workflow JDTLS, Spring, Maven/Gradle e comandos `nvim-jdtls` |
| Kotlin | Kotlin LSP oficial existe, mas está em Alpha e é orientado a Kotlin [2] | Pode ser avaliado separadamente para Kotlin; não substitui JDTLS para Java/Spring/Lombok |
| Lombok | O caminho atual usa `lombok.jar` empacotado e `JDTLS_JVM_ARGS`; o suporte do IntelliJ LSP externo não foi documentado para este cliente | Trocar sem uma matriz de testes poderia remover justamente os símbolos gerados que motivaram a investigação |
| Imports | O repositório chama `require("jdtls").organize_imports()` no workflow Java | Uma troca exigiria substituir comandos e validar `source.organizeImports`/code actions do novo servidor |
| Testes e DAP | O workflow usa `neotest-java` e configuração DAP Java | Não há evidência de adaptadores equivalentes para o servidor IntelliJ no Neovim |
| Reprodutibilidade | JDTLS, JDKs, Maven, Gradle e Lombok são membros declarativos da closure Nix | A extensão teria de ser empacotada, licenciada e atualizada como dependência externa, sem contrato atual |

## Por que o JDTLS continua sendo a escolha correta

O JDTLS é um servidor LSP dedicado e open source para Java, já empacotado no ambiente do projeto. O módulo `config/languages/java.nix` declara `plugins.jdtls`, fixa `jdtLanguageServerPackage = pkgs.jdt-language-server`, mantém `cmd = [ "jdtls" ]`, resolve raízes por `pom.xml`/Gradle/Maven wrapper e anuncia JavaSE-1.8 e JavaSE-21. Essa interface é exatamente a que o módulo NixVim espera, e o plugin `nvim-jdtls` fornece os comandos Java específicos consumidos pelos keymaps e pelo Neotest.

O completion não é uma implementação separada para cada biblioteca. `nvim-cmp` recebe itens pela fonte `nvim_lsp`, e `cmp_nvim_lsp.default_capabilities()` é aplicado globalmente antes da configuração dos servidores. Se `@AllArgsConstructor` é reconhecido, mas getters/setters não aparecem, o diagnóstico mais provável é estado do índice, classpath ou agente Lombok, não ausência de uma fonte de completion. A documentação do projeto vscode-java confirma que o JDTLS pode carregar Lombok por suporte embutido ou por agente; ao usar um jar próprio, deve-se evitar a duplicação de mecanismos [4].

## O que seria necessário para uma migração futura

Uma migração só deve ser reaberta quando a JetBrains publicar um servidor externo oficialmente lançável por clientes LSP, com distribuição e licença claras. Mesmo nesse cenário, não bastaria trocar o nome do comando em `java.nix`. Seria necessário empacotar a distribuição em Nix, validar o handshake `initialize`, `workspaceFolders`, `textDocument/completion`, diagnostics, hover, rename, code actions e `source.organizeImports`, e garantir que o cliente Neovim receba capacidades de completion e snippets equivalentes.

Depois seria preciso substituir ou adaptar os pontos Java específicos. O comando de organizar imports teria de deixar de depender de `require("jdtls").organize_imports()`; o root/workspace teria de ser revalidado por projeto; o fluxo Maven/Gradle teria de importar o mesmo conjunto de dependências; e a configuração de Lombok teria de provar a presença de getters, setters, construtores, `@Builder`, `@Data` e demais símbolos gerados em um projeto de teste real. O adaptador `neotest-java` e o DAP também precisariam de testes separados, porque ambos podem depender de semântica específica do JDTLS.

A matriz mínima de aceitação deveria abrir um projeto Maven e um projeto Gradle com Java 8 e Java 21, verificar completion de membros Lombok, diagnostics de tipos inválidos, organize imports, rename, code lens, referências, debug attach, execução de método/teste via Neotest, importação de dependências e reinicialização limpa do workspace. Nenhum desses testes pode ser considerado aprovado apenas porque a extensão funciona no VS Code; o cliente e o launcher do Neovim são partes diferentes do sistema.

## Ações recomendadas agora

A configuração deve permanecer com JDTLS e com o agente Lombok único em `JDTLS_JVM_ARGS`. Ao alterar a versão do jar ou o classpath, o workspace correspondente do JDTLS deve ser limpo/reiniciado para reconstruir o índice. O repositório não fará limpeza automática porque apagar estado de workspace é uma ação destrutiva e depende do projeto aberto.

A investigação do IntelliJ LSP deve ser reavaliada somente após uma distribuição standalone documentada. Até lá, o Kotlin LSP pode ser estudado como um workflow separado para projetos Kotlin puros, sem misturá-lo ao owner Java/Spring existente. Essa separação preserva a arquitetura declarativa, evita dependência comercial prematura e mantém os caminhos de imports, Lombok, testes e DAP que já são verificáveis.

## Referências

[1]: https://blog.jetbrains.com/idea/2026/08/intellij-idea-goes-lsp/ "JetBrains Blog — IntelliJ IDEA Goes LSP: Java and Kotlin Intelligence Comes to VS Code, Cursor, and Agentic Flows"

[2]: https://kotlinlang.org/docs/kotlin-lsp.html "Kotlin Documentation — Kotlin Language Server"

[3]: https://plugins.jetbrains.com/docs/intellij/language-server-protocol.html "IntelliJ Platform Plugin SDK — Language Server Protocol"

[4]: https://github.com/redhat-developer/vscode-java/wiki/Lombok-support "Red Hat vscode-java Wiki — Lombok support"

[5]: https://nix-community.github.io/nixvim/plugins/lsp/servers/jdtls/index.html "Nixvim Documentation — jdtls"

[6]: https://github.com/mfussenegger/nvim-jdtls "mfussenegger/nvim-jdtls — Java Language Server integration for Neovim"

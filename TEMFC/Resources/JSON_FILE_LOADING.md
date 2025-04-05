# Carregamento Automático de Arquivos JSON no TEMFC

## Problema Resolvido

O aplicativo apresentava um problema na detecção e carregamento dos arquivos JSON de exames, onde nem todos os arquivos disponíveis estavam sendo reconhecidos. Isso limitava a oferta de exames disponíveis para os usuários.

## Solução Implementada

Uma nova abordagem para detecção e carregamento de arquivos JSON foi implementada, com as seguintes características:

1. **Busca Recursiva Aprimorada**:
   - Implementação de um sistema que percorre recursivamente o bundle do aplicativo
   - Detecção automática de todos os arquivos JSON em qualquer subdiretório

2. **Detecção Inteligente**:
   - Identificação de arquivos de exame por meio de padrões no nome (por exemplo, "TEMFC", "Prova", "Exam")
   - Suporte para múltiplos formatos e localizações de arquivos

3. **Robustez e Resiliência**:
   - Sistema de fallback para métodos alternativos de carregamento caso a abordagem principal falhe
   - Validação de arquivos para garantir integridade dos dados

4. **Detecção Automática de Novos Arquivos**:
   - Novos arquivos JSON adicionados ao projeto serão detectados automaticamente sem necessidade de alteração no código

## Como Funciona

1. A extensão `Bundle` agora possui métodos aprimorados:
   - `allJSONFiles`: Lista todos os nomes de arquivos JSON no bundle, incluindo subdiretórios
   - `findAllJSONFileURLs`: Retorna detalhes completos de todos os arquivos JSON (nome, URL e diretório pai)

2. O `DataManager` utiliza esses métodos para:
   - Localizar todos os arquivos JSON no bundle
   - Filtrar apenas os que parecem ser arquivos de exame
   - Carregar e decodificar os arquivos identificados

3. O sistema determina automaticamente o tipo de exame (teórico ou teórico-prático) com base:
   - No conteúdo do arquivo JSON
   - No nome do arquivo
   - No diretório onde está localizado

## Como Testar

Para verificar o funcionamento da nova implementação:

1. **Modo de Diagnóstico**:
   - Execute o aplicativo com o argumento de linha de comando `diagnoseFiles`
   - O aplicativo executará o método `testJSONFileDetection()` e exibirá os resultados no console

```swift
// Exemplo de resultados no console
--- 🧪 TESTE DE DETECÇÃO DE ARQUIVOS JSON ---
📊 Arquivos JSON encontrados com Bundle.findAllJSONFileURLs(): 5
  [1] TEMFC34.json em raiz
  [2] TEMFC35.json em raiz
  [3] TEMFC35TP.json em raiz
  [4] NovoExame.json em Teorico

📊 Arquivos de exame encontrados com findAllExamFiles(): 4
  [1] TEMFC34.json em raiz
  [2] TEMFC35.json em raiz
  [3] TEMFC35TP.json em raiz
  [4] NovoExame.json em Teorico

📊 Exames carregados: 4
  [1] Prova TEMFC 34 (TEMFC34) - Tipo: Teórica, Questões: 80
  [2] Prova TEMFC 35 (TEMFC35) - Tipo: Teórica, Questões: 80
  [3] Prova TEMFC 35 TP (TEMFC35TP) - Tipo: Teórico-Prática, Questões: 20
  [4] Novo Exame (NovoExame) - Tipo: Teórica, Questões: 50
--- FIM DO TESTE ---
```

## Adicionando Novos Exames

Para adicionar novos exames ao aplicativo, basta:

1. Criar um arquivo JSON seguindo o formato padrão (conforme os modelos existentes)
2. Adicionar o arquivo em qualquer diretório do bundle (preferencialmente em "Resources" ou subdiretórios)
3. O sistema detectará e carregará automaticamente o novo arquivo na próxima execução

Não é necessário atualizar nenhum código ou lista de arquivos para incluir novos exames.

## Considerações Técnicas

- A implementação utiliza o padrão MVVM e mantém a separação entre modelos, visualizações e lógica de negócios
- Os métodos foram otimizados para performance, usando filas de dispatch e processamento assíncrono
- Implementação de diagnóstico e logs detalhados para facilitar a identificação de problemas futuros
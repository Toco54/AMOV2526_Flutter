# Relatório Técnico - Guia Turístico de Coimbra

**Unidade Curricular:** Computação Móvel  
**Ano Letivo:** 2025/2026  
**Data:** Janeiro de 2026  

**Autores:**
*   Nome do Aluno 1 (Número)
*   Nome do Aluno 2 (Número)
*   Nome do Aluno 3 (Número)

---

## Índice

1.  [Introdução](#1-introdução)
2.  [Arquitetura e Organização do Projeto](#2-arquitetura-e-organização-do-projeto)
3.  [Detalhes de Implementação](#3-detalhes-de-implementação)
    *   [3.1. Widgets: Stateless vs. Stateful](#31-widgets-stateless-vs-stateful)
    *   [3.2. Gestão de Estado (State Management)](#32-gestão-de-estado-state-management)
    *   [3.3. Arquitetura de Dados (DataManager)](#33-arquitetura-de-dados-datamanager)
    *   [3.4. Navegação](#34-navegação)
    *   [3.5. Interface e UI/UX (Material Design 3)](#35-interface-e-uiux-material-design-3)
    *   [3.6. Integração de Serviços Externos](#36-integração-de-serviços-externos)
4.  [Desafios e Soluções](#4-desafios-e-soluções)
5.  [Análise Crítica e Melhorias Futuras](#5-análise-crítica-e-melhorias-futuras)
6.  [Conclusão](#6-conclusão)

---

## 1. Introdução

O presente relatório descreve o desenvolvimento de uma aplicação móvel para um Guia Turístico da cidade de Coimbra. O projeto foi realizado no âmbito da unidade curricular de Computação Móvel, utilizando a framework **Flutter**.

O objetivo principal foi criar uma solução funcional para dispositivos Android que permita aos utilizadores consultar pontos de interesse (organizados por categorias), ver detalhes específicos de cada local e gerir uma lista pessoal de favoritos. O projeto foca-se na implementação de boas práticas de desenvolvimento móvel, incluindo persistência de dados local, navegação estruturada e integração de serviços externos (API de meteorologia).

## 2. Arquitetura e Organização do Projeto

A arquitetura do projeto foi desenhada para promover a **separação de responsabilidades** (*Separation of Concerns*), garantindo que a interface gráfica não contenha lógica de negócio complexa. O sistema organiza-se em camadas lógicas distintas, refletidas na estrutura de pastas:

### Estrutura de Camadas
*   **Camada de Domínio (`lib/models`):** Contém as definições fundamentais dos dados. As classes `POI` e `WeatherInfo` são objetos puros responsáveis apenas por representar a informação e realizar a conversão de/para JSON, sem dependências da interface.
*   **Camada de Serviços (`lib/services`):** Centraliza a lógica da aplicação.
    *   `DataManager`: Atua como um repositório central e mediador. Isola a origem dos dados (ficheiros locais ou memória) da interface.
    *   `WeatherService`: Encapsula a comunicação com a API externa, tratando pedidos HTTP e erros de rede.
*   **Camada de Apresentação (`lib/screens` e `lib/widgets`):** Focada exclusivamente na renderização da interface e interação com o utilizador.
    *   `screens`: Representam páginas completas e gerem o ciclo de vida da navegação.
    *   `widgets`: Componentes visuais reutilizáveis e modulares (ex: cartões).

### Fluxo de Inicialização
A entrada da aplicação (`main.dart`) desempenha um papel crucial na arquitetura ao garantir a inicialização assíncrona do `DataManager` antes da execução do `runApp`. Isto assegura que, quando a árvore de widgets é construída, os dados essenciais já estão disponíveis em memória, prevenindo estados inconsistentes ou erros de "dados nulos" no arranque.

## 3. Detalhes de Implementação

Nesta secção detalham-se as opções técnicas tomadas para resolver os requisitos funcionais, ilustradas com excertos de código relevantes do projeto.

### 3.1. Widgets: Stateless vs. Stateful

A escolha entre widgets foi criteriosa, baseada na necessidade de manipulação do ciclo de vida:

*   **Stateless Widgets (Eficiência):** Privilegiou-se o uso destes widgets (ex: `CategoryCard`, `PoiCard`) para componentes que dependem apenas da sua configuração inicial.
*   **Stateful Widgets (Ciclo de Vida):** Essenciais para ecrãs com lógica temporal ou reativa. No `HomeScreen`, o método `initState()` inicia o temporizador da meteorologia e o `dispose()` cancela-o para prevenir fugas de memória:

```dart
// Excertos de lib/screens/HomeScreen.dart
@override
void initState() {
  super.initState();
  _fetchWeather();
  // Update weather every 15 minutes
  _weatherTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
    _fetchWeather();
  });
}

@override
void dispose() {
  _weatherTimer?.cancel();
  super.dispose();
}
```

### 3.2. Gestão de Estado (State Management)

Sem recorrer a bibliotecas externas complexas, a aplicação utiliza uma gestão de estado manual baseada no método `setState()`. A aplicação deste método divide-se em três cenários distintos:

1.  **Atualização de Estado Local:** Utilizada quando é necessário atualizar variáveis internas do widget e refletir esses dados na UI. No exemplo abaixo, as variáveis de meteorologia são atribuídas dentro do bloco `setState`, garantindo que a framework deteta a alteração:

```dart
// Excerto de lib/screens/HomeScreen.dart
setState(() {
  _weather = weather;
  _loadingWeather = false;
});
```

2.  **Reatividade Local:** Garante feedback visual imediato após uma interação do utilizador. Ao clicar no botão de favoritos, a operação assíncrona é aguardada e, de seguida, o `setState` vazio força a reconstrução do ícone (de vazio para cheio ou vice-versa):

```dart
// Excerto de lib/screens/POIDetailsScreen.dart
onPressed: () async {
  await _dataManager.toggleFavorite(widget.poi.id);
  setState(() {}); // Reconstrói o widget para atualizar o ícone
},
```

3.  **Sincronização no Retorno:** Assegura a consistência entre ecrãs. Ao navegar de volta de um ecrã de detalhe, é crucial atualizar a lista anterior (pois um favorito pode ter sido removido). O método `.then()` do `Navigator` captura o momento do regresso e invoca o `setState`:

```dart
// Excerto de lib/screens/POIsListScreen.dart
onTap: () {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(builder: (context) => POIDetailsScreen(poi: poi)),
  ).then((_) {
    // Força a reconstrução da lista ao voltar do ecrã de detalhe
    setState(() {}); 
  });
},
```

### 3.3. Arquitetura de Dados (DataManager)

A classe `DataManager` atua como a "Fonte Única de Verdade" (*Single Source of Truth*) da aplicação. A sua implementação é complexa e cobre várias responsabilidades críticas:

**A. Padrão Singleton**
Garante que todos os ecrãs acedem exatamente à mesma instância de dados em memória, evitando dessincronização entre vistas (ex: lista e detalhe).

```dart
class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();
  // ...
}
```

**B. Inicialização e Parsing JSON**
O método `loadData` é responsável por orquestrar o arranque da aplicação. Lê o ficheiro `assets/data/poi.json` usando `rootBundle`, descodifica a estrutura JSON e itera sobre as categorias e pontos para preencher as listas em memória (`_allPois` e `_categories`).

```dart
// Excerto de lib/services/DataManager.dart
Future<void> loadData() async {
  final String response = await rootBundle.loadString('assets/data/poi.json');
  final data = await json.decode(response);
  
  // Lógica de parsing iterando sobre categorias e pontos
  for (var catJson in data['categories']) {
     // ... criação de objetos POI e preenchimento de listas
  }
  
  // Carrega favoritos do disco após processar o JSON
  await _loadFavorites();
}
```

**C. Persistência de Favoritos**
A gestão de favoritos utiliza um `Set<int>` para garantir acessos rápidos (complexidade O(1)) e evitar duplicados. A persistência é assegurada pelo `SharedPreferences`, convertendo a lista de IDs inteiros para Strings antes de guardar no disco.

```dart
// Excerto de lib/services/DataManager.dart
Future<void> toggleFavorite(int poiId) async {
  // Atualiza em memória
  if (_favorites.contains(poiId)) {
    _favorites.remove(poiId);
  } else {
    _favorites.add(poiId);
  }
  
  // Persiste no disco
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('favorites', _favorites.map((id) => id.toString()).toList());
}
```

**D. Encapsulamento e Filtragem**
O `DataManager` expõe métodos utilitários que simplificam a lógica nos Widgets, como `getPoisByCategory(String category)` e `getFavorites()`, centralizando a lógica de filtragem.

**E. Tratamento de Exceções e Robustez**
Para evitar que a aplicação encerre abruptamente (*crash*) caso o ficheiro JSON esteja corrompido ou inacessível, todo o processo de carregamento está protegido por um bloco `try-catch-finally`.
O bloco `finally` garante que o estado de carregamento (`_isLoading`) é definido como `false` mesmo em caso de erro, permitindo que a aplicação saia do estado de "loading" e apresente uma interface (mesmo que vazia), em vez de ficar presa num loop infinito de carregamento.

```dart
// Excerto de lib/services/DataManager.dart
try {
  // Tentativa de carregar e fazer parse do JSON
  final String response = await rootBundle.loadString('assets/data/poi.json');
  // ...
} catch (e) {
  if (kDebugMode) {
    print('Error loading POIs: $e'); // Log do erro para depuração
  }
} finally {
  _isLoading = false; // Garante que a UI desbloqueia
}
```

### 3.4. Navegação

A navegação foi implementada de forma hierárquica e resiliente, utilizando diferentes estratégias para diferentes contextos:

**A. Pilha de Navegação (Navigator)**
Utiliza-se o `MaterialPageRoute` para transições fluidas e nativas da plataforma Android. A passagem de argumentos (objeto `POI`) via construtor evita pesquisas desnecessárias na base de dados ao abrir detalhes:
```dart
Navigator.push(context, MaterialPageRoute(builder: (context) => POIDetailsScreen(poi: poi)));
```

**B. Gestão de Abas e Estado (IndexedStack)**
Na `MainScreen`, a simples alternância de widgets no `body` provocaria a perda do estado de scroll. A solução implementada foi o `IndexedStack`, que mantém todas as abas "vivas" na árvore de widgets, mas apenas uma visível.
```dart
// Excerto de lib/screens/MainScreen.dart
body: IndexedStack(
  index: _selectedIndex,
  children: [
    // Tab 0: Navigator próprio para Categorias
    Navigator(onGenerateRoute: ...),
    // Tab 1: Navigator próprio para Favoritos
    Navigator(onGenerateRoute: ...),
  ],
),
```
*Nota:* Cada aba possui o seu próprio `Navigator` aninhado, permitindo que o utilizador navegue profundamente dentro de uma categoria, troque para os favoritos e, ao voltar, encontre a categoria exatamente onde a deixou.

**C. Controlo de Saída (PopScope)**
Para evitar saídas acidentais da aplicação, foi implementado o `PopScope` na `MainScreen`. Este widget interceta o botão "Voltar" do Android (`canPop: false`) e implementa uma lógica personalizada:
1. Se houver navegação interna numa aba (ex: dentro de uma lista de POIs), volta atrás nessa lista.
2. Se estiver na aba Favoritos, volta para a aba Categorias (Home).
3. Só se estiver na raiz da Home é que permite fechar a aplicação (ou voltar ao ecrã inicial).

```dart
// Excerto de lib/screens/MainScreen.dart
return PopScope(
  canPop: false,
  onPopInvokedWithResult: (bool didPop, dynamic result) async {
    // Lógica personalizada para botão Back:
    // 1. Tenta fazer pop no Navigator interno da aba
    // 2. Se não der, muda para a aba 0 (Home)
    // 3. Se já estiver na Home, sai da MainScreen
  },
  child: Scaffold(...),
);
```

### 3.5. Interface e UI/UX (Material Design 3)

A interface da aplicação foi construída utilizando os princípios do **Material Design 3**, focando-se na clareza visual e na eficiência do layout através de uma composição rica de widgets:

*   **Estrutura Base (Scaffold & AppBar):** Todos os ecrãs utilizam o widget `Scaffold` para gerir a estrutura básica (barra superior, corpo e navegação). A `AppBar` foi configurada de forma global no tema (`main.dart`) para manter a consistência, utilizando títulos centrados e elevação suave.
*   **Listagens Eficientes (ListView.builder):** Nas listas de categorias e pontos de interesse, utilizou-se o `ListView.builder`. Esta abordagem é tecnicamente superior ao `ListView` simples, pois renderiza os itens "on-demand" (apenas os que estão visíveis), otimizando o consumo de memória em listas longas.
*   **Content Containers (Card & ListTile):** Os Pontos de Interesse são encapsulados em `Cards` com cantos arredondados e elevação controlada. No interior, o widget `ListTile` organiza de forma limpa a imagem à esquerda (`leading`), o texto central (`title` e `subtitle`) e as ações à direita (`trailing`).
*   **Composição de Layouts (Stack, Column, Row):**
    *   O ecrã inicial (`HomeScreen`) utiliza um `Stack` para sobrepor a imagem de fundo, um gradiente escuro (criado com `BoxDecoration` e `LinearGradient`) e o conteúdo textual.
    *   As informações detalhadas em `POIDetailsScreen` são organizadas em `Columns` dentro de um `SingleChildScrollView` para garantir a legibilidade em ecrãs de menores dimensões.
*   **Feedback e Interação (InkWell & ElevatedButton):**
    *   Os cartões de categoria utilizam `InkWell` para fornecer feedback visual de toque (*ripple effect*).
    *   O botão principal na Home utiliza `WidgetStateProperty` para mudar a elevação e cor consoante o estado (pressionado ou em repouso), uma funcionalidade nativa do Material 3.
*   **Tratamento de Assets e Erros:** O widget `Image.asset` foi robustecido com um `errorBuilder` que exibe um ícone de substituição caso a imagem não exista no sistema de ficheiros, prevenindo buracos no layout.

### 3.6. Integração de Serviços Externos

O `WeatherService` consome a API da Open-Meteo através de operações assíncronas (`Future`) e pedidos HTTP, convertendo os códigos de resposta em dados legíveis.

```dart
// Excerto de lib/services/WeatherService.dart
Future<WeatherInfo?> fetchWeather() async {
  final url = Uri.parse('$_baseUrl?latitude=$_lat&longitude=$_lon&current_weather=true');
  
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherInfo.fromJson(json.decode(response.body));
    }
  } catch (e) {
    // Error handling...
  }
  return null;
}
```

## 4. Desafios e Soluções

O desafio de manter a **consistência dos dados globais** foi resolvido através do Singleton `DataManager`. A falta de reatividade automática foi compensada por uma lógica disciplinada de `setState()` no retorno das rotas de navegação, garantindo que o utilizador vê sempre a informação mais atualizada em qualquer ecrã da aplicação.

## 5. Análise Crítica e Melhorias Futuras

A solução desenvolvida cumpre os requisitos propostos, destacando-se pela robustez e organização.

**Melhorias Futuras:**
*   **Mapas:** Integração com Google Maps para visualização de localizações.
*   **Internacionalização:** Suporte para múltiplos idiomas.
*   **Cache:** Implementação de cache local para a meteorologia (offline).

## 6. Conclusão

O projeto resultou numa aplicação Android estável e reativa. A arquitetura escolhida, baseada em serviços e gestão de estado nativa, provou ser escalável para as necessidades do projeto, garantindo facilidade de manutenção e performance.
/// Representa um Ponto de Interesse (POI) na aplicação.
///
/// Esta classe imutável encapsula todas as informações relevantes de um ponto turístico,
/// incluindo dados descritivos, localização, preços e categorização.
/// Serve como o modelo de dados primário para a exibição de detalhes e listagens.
class POI {
  /// Identificador único do POI.
  final int id;
  /// Nome de exibição do ponto turístico.
  final String name;
  /// Descrição breve para listagens e cartões.
  final String shortDescription;
  /// Descrição detalhada para o ecrã de detalhes.
  final String description;
  /// Caminho ou nome do ficheiro da imagem associada (assets).
  final String image;
  /// Horário de funcionamento formatado como texto.
  final String schedule;
  /// Preço médio ou indicação de custo formatada.
  final String averagePrice;
  /// Localização textual ou endereço.
  final String location;
  /// Categoria à qual o POI pertence (ex: "Museus", "Parques").
  final String category;

  /// Construtor padrão para criar uma instância de [POI].
  ///
  /// Todos os campos são obrigatórios para garantir a integridade dos dados na UI.
  POI({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.image,
    required this.schedule,
    required this.averagePrice,
    required this.location,
    required this.category,
  });

  /// Cria uma instância de [POI] a partir de um mapa JSON.
  ///
  /// [json] - O mapa contendo os dados brutos do POI.
  /// [category] - A categoria pai, passada explicitamente pois a estrutura do JSON agrupa POIs por categoria.
  ///
  /// Returns: Uma nova instância de [POI] validada.
  factory POI.fromJson(Map<String, dynamic> json, String category) {
    // Mapeamento direto dos campos do JSON para as propriedades da classe.
    // NOTE: Assume-se que o JSON está bem formado e contém todas as chaves necessárias.
    return POI(
      id: json['id'],
      name: json['name'],
      shortDescription: json['short_description'],
      description: json['description'],
      image: json['image'],
      schedule: json['schedule'],
      averagePrice: json['average_price'],
      location: json['location'],
      category: category,
    );
  }
}

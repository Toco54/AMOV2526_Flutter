class PointOfInterest {
  final int id;
  final String name;
  final String shortDescription;
  final String description;
  final String image;
  final String schedule;
  final String averagePrice;
  final String location;
  final String category;

  PointOfInterest({
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

  factory PointOfInterest.fromJson(Map<String, dynamic> json, String category) {
    return PointOfInterest(
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

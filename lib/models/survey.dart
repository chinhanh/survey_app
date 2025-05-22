class Survey {
  final String id;
  final String area;
  final String sunDirection;
  final String plantType;
  final String need;
  final String budget;
  final String? imagePath;

  Survey({
    required this.id,
    required this.area,
    required this.sunDirection,
    required this.plantType,
    required this.need,
    required this.budget,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'area': area,
      'sunDirection': sunDirection,
      'plantType': plantType,
      'need': need,
      'budget': budget,
      'imagePath': imagePath,
    };
  }
}


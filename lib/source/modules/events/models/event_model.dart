enum EventCategory { all, music, sports, gastronomy }

class EventModel {
  final String id;
  final String title;
  final EventCategory category;
  final String subtitle; // ex.: "Evento musical", "Evento esportivo"
  final String? date; // opcional
  final String? place; // opcional
  final String imageAsset; // caminho do asset (placeholder)

  bool isFollowing;

  EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.imageAsset,
    this.date,
    this.place,
    this.isFollowing = false,
  });
}

String categoryLabel(EventCategory c) {
  switch (c) {
    case EventCategory.all:
      return 'Todos eventos';
    case EventCategory.music:
      return 'Músicas';
    case EventCategory.sports:
      return 'Esportes';
    case EventCategory.gastronomy:
      return 'Gastronomia';
  }
}

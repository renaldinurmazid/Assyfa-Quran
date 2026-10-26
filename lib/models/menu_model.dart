class MenuModel {
  final int id;
  final String title;
  final String? image;
  final String? asset;
  final String? route;
  final String? actionType;
  final bool? isPages;
  final String? slug;
  final int priority;
  final int? parentId;

  MenuModel({
    required this.id,
    required this.title,
    this.image,
    this.asset,
    this.route,
    this.actionType,
    this.isPages,
    this.slug,
    required this.priority,
    this.parentId,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      asset: json['asset'],
      route: json['route'],
      actionType: json['action_type'],
      isPages: json['is_pages'] == 1 || json['is_pages'] == true,
      slug: json['slug'],
      priority: json['priority'] ?? 0,
      parentId: json['parent_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'asset': asset,
      'route': route,
      'action_type': actionType,
      'is_pages': isPages,
      'slug': slug,
      'priority': priority,
      'parent_id': parentId,
    };
  }
}


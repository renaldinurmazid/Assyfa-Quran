class NotificationModel {
  int? id;
  int? userId;
  int? scheduledNotificationId;
  String? title;
  String? body;
  String? imageUrl;
  dynamic data;
  bool? isRead;
  DateTime? readAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  ScheduledNotification? scheduledNotification;

  NotificationModel({
    this.id,
    this.userId,
    this.scheduledNotificationId,
    this.title,
    this.body,
    this.imageUrl,
    this.data,
    this.isRead,
    this.readAt,
    this.createdAt,
    this.updatedAt,
    this.scheduledNotification,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        userId: json["user_id"],
        scheduledNotificationId: json["scheduled_notification_id"],
        title: json["title"],
        body: json["body"],
        imageUrl: json["image_url"],
        data: json["data"],
        isRead: json["is_read"],
        readAt: json["read_at"] != null
            ? DateTime.parse(json["read_at"])
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        scheduledNotification: json["scheduled_notification"] != null
            ? ScheduledNotification.fromJson(json["scheduled_notification"])
            : null,
      );
}

class ScheduledNotification {
  int? id;
  int? categoryNotificationId;
  CategoryNotification? categoryNotification;

  ScheduledNotification({
    this.id,
    this.categoryNotificationId,
    this.categoryNotification,
  });

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) =>
      ScheduledNotification(
        id: json["id"],
        categoryNotificationId: json["category_notification_id"],
        categoryNotification: json["category_notification"] != null
            ? CategoryNotification.fromJson(json["category_notification"])
            : null,
      );
}

class CategoryNotification {
  int? id;
  String? name;
  String? icon;
  String? bgColor;

  CategoryNotification({this.id, this.name, this.icon, this.bgColor});

  factory CategoryNotification.fromJson(Map<String, dynamic> json) =>
      CategoryNotification(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
        bgColor: json["bg_color"],
      );
}

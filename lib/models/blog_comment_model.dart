import 'dart:convert';

class BlogCommentResponse {
  final String? status;
  final String? message;
  final BlogCommentPagination? data;

  BlogCommentResponse({this.status, this.message, this.data});

  factory BlogCommentResponse.fromRawJson(String str) =>
      BlogCommentResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogCommentResponse.fromJson(Map<String, dynamic> json) =>
      BlogCommentResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : BlogCommentPagination.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class BlogCommentPagination {
  final int? currentPage;
  final List<BlogComment>? data;
  final int? lastPage;
  final int? total;

  BlogCommentPagination({
    this.currentPage,
    this.data,
    this.lastPage,
    this.total,
  });

  factory BlogCommentPagination.fromJson(Map<String, dynamic> json) =>
      BlogCommentPagination(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<BlogComment>.from(
                json["data"].map((x) => BlogComment.fromJson(x)),
              ),
        lastPage: json["last_page"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "last_page": lastPage,
        "total": total,
      };
}

class BlogComment {
  final int? id;
  final int? blogId;
  final int? userId;
  final int? parentId;
  final String? comment;
  final User? user;
  final DateTime? createdAt;
  final List<BlogComment>? replies;

  BlogComment({
    this.id,
    this.blogId,
    this.userId,
    this.parentId,
    this.comment,
    this.user,
    this.createdAt,
    this.replies,
  });

  factory BlogComment.fromRawJson(String str) =>
      BlogComment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogComment.fromJson(Map<String, dynamic> json) => BlogComment(
        id: json["id"],
        blogId: json["blog_id"],
        userId: json["user_id"],
        parentId: json["parent_id"],
        comment: json["comment"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        replies: json["replies"] == null
            ? []
            : List<BlogComment>.from(
                json["replies"].map((x) => BlogComment.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "blog_id": blogId,
        "user_id": userId,
        "parent_id": parentId,
        "comment": comment,
        "user": user?.toJson(),
        "created_at": createdAt?.toIso8601String(),
        "replies": replies == null
            ? []
            : List<dynamic>.from(replies!.map((x) => x.toJson())),
      };
}

class User {
  final int? id;
  final String? name;
  final String? photo;

  User({this.id, this.name, this.photo});

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        photo: json["profile_picture"] ?? json["photo"] ?? json["avatar"] ?? json["profile_photo_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "photo": photo,
      };
}

import 'dart:convert';

class BlogResponse {
  final String? status;
  final BlogDataPagination? data;

  BlogResponse({this.status, this.data});

  factory BlogResponse.fromRawJson(String str) =>
      BlogResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogResponse.fromJson(Map<String, dynamic> json) => BlogResponse(
    status: json["status"],
    data: json["data"] == null
        ? null
        : BlogDataPagination.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"status": status, "data": data?.toJson()};
}

class BlogDataPagination {
  final int? currentPage;
  final List<BlogItem>? data;
  final String? nextPageUrl;
  final int? lastPage;
  final int? total;

  BlogDataPagination({
    this.currentPage,
    this.data,
    this.nextPageUrl,
    this.lastPage,
    this.total,
  });

  factory BlogDataPagination.fromRawJson(String str) =>
      BlogDataPagination.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogDataPagination.fromJson(Map<String, dynamic> json) =>
      BlogDataPagination(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<BlogItem>.from(
                json["data"].map((x) => BlogItem.fromJson(x)),
              ),
        nextPageUrl: json["next_page_url"],
        lastPage: json["last_page"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "last_page": lastPage,
    "total": total,
  };
}

class BlogItem {
  final int? id;
  final String? slug;
  final String? title;
  final String? thumbnail;
  final int? categoryId;
  final int? likes;
  final int? views;
  final String? content;
  final String? author;
  final String? publishedAt;
  final DateTime? createdAt;
  final BlogCategory? category;
  final List<BlogItem>? otherPrograms;
  final bool? isLiked;

  BlogItem({
    this.id,
    this.slug,
    this.title,
    this.thumbnail,
    this.categoryId,
    this.likes,
    this.views,
    this.content,
    this.author,
    this.publishedAt,
    this.createdAt,
    this.category,
    this.otherPrograms,
    this.isLiked,
  });

  factory BlogItem.fromRawJson(String str) =>
      BlogItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogItem.fromJson(Map<String, dynamic> json) => BlogItem(
    id: json["id"],
    slug: json["slug"],
    title: json["title"],
    thumbnail: json["thumbnail"],
    categoryId: json["category_id"],
    likes: json["likes"],
    views: json["views"],
    content: json["content"],
    author: json["author"],
    publishedAt: json["published_at"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    category: json["category"] == null
        ? null
        : BlogCategory.fromJson(json["category"]),
    otherPrograms: json["other_programs"] == null
        ? []
        : List<BlogItem>.from(
            json["other_programs"].map((x) => BlogItem.fromJson(x)),
          ),
    isLiked: json["is_liked"] ?? json["liked"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "title": title,
    "thumbnail": thumbnail,
    "category_id": categoryId,
    "likes": likes,
    "views": views,
    "content": content,
    "author": author,
    "published_at": publishedAt,
    "created_at": createdAt?.toIso8601String(),
    "category": category?.toJson(),
    "other_programs": otherPrograms == null
        ? []
        : List<dynamic>.from(otherPrograms!.map((x) => x.toJson())),
    "is_liked": isLiked,
  };
}

class BlogCategory {
  final int? id;
  final String? name;
  final String? slug;
  final String? icon;

  BlogCategory({this.id, this.name, this.slug, this.icon});

  factory BlogCategory.fromRawJson(String str) =>
      BlogCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogCategory.fromJson(Map<String, dynamic> json) => BlogCategory(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "icon": icon,
  };
}

class BlogCategoryResponse {
  final String? status;
  final List<BlogCategory>? data;

  BlogCategoryResponse({this.status, this.data});

  factory BlogCategoryResponse.fromRawJson(String str) =>
      BlogCategoryResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogCategoryResponse.fromJson(Map<String, dynamic> json) =>
      BlogCategoryResponse(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<BlogCategory>.from(
                json["data"].map((x) => BlogCategory.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class BlogDetailResponse {
  final String? status;
  final BlogItem? data;

  BlogDetailResponse({this.status, this.data});

  factory BlogDetailResponse.fromRawJson(String str) =>
      BlogDetailResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlogDetailResponse.fromJson(Map<String, dynamic> json) =>
      BlogDetailResponse(
        status: json["status"],
        data: json["data"] == null ? null : BlogItem.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"status": status, "data": data?.toJson()};
}

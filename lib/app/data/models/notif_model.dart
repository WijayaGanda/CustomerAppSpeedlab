class NotifModelResponse {
  final bool? success;
  final List<NotifModel>? data;

  NotifModelResponse({this.success, this.data});

  factory NotifModelResponse.fromJson(Map<String, dynamic> json) {
    return NotifModelResponse(
      success: json['success'],
      data:
          (json['data'] as List?)
              ?.map((item) => NotifModel.fromJson(item))
              .toList(),
    );
  }
}

class NotifModel {
  final String? id;
  final String? userId;
  final String? title;
  final String? body;
  final String? type;
  final bool? isRead;
  final DateTime? createdAt;
  final int? unreadCount;
  final String? relatedId;

  NotifModel({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.type,
    this.isRead,
    this.createdAt,
    this.unreadCount,
    this.relatedId,
  });

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
      unreadCount: json['unreadCount'],
      relatedId: json['relatedId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'relatedId': relatedId,
    };
  }
}

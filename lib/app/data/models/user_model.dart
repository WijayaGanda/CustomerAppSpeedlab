class LoginResponseModel {
  String? token;
  UserModel? user;

  LoginResponseModel({this.token, this.user});
  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
  }
}

class UserModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? role;
  String? avatar;
  String? googleId;
  // String? token;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.role,
    this.avatar,
    this.googleId,
    // this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    role: json["role"],
    avatar: json["avatar"],
    googleId: json["google_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "address": address,
    "role": role,
    "avatar": avatar,
    "google_id": googleId, // Pastikan key sama dengan response API
  };
}

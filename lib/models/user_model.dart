class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? plateNumber;
  final String userType; // 'Driver' or 'Passenger'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.plateNumber,
    required this.userType,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      plateNumber: data['plateNumber'],
      userType: data['userType'] ?? 'Passenger',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'plateNumber': plateNumber,
      'userType': userType,
    };
  }
}

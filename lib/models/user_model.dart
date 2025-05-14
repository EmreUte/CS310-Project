class MyUser {
  final String uid;

  MyUser({required this.uid});
}

class UserModel {
  final String uid;
  final String userType; // 'Driver' or 'Passenger'

  final String name;
  final String email;
  final String phone;

  final String plateNumber;

  final int cardCount;
  final int cardID;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.plateNumber,
    required this.userType,
    required this.cardCount,
    required this.cardID,
  });
}

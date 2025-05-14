import '../digital_payments/components/credit_card.dart';

class MyUser {
  final String uid;

  MyUser({required this.uid});
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String plateNumber;
  final String userType; // 'Driver' or 'Passenger'
  final int cardCount;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.plateNumber,
    required this.userType,
    required this.cardCount,
  });
}

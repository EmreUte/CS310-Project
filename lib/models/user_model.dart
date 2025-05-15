import 'package:cloud_firestore/cloud_firestore.dart';

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

class RideRecord {
  final String id;
  final String date;
  final String time;
  final String pickup;
  final String dropoff;
  final String amount;

  RideRecord({
    required this.id,
    required this.date,
    required this.time,
    required this.pickup,
    required this.dropoff,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'time': time,
      'pickup': pickup,
      'dropoff': dropoff,
      'amount': amount,
    };
  }

  factory RideRecord.fromDocument(DocumentSnapshot doc) {
    return RideRecord(
      id: doc.id,
      date: doc['date'],
      time: doc['time'],
      pickup: doc['pickup'],
      dropoff: doc['dropoff'],
      amount: doc['amount'],
    );
  }
}

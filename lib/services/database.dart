import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/digital_payments/components/credit_card.dart';
import 'package:cs310_project/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

  final CollectionReference msgCollection = FirebaseFirestore.instance
      .collection('emails');

  Future sendMessage(String msg) async {
    try {
      // Create a new document in the 'emails' collection with a unique ID
      return await msgCollection.add({
        'uid': uid, // Store the user's UID
        'msg': msg, // Store the message
        'timestamp': FieldValue.serverTimestamp(), // Add a server-side timestamp
      });
    } catch (e) {
      print('Error logging message: $e');
      rethrow; // Rethrow to handle errors in the UI
    }
  }

  // Update user data in Firestore
  Future updateUserData(
    String name,
    String email,
    String phone,
    String plateNumber,
    String userType,
    int cardCount,
    int cardID,
    int historyId,
  ) async {
      return await userCollection.doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'plateNumber': plateNumber,
        'userType': userType,
        'cardCount': cardCount,
        'cardID': cardID,
        'historyId': historyId,
      });
  }

  // gift list from snapshot
  Future addCreditCard(CreditCard card) async {
    return await userCollection
        .doc(uid)
        .collection('payment_methods')
        .doc(card.id)
        .set(card.toMap());
  }
  Future removeCreditCard(String cardID) async {
      return await userCollection
          .doc(uid)
          .collection('payment_methods')
          .doc(cardID)
          .delete();
  }
  List<CreditCard> _cardListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return CreditCard(
        id: doc['id'],
        name: doc['name'],
        number: doc['number'],
        month: doc['month'],
        year: doc['year'],
        type: doc['type'],
      );
    }).toList();
  }
  // get cards stream
  Stream<List<CreditCard>> get cards {
    return userCollection
        .doc(uid)
        .collection('payment_methods')
        .snapshots()
        .map(_cardListFromSnapshot);
  }

  Future addRideRecord(RideRecord record) async {
    return await userCollection.doc(uid).collection('ride_history').add(record.toMap());
  }

  Future removeRideRecord(String rideId) async {
    return await userCollection.doc(uid).collection('ride_history').doc(rideId).delete();
  }

  List<RideRecord> _rideListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return RideRecord.fromDocument(doc);
    }).toList();
  }

  Stream<List<RideRecord>> get rideHistory {
    return userCollection.doc(uid).collection('ride_history').snapshots().map(_rideListFromSnapshot);
  }

  UserModel? _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(
        uid: uid,
        name: snapshot['name'],
        email: snapshot['email'],
        phone: snapshot['phone'],
        plateNumber: snapshot['plateNumber'],
        userType: snapshot['userType'],
        cardCount: snapshot['cardCount'],
        cardID: snapshot['cardID'],
        historyId: snapshot['historyId'],
    );
  }

  // get user doc stream
  Stream<UserModel?> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}

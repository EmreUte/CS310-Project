import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../maps/road_trip_map.dart';
import 'package:latlong2/latlong.dart';


class RideProgressPassenger extends StatefulWidget {
  @override
  _RideProgressPassengerState createState() => _RideProgressPassengerState();
}

class _RideProgressPassengerState extends State<RideProgressPassenger> {
  bool driverEndedRide = true; // Simulate being told driver ended ride
  bool paymentSuccess = false;
  bool hasPaymentMethod = true; // Simulate wallet check

  void handlePayment() {
    if (hasPaymentMethod) {
      setState(() => paymentSuccess = true);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Payment Successful"),
          content: const Text("Your ride has been paid successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/passenger_profile')),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No Payment Method"),
          content: const Text("Please add a payment method to your wallet."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/wallet'),
              child: const Text("Go to Wallet"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/passenger_profile')),
        ),
        title: Text("Ride Progress", style: kAppBarText),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300, // or whatever height you prefer
            child: const RoadTripMap(),
          ),

          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fillBox,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_taxi),
                    SizedBox(width: 8),
                    Text("Beyoğlu", style: kFillerText),
                    SizedBox(width: 8),
                    Icon(Icons.more_horiz),
                    SizedBox(width: 8),
                    Text("Fatih", style: kFillerText),
                  ],
                ),
                SizedBox(height: 8),
                Text("Amount: 300 ₺", style: kFillerText),
                SizedBox(height: 4),
                Text("Estimated Time Left: 24 minutes", style: kFillerTextSmall),
              ],
            ),
          ),
          const Spacer(),
          if (driverEndedRide && !paymentSuccess)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: handlePayment,
                child: Text("Make Payment", style: kButtonText),
              ),
            ),
        ],
      ),
    );
  }
}

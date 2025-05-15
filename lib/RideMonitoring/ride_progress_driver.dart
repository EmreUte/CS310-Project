import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../maps/road_trip_map.dart';


class RideProgressDriver extends StatefulWidget {
  @override
  _RideProgressDriverState createState() => _RideProgressDriverState();
}

class _RideProgressDriverState extends State<RideProgressDriver> {
  bool rideEnded = false;

  void handleEndRide() {
    setState(() => rideEnded = true);
    // trigger passenger's UI to enable payment
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Ride Progress", style: kAppBarText),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300, // or whatever height you prefer
            child: RoadTripMap(),

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
              children:  [
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
          if (!rideEnded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: handleEndRide,
                child: Text("End Ride", style: kButtonText),
              ),
            ),
          if (rideEnded)
             Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text("Waiting for passenger to make payment...", style: kFillerTextSmall),
            )
        ],
      ),
    );
  }
}

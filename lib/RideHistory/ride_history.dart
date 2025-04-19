import 'package:flutter/material.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

//Data model for ride record
class RideRecord {
  final String date;
  final String time;
  final String pickup;
  final String dropoff;
  final String amount;

  RideRecord({
    required this.date,
    required this.time,
    required this.pickup,
    required this.dropoff,
    required this.amount,
  });
}

//Reusable widget for each ride history block
class RideHistoryBlock extends StatelessWidget {
  final RideRecord record;
  final VoidCallback onDelete;
  final VoidCallback onRate;
  final VoidCallback onDetails;

  const RideHistoryBlock ({super.key,
    required this.record,
    required this.onDelete,
    required this.onRate,
    required this.onDetails,
  });

  @override
  Widget build (BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration (
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column (
        children: [
          // Date and Time Section
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 20),
                    SizedBox(width: 8.0),
                    Text(record.date, style: TextStyle(color: Colors.white)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 20),
                    SizedBox(width: 8.0),
                    Text(record.time, style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          // Ride Details Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car, size: 20),
                        SizedBox(width: 8.0),
                        Text(record.pickup),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 20),
                        SizedBox(width: 8.0),
                        Text(record.dropoff),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text('Amount: ${record.amount}'),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.star, size: 20),
                    onPressed: onRate,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                  ),
                  IconButton(
                    icon: Row(
                      children: [
                        Icon(Icons.arrow_forward, size: 20),
                        SizedBox(width: 4.0),
                        Text('for details', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    onPressed: onDetails,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// Main Ride History Page





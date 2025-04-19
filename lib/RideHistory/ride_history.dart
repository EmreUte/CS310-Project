import 'package:flutter/material.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import 'package:intl/intl.dart';

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
        color: Color(0x141D1B20),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column (
        children: [
          // Date and Time Section
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.buttonBackground,
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
class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key});

  @override
  RideHistoryPageState createState() => RideHistoryPageState();
}

class RideHistoryPageState extends State<RideHistoryPage> {
  List<RideRecord> rideRecords = [
    RideRecord(date: '10/05/2025', time: '14:28 - 15:17', pickup: 'Maltepe', dropoff: 'Tuzla', amount: '250 ₺'),
    RideRecord(date: '08/01/2025', time: '11:18 - 12:04', pickup: 'Kadıköy', dropoff: 'Kartal', amount: '350 ₺'),
    RideRecord(date: '24/11/2024', time: '18:40 - 19:25', pickup: 'Beyoğlu', dropoff: 'Fatih', amount: '300 ₺'),
    RideRecord(date: '13/07/2024', time: '21:24 - 23:33', pickup: 'Beşiktaş', dropoff: 'Karaköy', amount: '150 ₺'),
    RideRecord(date: '01/06/2024', time: '09:15 - 10:00', pickup: 'Şişli', dropoff: 'Levent', amount: '200 ₺'),
    RideRecord(date: '01/05/2024', time: '10:22 - 10:57', pickup: 'Şişhane', dropoff: 'Topkapı', amount: '220 ₺'),
  ];

  int currentPage = 1;
  final int recordsPerPage = 5;

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  void sortRecords(String option) {
    setState(() {
      if (option == 'Date Ascending') {
        rideRecords.sort((a, b) => dateFormat.parse(a.date).compareTo(dateFormat.parse(b.date)));
      } else if (option == 'Date Descending') {
        rideRecords.sort((a, b) => dateFormat.parse(b.date).compareTo(dateFormat.parse(a.date)));
      } else if (option == 'Amount Ascending') {
        rideRecords.sort((a, b) => double.parse(a.amount.split(' ')[0]).compareTo(double.parse(b.amount.split(' ')[0])));
      } else if (option == 'Amount Descending') {
        rideRecords.sort((a, b) => double.parse(b.amount.split(' ')[0]).compareTo(double.parse(a.amount.split(' ')[0])));
      }
    });
  }

  void deleteRecord(int index) {
    setState(() {
      rideRecords.removeAt(index);
    });
  }

  void showRatingPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate the Ride'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => Icon(Icons.star_border, color: Colors.amber)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void showDetailsPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ride Details'),
        content: Text('Details and driver info will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (rideRecords.length / recordsPerPage).ceil();
    List<RideRecord> currentRecords = rideRecords
        .skip((currentPage - 1) * recordsPerPage)
        .take(recordsPerPage)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () {
            Navigator.pop(context); // Back navigation
          },
        ),
        title: Text('Ride History', style: kAppBarText),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Action Buttons
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<String>(
                  onSelected: sortRecords,
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'Date Ascending', child: Text('Date Ascending')),
                    PopupMenuItem(value: 'Date Descending', child: Text('Date Descending')),
                    PopupMenuItem(value: 'Amount Ascending', child: Text('Amount Ascending')),
                    PopupMenuItem(value: 'Amount Descending', child: Text('Amount Descending')),
                  ],
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Color(0x141D1B20),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Text('Sort by', style: TextStyle(color: Colors.black)),
                        SizedBox(width: 4.0),
                        Icon(Icons.arrow_drop_down, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Placeholder for export functionality
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Color(0x141D1B20),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Text('Export', style: TextStyle(color: Colors.black)),
                        SizedBox(width: 4.0),
                        Icon(Icons.download, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Ride History List
          Expanded(
            child: ListView.builder(
              itemCount: currentRecords.length,
              itemBuilder: (context, index) {
                final record = currentRecords[index];
                return RideHistoryBlock(
                  record: record,
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Record'),
                        content: Text('Do you want to delete this record?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteRecord((currentPage - 1) * recordsPerPage + index);
                              Navigator.pop(context);
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onRate: showRatingPopup,
                  onDetails: showDetailsPopup,
                );
              },
            ),
          ),
          // Pagination Bar
          Container(
            color: AppColors.appBarBackground,
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, color: Colors.white),
                  onPressed: currentPage > 1
                      ? () {
                    setState(() {
                      currentPage--;
                    });
                  }
                      : null,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text('$currentPage'),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, color: Colors.white),
                  onPressed: currentPage < totalPages
                      ? () {
                    setState(() {
                      currentPage++;
                    });
                  }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';
import 'dart:convert';
// Firebase Imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';


class PassengerPreferencesScreen extends StatefulWidget
{
  const PassengerPreferencesScreen({super.key});

  @override
  State<PassengerPreferencesScreen> createState() => _PassengerPreferencesScreenState();
}





class _PassengerPreferencesScreenState extends State<PassengerPreferencesScreen>
{
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  String location = "";
  double? selectedLat;
  double? selectedLng;
  double? finalLat;
  double? finalLng;
  String luggageAmount = "";
  String tipAmount = "";
  String driverExperience = "";
  bool hasSubmitted = false;
  final List<String> genderPreference = ["Male","Female","None"];
  final List<String> smokingPreference = ["Non-Smoking","Smoking Allowed"];
  String selectedGender = "None";
  String selectedSmoking = "Non-Smoking";
  int? selectedRating; //null at first.
  bool isExpandedRating = false;
  bool isExpandedCarType = false;
  bool isExpanded = false;
  String? preferredCarType;
  List<String> carTypes = ["SUV","Sports","Convertible","Mini Van","Electric","Sedan"];

  Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query&countrycodes=tr'), // Turkey-only results
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((place) => {
        'display': place['display_name'],
        'lat': place['lat'],
        'lon': place['lon'],
      })
          .toList();
    }
    return [];
  }






  Future<void> _showDialog(String title, String message) async {
    bool isAndroid = Platform.isAndroid;
    return showDialog(context: context, builder: (BuildContext context) {
      if(isAndroid)
      {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            },child: Text("OK"))
          ],
        );
      }
      else
      {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () {
              Navigator.of(context).pop();
            },
                child: Text('OK'))
          ],

        );
      }
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text("Passenger Preferences", style: kAppBarText),
      automaticallyImplyLeading: false,
    ),
      body: SingleChildScrollView(child: Padding(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 80),
        child: Form(key: _formKey, child:
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Location", style: kFillerText),
                  SizedBox(height: 15),
                  FormField<String>(
                    validator: (value) {
                      if (_locationController.text.isEmpty) {
                        return 'Please enter your location';
                      }
                      return null;
                    },
                    builder: (FormFieldState<String> state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TypeAheadField<Map<String, dynamic>>(
                            suggestionsCallback: (pattern) async {
                              // Due to limitations.
                              await Future.delayed(Duration(seconds: 1));
                              return await searchAddress(pattern);
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion['display']),
                              );
                            },
                            onSelected: (suggestion) {
                              _locationController.text = suggestion['display'];
                              _formKey.currentState?.save();
                              state.didChange(_locationController.text); // Inform the form field
                              setState(() {
                                selectedLat = double.parse(suggestion['lat']);
                                selectedLng = double.parse(suggestion['lon']);
                              });
                            },
                            builder: (context, controller, focusNode) {
                              // Sync internal TypeAhead controller with your external controller
                              controller.text = _locationController.text;
                              controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: controller.text.length),
                              );
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.fillBox,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: Dimen.textboxPadding,
                                  labelText: 'Enter your current location',
                                  hintText: 'Ex: Orta Mahallesi, Üniversite Cd...',
                                  suffixIcon: Icon(Icons.search),
                                  errorText: state.errorText,
                                ),
                                onChanged: (value) {
                                  _locationController.text = value;
                                  state.didChange(value); // Trigger validation updates
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                    onSaved: (value) {
                      finalLat = selectedLat;
                      finalLng = selectedLng;
                    },
                  ),
                  SizedBox(height: 25,),
                  Text("Lüggage", style: kFillerText),
                  SizedBox(height: 5),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.fillBox,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: Dimen.textboxPadding,
                    ),
                    validator: (value) {
                      if (value != null) {
                        if (value.isEmpty) {
                          return "Please enter the amount of your luggage";
                        }
                      }
                      return null;
                    },
                    onSaved: (value) {
                      luggageAmount = value ?? '';
                    },
                  ),
                ],
              ),
              SizedBox(height: 15),
              Center(
                  child: Text("Driver Gender Preference",style: kFillerText)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: genderPreference.map<Widget>((option) {
                  return Padding(padding: const EdgeInsets.symmetric(horizontal: 17.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Radio<String>(
                          value: option,
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          }
                      ),
                        Text(option),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 15),
              Center(
                  child: Text("Rating",style: kFillerText)),
              Padding(
                padding: Dimen.textboxPadding,
                child: FormField<int>
                  (
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option';
                      }
                      return null;
                    },
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              errorText: field.errorText,
                            ),
                            child: ExpansionTile(
                              title:
                              Center(
                                child: Text(
                                  selectedRating == null
                                      ? "Select Rating(1 to 5)"
                                      : "Selected Rating: $selectedRating ⭐",
                                ),
                              ),
                              collapsedBackgroundColor: AppColors.fillBox,
                              backgroundColor: AppColors.fillBox,
                              collapsedShape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              onExpansionChanged: (bool expand) {
                                setState(() {
                                  //isExpandedRating = expand;
                                  isExpanded = expand;
                                });
                              },
                              children: List.generate(5, (index) {
                                int rating = index + 1;
                                return RadioListTile<int>(
                                  title: Text("$rating ⭐"),
                                  value: rating,
                                  groupValue: selectedRating,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedRating = value;
                                      field.didChange(value);
                                    });
                                    setState(() {
                                      //isExpandedRating = false;
                                      isExpanded = false;
                                    });
                                  },
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: 15),
                          Center(
                              child: Text(
                                  "Tip Amount - In TRY", style: kFillerText)),
                          SizedBox(height: 5),
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.fillBox,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: Dimen.textboxPadding,
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return "Please enter an amount";
                                }
                                else if (int.tryParse(value) == null) {
                                  return "Please enter a valid integer as value";
                                }
                                else if (int.tryParse(value) ! < 0) {
                                  return "Please enter a non-negative integer value.";
                                }
                              }
                              return null;
                            },
                            onSaved: (value) {
                              tipAmount = value ?? '';
                            },
                          ),
                          SizedBox(height: 15),
                          Center(
                              child: Text("Driver Experience - In Years", style: kFillerText)),
                          SizedBox(height: 5),
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.fillBox,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: Dimen.textboxPadding,
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return "Please enter a number";
                                }
                                else if (int.tryParse(value) == null) {
                                  return "Please enter a valid integer as driver experience";
                                }
                                else if (int.tryParse(value) ! < 0 &&
                                    int.tryParse(value) ! > 70) {
                                  return "Please enter a plausible driver experience";
                                }
                              }
                              return null;
                            },
                            onSaved: (value) {
                              driverExperience = value ?? '';
                            },
                          ),
                          SizedBox(height: 15),
                          Center(
                              child: Text("Smoking Preference", style: kFillerText)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: smokingPreference.map<Widget>((option) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Radio<String>(
                                      value: option,
                                      groupValue: selectedSmoking,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSmoking = value!;
                                        });
                                      }
                                  ),
                                    Text(option),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 15),
                          Center(
                              child: Text("Car Type Preference", style: kFillerText)),
                          Padding(
                            padding: Dimen.textboxPadding,
                            child: FormField<String>(
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select an option';
                                }
                                return null;
                              },
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        errorText: field.errorText,
                                      ),
                                      child:ExpansionTile(
                                        title:
                                        Center(child: Text(
                                          preferredCarType == null
                                              ? "Select Car Type"
                                              : "$preferredCarType",
                                        ),

                                        ),
                                        collapsedBackgroundColor: AppColors.fillBox,
                                        backgroundColor: AppColors.fillBox,
                                        collapsedShape: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        shape: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        onExpansionChanged: (bool expand) {
                                          setState(() {
                                            //isExpandedCarType = expand;
                                            isExpanded = expand;
                                          });
                                        },
                                        children: carTypes.map((element) {
                                          return RadioListTile<String>(
                                            title: Text(element),
                                            value: element,
                                            groupValue: preferredCarType,
                                            onChanged: (value) {
                                              setState(() {
                                                preferredCarType = value;
                                                field.didChange(value);
                                              });
                                              setState(() {
                                                //isExpandedCarType = false;
                                                isExpanded = false;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: 222,
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    hasSubmitted =
                                    true; // Set flag when button is clicked
                                  });
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Processing Data')),
                                    );
                                    _formKey.currentState!.save();

                                    try {
                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user == null) throw Exception('User not authenticated');
                                      await FirebaseFirestore.instance
                                          .collection('Passenger_Preferences')
                                          .doc(user.uid)
                                          .set({
                                        'latitude': finalLat,
                                        'longitude': finalLng,
                                        'luggage': luggageAmount,
                                        'gender_preference': selectedGender,
                                        'rating': selectedRating,
                                        'tip': tipAmount,
                                        'requested_driver_exp': driverExperience,
                                        'smoking_preference': selectedSmoking,
                                        'car_type': preferredCarType});

                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Preferences saved successfully!')),);

                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to save: ${e.toString()}')),
                                      );
                                    }

                                  } else {
                                    String errorMessage = 'Try again with valid entries';
                                    _showDialog('Form Error', errorMessage);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttonBackground,
                                  padding: Dimen.buttonPadding,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Text(
                                  'Save Preferences',
                                  style: kButtonText,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(child: Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10))),
                        ],
                      );
                    }),
              ),
            ]),
        ),
      ),
      ),
    );
  }








}
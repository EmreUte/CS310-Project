import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';


class PassengerPreferencesScreen extends StatefulWidget
{
  const PassengerPreferencesScreen({super.key});

  @override
  State<PassengerPreferencesScreen> createState() => _PassengerPreferencesScreenState();
}

class _PassengerPreferencesScreenState extends State<PassengerPreferencesScreen>
{
  final _formKey = GlobalKey<FormState>();
  String location = "";
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
                          return "Please enter your location";
                        }
                      }
                      return null;
                    },
                    onSaved: (value) {
                      location = value ?? '';
                    },
                  ),
                  SizedBox(height: 25,),
                  Text("Luggage", style: kFillerText),
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
                                onPressed: () {
                                  setState(() {
                                    hasSubmitted =
                                    true; // Set flag when button is clicked
                                  });
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Processing Data')),
                                    );
                                    _formKey.currentState!.save();
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
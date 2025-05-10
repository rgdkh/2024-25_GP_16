import 'dart:io';

import 'package:awj/src/features/BrowseTrails.dart';
import 'package:awj/src/features/authentication/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

class ReviewDetailsPage extends StatefulWidget {
  final String trailId;

  ReviewDetailsPage({required this.trailId});

  @override
  _ReviewDetailsPageState createState() => _ReviewDetailsPageState();
}

class _ReviewDetailsPageState extends State<ReviewDetailsPage> {
  
  // Rating variables
  double overallAverageRating = 0.0;
  int numberOfRatings = 0;
  double userDifficultyRating = 0.0;
  double userConditionRating = 0.0;
  double userAmenitiesRating = 0.0;
  List<double> difficultyRatings = [];
  List<double> conditionRatings = [];
  List<double> amenitiesRatings = [];
bool isFavorited = false;
 List<XFile> selectedImages = [];
 String selectedCondition = '';

  final TextEditingController reviewController = TextEditingController();
  String? uploadedPhotoPath;
 String selectedContentType = 'All'; // Filter: All, Photo, Text
  String selectedSortOrder = 'Most Recent'; 
  Stream<QuerySnapshot> reviewsStream = FirebaseFirestore.instance
      .collection('trails')
      .doc("trailId") // Replace with the actual trailId
      .collection('reviews')
      .orderBy('createdAt', descending: true)
      .snapshots();

       // Open filter modal
  void _openFilterDialog() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEAE7D8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filter & Sort Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter by Content Type
                    buildFilterOption(
                      'Review Type',
                      selectedContentType,
                      ['All', 'With Photos', 'With Comment'],
                      (value) {
                        setModalState(() => selectedContentType = value);
                      },
                    ),

                    // Sort by Order
                    buildFilterOption(
                      'Sort By',
                      selectedSortOrder,
                      [
                        'Most Recent',
                        'Least Recent',
                        'Most Helpful',
                        'Highest Rating',
                        'Lowest Rating'
                      ],
                      (value) {
                        setModalState(() => selectedSortOrder = value);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Apply Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {}); // Apply filters and sorting
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A3A26),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(color: Color(0xFFEAE7D8)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}


  Widget buildFilterOption(String title, String currentValue, List<String> options, Function(String) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(title, style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          flex: 3,
          child: DropdownButton<String>(
            value: currentValue,
            onChanged: (String? newValue) {
              if (newValue != null) onChanged(newValue);
            },
            isExpanded: true,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

 Future<bool> hasUserReported(String trailId, String reviewId) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return false;

  QuerySnapshot reportSnapshot = await FirebaseFirestore.instance
      .collection('trails')
      .doc(trailId)
      .collection('reviews')
      .doc(reviewId)
      .collection('reported_reviews')
      .where('reportedBy', isEqualTo: currentUser.uid)
      .get();

  print("Report exists for user: ${reportSnapshot.docs.isNotEmpty}");
  return reportSnapshot.docs.isNotEmpty;
}

void _showAlreadyReportedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEAE7D8),
        title: const Text(
          "Feedback Recorded",
        ),
        content: const Text(
          "You have already reported this review. Thank you for your feedback.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF2A3A26)),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    
      if (_showDialog) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showDialog = false; // Reset the state
      });
      _showThankYouDialog(context); // Show the dialog
    });
  }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () {
    Navigator.pop(context, true); 
  },
),
   title: const Text(
          "Trail Reviews",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
         actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _openFilterDialog,
          ),
        ],
         iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
       backgroundColor: Color(0xFFEAE7D8), 


       
      body: StreamBuilder<QuerySnapshot>(
        
        stream: FirebaseFirestore.instance
            .collection('trails')
            .doc(widget.trailId) // Use widget.trailId to access the trailId
            .collection('reviews')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading reviews."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No reviews yet."));
          }

        // Get all reviews
    List<DocumentSnapshot> reviews = snapshot.data!.docs;

    // Get the current user's ID
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

   // Separate the user's review
DocumentSnapshot? userReview;
List<DocumentSnapshot> otherReviews = [];

// Use 'reviews' instead of 'sortedReviews'
for (var doc in reviews) {
  var reviewData = doc.data() as Map<String, dynamic>;
  if (reviewData['userId'] == currentUserId) {
    userReview = doc; // Identify the user's review
  } else {
    otherReviews.add(doc); // Collect other reviews
  }
}

// Apply sorting to other reviews
otherReviews.sort((a, b) {
  var reviewA = a.data() as Map<String, dynamic>;
  var reviewB = b.data() as Map<String, dynamic>;

  if (selectedSortOrder == 'Most Recent') {
    return reviewB['createdAt'].compareTo(reviewA['createdAt']);
  } else if (selectedSortOrder == 'Least Recent') {
    return reviewA['createdAt'].compareTo(reviewB['createdAt']);
  } else if (selectedSortOrder == 'Most Helpful') {
    return (reviewB['helpfulCount'] ?? 0).compareTo(reviewA['helpfulCount'] ?? 0);
  } else if (selectedSortOrder == 'Highest Rating') {
    return (reviewB['difficultyRating'] + reviewB['conditionRating'] + reviewB['amenitiesRating'])
        .compareTo(reviewA['difficultyRating'] + reviewA['conditionRating'] + reviewA['amenitiesRating']);
  } else if (selectedSortOrder == 'Lowest Rating') {
    return (reviewA['difficultyRating'] + reviewA['conditionRating'] + reviewA['amenitiesRating'])
        .compareTo(reviewB['difficultyRating'] + reviewB['conditionRating'] + reviewB['amenitiesRating']);
  }

  return 0;
});


// Apply content filter to other reviews
if (selectedContentType == 'With Photos') {
    otherReviews = otherReviews.where((doc) {
        var reviewData = doc.data() as Map<String, dynamic>;
        return reviewData['photoUrls'] != null && (reviewData['photoUrls'] as List).isNotEmpty;
    }).toList();
} else if (selectedContentType == 'With Comment') {
    otherReviews = otherReviews.where((doc) {
        var reviewData = doc.data() as Map<String, dynamic>;
        return reviewData['reviewText']?.isNotEmpty ?? false;
    }).toList();
}


// Combine the user's review with the sorted and filtered other reviews
List<DocumentSnapshot> finalReviews = [];
if (userReview != null) {
  finalReviews.add(userReview); // Add user's review at the top
}
finalReviews.addAll(otherReviews); // Append the filtered and sorted other reviews

  
    



          return ListView.builder(
           itemCount: finalReviews.length,
            itemBuilder: (context, index) {
            var review = finalReviews[index];
              var reviewData = review.data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(reviewData['userId'])
                    .get(),
                builder: (context, userSnapshot) {
                  
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        child: Container(
                          height: 150,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 20,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                height: 15,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: 150,
                                height: 15,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return Text("Error loading user data.");
                  }

                  var user = userSnapshot.data!.data() as Map<String, dynamic>?;
                  String username = user?['name'] ?? 'Unknown User';
                  String? userIcon = user?['icon'];

                  IconData? iconData;
                  if (userIcon != null) {
                    iconData = IconData(
                      int.parse(userIcon),
                      fontFamily: 'MaterialIcons',
                    );
                  }
IconData getIconData(String? iconCode, {IconData fallbackIcon = Icons.home}) {
  try {
    return IconData(
      int.parse(iconCode!),
      fontFamily: 'MaterialIcons',
    );
  } catch (e) {
    print('Invalid icon code: $iconCode');
    return fallbackIcon;
  }
}

// Show a dialog for guest users
void _showLoginDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        title: Text("Login Required"),
        content: Text("You need to login or sign up to report a review."),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
          ),
          TextButton(
            child: Text('Login'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
          ),
        ],
      );
    },
  );
}

                  return Card(
                    
  margin: EdgeInsets.all(10),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  elevation: 5,
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Information Section
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2),
             
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(255, 230, 231, 230),
                child: iconData != null
                    ? Icon(iconData, size: 40, color: Colors.black)
                    : Icon(Icons.account_circle, size: 40, color: Colors.black),
              ),
            ),
            SizedBox(width: 10),
            Text(
              username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Ratings Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty Rating
    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Difficulty:",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    Text(
      "${reviewData['difficultyRating'] ?? 0.0} / 5",
      style: TextStyle(fontSize: 14),
    ),
  ],
),
SizedBox(height: 8),
LinearProgressIndicator(
  value: (reviewData['difficultyRating'] ?? 0.0) / 5,
  backgroundColor: Colors.grey[300],
  color: Colors.amber,
  minHeight: 6, // Reduced height for a smaller bar
),
            SizedBox(height: 8),

         Row(
  children: [
    Text(
      "Condition:",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    SizedBox(width: 8),
    Expanded(
      child: Builder(
        builder: (context) {
          try {
            if (reviewData['conditionRating'] != null &&
                reviewData['conditionRating'] >= 1 &&
                reviewData['conditionRating'] <= conditionOptions.length) {
              // Safely access conditionOptions
              return Text(
                conditionOptions[reviewData['conditionRating'].toInt() - 1],
                style: TextStyle(fontSize: 14, color: Colors.black87),
              );
            } else {
              return Text(
                "Not Rated",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              );
            }
          } catch (e) {
            // Catch the exception and log it
            print("Error in conditionRating: $e");
            return Text(
              "Invalid Rating",
              style: TextStyle(fontSize: 14, color: Colors.red),
            );
          }
        },
      ),
    ),
  ],
),

            SizedBox(height: 8),

            // Amenities Rating
           Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Facilities:",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    Text(
      "${reviewData['amenitiesRating'] ?? 0.0} / 5",
      style: TextStyle(fontSize: 14),
    ),
  ],
),
SizedBox(height: 8),
LinearProgressIndicator(
  value: (reviewData['amenitiesRating'] ?? 0.0) / 5,
  backgroundColor: Colors.grey[300],
  color: Colors.amber,
  minHeight: 6, // Reduced height for a smaller bar
),
          ],
          
        ),
        SizedBox(height: 12),

        
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
                Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (reviewData['reviewText'] != null && reviewData['reviewText'].trim().isNotEmpty) ...[
      Text(
        "Review Comment", // Add a title above the comment box
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 8), // Add some spacing between the title and the box
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          reviewData['reviewText']!,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  ],
  ),
              SizedBox(height: 8),

              // Photo Section
              if (reviewData['photoUrls'] != null &&
                  (reviewData['photoUrls'] as List).isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List<Widget>.from(
                    (reviewData['photoUrls'] as List<dynamic>).map(
                      (url) => GestureDetector(
                        onTap: () {
                          _showFullImageCarousel(
                              context,
                              reviewData['photoUrls'],
                              reviewData['photoUrls'].indexOf(url));
                        },
                        child: Image.network(
                          url,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 12),

              
            ],
          ),
          
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Date Section
      Text(
        "Created At: ${reviewData['createdAt']?.toDate()?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),

      // Helpful Section
      Row(
        children: [
          Text(
            "Helpful?",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          SizedBox(width: 8),
          Text(
            "(${reviewData['helpfulCount'] ?? 0})",
            style: TextStyle(fontSize: 14),
          ),
             // Only show the helpful button if the review is not authored by the current user
          if (FirebaseAuth.instance.currentUser?.uid != reviewData['userId'])
          IconButton(
            icon: Icon(
              Icons.thumb_up,
              color: (reviewData['helpfulBy'] != null &&
                      reviewData['helpfulBy'].contains(
                          FirebaseAuth.instance.currentUser?.uid))
                  ? Colors.green
                  : Colors.grey,
            ),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                _showLoginDialog();
              } else {
                // Check if already clicked
                if (reviewData['helpfulBy'] != null &&
                    reviewData['helpfulBy'].contains(
                        FirebaseAuth.instance.currentUser?.uid)) {
                  // Undo "Helpful" click
                  FirebaseFirestore.instance
                      .collection('trails')
                      .doc(widget.trailId)
                      .collection('reviews')
                      .doc(review.id)
                      .update({
                    'helpfulBy': FieldValue.arrayRemove(
                        [FirebaseAuth.instance.currentUser?.uid]),
                    'helpfulCount': FieldValue.increment(-1),
                  });
                } else {
                  // Mark as "Helpful"
                  FirebaseFirestore.instance
                      .collection('trails')
                      .doc(widget.trailId)
                      .collection('reviews')
                      .doc(review.id)
                      .update({
                    'helpfulBy': FieldValue.arrayUnion(
                        [FirebaseAuth.instance.currentUser?.uid]),
                    'helpfulCount': FieldValue.increment(1),
                  });
                }
              }
            },
          ),
          // Report Flag
        IconButton(
  icon: FutureBuilder<bool>(
    future: hasUserReported(widget.trailId, review.id),
    builder: (context, snapshot) {
      // Determine if the current review belongs to the logged-in user
      bool isUserReview = FirebaseAuth.instance.currentUser?.uid == reviewData['userId'];

     if (isUserReview) {
  // Show edit and delete buttons for user's own review
  return Row(
    children: [
      IconButton(
        icon: Icon(Icons.edit, color: Colors.blue),
        onPressed: () {
          _showRatingDialog(
            reviewData: reviewData, // Pass existing review data
            reviewId: review.id,   // Pass review ID for updates
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          _confirmDelete(context, widget.trailId, review.id); // Confirm before deletion
        },
      ),
    ],
  );
}


      if (snapshot.connectionState == ConnectionState.waiting) {
        return Icon(Icons.flag, color: Colors.grey);
      }

      if (snapshot.hasError) {
        return Icon(Icons.flag, color: Colors.grey); // Handle errors gracefully
      }

      // Show flag button for reviews not authored by the user
      return Icon(
        Icons.flag,
        color: snapshot.data == true ? Colors.red : Colors.grey,
      );
    },
  ),
  onPressed: () async {
    bool isUserReview = FirebaseAuth.instance.currentUser?.uid == reviewData['userId'];

    if (isUserReview) {
      // Open the edit dialog if it's the user's own review
      _showRatingDialog(
        reviewData: reviewData, // Pass existing review data
        reviewId: review.id, // Pass review ID for updates
      );
    } else {
      // Handle reporting functionality for non-user reviews
      if (FirebaseAuth.instance.currentUser == null) {
        _showLoginDialog();
      } else {
        bool alreadyReported = await hasUserReported(widget.trailId, review.id);
        if (alreadyReported) {
          _showAlreadyReportedDialog(context);
        } else {
          _showReportDialog(context, widget.trailId, review.id);
        }
      }
    }
  },
),

        ],
      ),


    ],
  )


      ],
    ),
  ),
);


                },
              );
            },
          );
        },
      ),
    );
  }
  

// Define the condition options
final List<String> conditionOptions = [
   'Very Poor (Inaccessible)',
   'Poor (Difficult to Navigate)',
   'Fair (Needs Improvement)',
   'Good (Minor Issues)',
  'Excellent (Well-maintained)',
];

  void _showFullImageCarousel(BuildContext context, List<dynamic> imageUrls, int initialIndex) {
    int _currentIndex = initialIndex;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.7),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                alignment: Alignment.center,
                children: [
                 Center(
  child: Container(
    width: double.infinity,
    height: double.infinity,
    child: displayImage(imageUrls[_currentIndex]),
  ),
),

                  Positioned(
                    top: 40,
                    right: 30,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  if (imageUrls.length > 1 && _currentIndex > 0)
                    Positioned(
                      left: 10,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: 50),
                        onPressed: () {
                          setState(() {
                            _currentIndex = (_currentIndex - 1).clamp(0, imageUrls.length - 1);
                          });
                        },
                      ),
                    ),
                  if (imageUrls.length > 1 && _currentIndex < imageUrls.length - 1)
                    Positioned(
                      right: 10,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.white, size: 50),
                        onPressed: () {
                          setState(() {
                            _currentIndex = (_currentIndex + 1).clamp(0, imageUrls.length - 1);
                          });
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
Widget displayImage(String path) {
  if (path.startsWith('http')) {
    return Image.network(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Text('Failed to load image')),
    );
  } else {
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Text('Failed to load image')),
    );
  }
}

 void _showReportDialog(BuildContext context, String trailDocId, String reviewDocId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        title: Text("Report Review"),
        content: Text("Are you sure you want to report this review?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
             style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
          ),
          TextButton(
             style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
            child: Text("Proceed to Report"),
            onPressed: () {
              Navigator.of(context).pop();
              _showReasonSelectionDialog(context, trailDocId, reviewDocId);
            },
          ),
        ],
      );
    },
  );
}



  void _showReasonSelectionDialog(BuildContext context, String trailDocId, String reviewDocId) {
  showDialog(
    context: context,
    builder: (context) {
      String? selectedReason;
      TextEditingController otherReasonController = TextEditingController();

      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        title: Text("Select a Reason for Reporting"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  
                  hint: Text("Select Reason"),
                  value: selectedReason,
                  items: [
                    DropdownMenuItem(
                      value: "Inappropriate Content",
                      child: Text("Inappropriate Content"),
                    ),
                    DropdownMenuItem(
                      value: "Spam",
                      child: Text("Spam"),
                    ),
                    DropdownMenuItem(
                      value: "Misleading or False Information",
                      child: Text("Misleading or False Information"),
                    ),
                    DropdownMenuItem(
                      value: "Other",
                      child: Text("Other"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                ),
                if (selectedReason == "Other")
                  TextField(
                    controller: otherReasonController,
                    decoration: InputDecoration(hintText: "Enter your reason"),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
             style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
             style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
            child: Text("Submit"),
            onPressed: () {
              Navigator.of(context).pop();
              String reportReason = selectedReason == "Other"
                  ? otherReasonController.text
                  : selectedReason ?? "No Reason Provided";
              _submitReport(context, trailDocId, reviewDocId, reportReason);
            },
          ),
        ],
      );
    },
  );
}

void _showThankYouDialog(BuildContext context) {
   print("Thank You Dialog triggered"); // Add this to debug
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEAE7D8),
        title: const Text(
          "Thank You!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Our team will review this content soon.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF2A3A26)),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
bool _showDialog = false;

void _submitReport(BuildContext context, String trailDocId, String reviewDocId, String reason) {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please log in to report this review.")),
    );
    return;
  }

  String currentUserId = user.uid;

  FirebaseFirestore.instance
      .collection('trails')
      .doc(trailDocId)
      .collection('reviews')
      .doc(reviewDocId)
      .collection('reported_reviews')
      .add({
    'reviewId': reviewDocId,
    'reportedBy': currentUserId,
    'reason': reason,
    'timestamp': FieldValue.serverTimestamp(),
  }).then((_) {
    FirebaseFirestore.instance
        .collection('trails')
        .doc(trailDocId)
        .collection('reviews')
        .doc(reviewDocId)
        .update({
          'reportCount': FieldValue.increment(1),
        })
        .then((_) {
      print("Report count updated successfully.");

      // Update the state to show the Thank You dialog
      setState(() {
        _showDialog = true;
      });
    }).catchError((error) {
      print("Failed to update report count: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update report count. Please try again.")),
      );
    });
  }).catchError((error) {
    print("Failed to submit report: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to submit report. Please try again.")),
    );
  });
}

void _showRatingDialog({Map<String, dynamic>? reviewData, String? reviewId}) {
  // Populate pre-filled data
  if (reviewData != null) {
    userDifficultyRating = reviewData['difficultyRating']?.toDouble() ?? 0.0;
    userAmenitiesRating = reviewData['amenitiesRating']?.toDouble() ?? 0.0;
    userConditionRating = reviewData['conditionRating']?.toDouble() ?? 0.0;
    reviewController.text = reviewData['reviewText'] ?? '';
    List<String> imageUrls = List<String>.from(reviewData['photoUrls'] ?? []);

  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFEAE7D8),
            title: Text(
              reviewId == null ? "Add Your Review" : "Edit Your Review",
              style: const TextStyle(color: Color(0xFF2A3A26)),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Inputs (Difficulty, Condition, Facilities)
                  _buildUserRatingInputs(setState),
                  const SizedBox(height: 16),

                  // Add Review Section
                  const Text(
                    "Add Review (Optional)",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add Photo Section
                  Row(
                    children: [
                      const Text(
                        "Add Photo (Optional)",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo, color: Color(0xFF2A3A26)),
                        onPressed: () async {
                          await _pickImages(); // Trigger image selection
                          setState(() {}); // Update state with new images
                        },
                      ),
                    ],
                  ),

                  // Display Selected Photos
                  if (selectedImages.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "Photos Selected:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3A26),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedImages.map((image) {
                            // Check if the path is a Firestore URL or local file
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: image.path.startsWith("http")
                                      ?  Image.file(
                                    File(image.path),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.broken_image, color: Colors.red);
                                          },
                                        )
                                      : Image.file(
                                          File(image.path),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImages.remove(image); // Remove specific image
                                      });
                                    },
                                    child: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  else
                    const Center(
                      child: Text(
                        "No photo selected",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),

            // Dialog Actions
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A26),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              TextButton(
                child: Text(reviewId == null ? 'Submit' : 'Update'),
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Submit or Update Review
                  if (reviewId == null) {
                    _submitReview(
                      difficultyRating: userDifficultyRating,
                      amenitiesRating: userAmenitiesRating,
                      conditionRating: userConditionRating,
                      reviewText: reviewController.text,
                      photoUrls: selectedImages,
                    );
                  } else {
                    _updateReview(
                      reviewId,
                      {
                        'difficultyRating': userDifficultyRating,
                        'amenitiesRating': userAmenitiesRating,
                        'conditionRating': userConditionRating,
                        'reviewText': reviewController.text,
                        'photoUrls': selectedImages.map((img) => img.path).toList(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      },
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A26),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}





void _submitReview({
  required double difficultyRating,
  required double amenitiesRating,
  required double conditionRating,
  required String reviewText,
  required List<XFile> photoUrls,
}) async {
  List<String> uploadedUrls = [];

  // Upload selected images to Firebase Storage
  for (var image in photoUrls) {
    String? photoUrl = await _uploadImage(image);
    if (photoUrl != null) {
      uploadedUrls.add(photoUrl);
    }
  }

  // Save review to Firestore
  FirebaseFirestore.instance.collection('trails').doc(widget.trailId).collection('reviews').add({
    'difficultyRating': difficultyRating,
    'amenitiesRating': amenitiesRating,
    'conditionRating': conditionRating,
    'reviewText': reviewText,
    'photoUrls': uploadedUrls,
    'createdAt': FieldValue.serverTimestamp(),
    'userId': FirebaseAuth.instance.currentUser?.uid,
  }).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully!")),
    );
    setState(() {
      selectedImages.clear();
    });
  }).catchError((error) {
    print("Error submitting review: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to submit review. Please try again.")),
    );
  });
}
// List of selected images
 
  final ImagePicker _picker = ImagePicker();

  // Pick multiple images
  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null && pickedImages.isNotEmpty) {
        setState(() {
          selectedImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }
  
  Future<String?> _uploadImage(XFile image) async {
  try {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('trail_reviews/$fileName');
    UploadTask uploadTask = storageRef.putFile(File(image.path));

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}

Widget _buildConditionOptions(Function(void Function()) setDialogState) {
  List<String> conditionOptions = [
    'Excellent (Well-maintained)', // 5
    'Good (Minor Issues)',                 // 4
    'Fair (Needs Improvement)',            // 3
    'Poor (Difficult to Navigate)',        // 2
    'Very Poor (Inaccessible)',  // 1
  ];

  return Wrap(
    spacing: 8,
    children: conditionOptions.asMap().entries.map((entry) {
      final int index = conditionOptions.length - entry.key; // Reverse index

      return ChoiceChip(
        label: Text(entry.value),
        selected: userConditionRating == index.toDouble(),
        onSelected: (isSelected) {
          setDialogState(() {
            userConditionRating = isSelected ? index.toDouble() : 0.0;
            print("Selected Condition: $userConditionRating"); // Debugging
          });
        },
        selectedColor: const Color(0xFF2A3A26),
        backgroundColor: Colors.grey[300],
        labelStyle: TextStyle(
          color: userConditionRating == index.toDouble()
              ? Colors.white
              : const Color(0xFF2A3A26),
        ),
      );
    }).toList(),
  );
}







 Widget buildUserRatingBar(double userRating, Function(double) onRatingUpdate) {
    return RatingBar.builder(
      initialRating: userRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
      onRatingUpdate: onRatingUpdate,
    );
  }
Widget _buildUserRatingInputs(Function(void Function()) setDialogState) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Difficulty Section
      Row(
        children: [
          const Text(
            'Difficulty ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
          ),
          Spacer(),
        ],
      ),
      const SizedBox(height: 8),
      RatingBar.builder(
        initialRating: userDifficultyRating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
        onRatingUpdate: (rating) {
          setDialogState(() {
            userDifficultyRating = rating;
          });
        },
      ),
      const SizedBox(height: 16),

      // Condition Section
      Row(
        children: [
          const Text(
            'Condition ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
          ),
          Spacer(),
        ],
      ),
      const SizedBox(height: 8),
      _buildConditionOptions(setDialogState), // Updated condition selector
      const SizedBox(height: 16),

      // Facilities Section
      Row(
        children: [
          const Text(
            'Facilities ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
          ),
          Spacer(),
        ],
      ),
      const SizedBox(height: 8),
      RatingBar.builder(
        initialRating: userAmenitiesRating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
        onRatingUpdate: (rating) {
          setDialogState(() {
            userAmenitiesRating = rating;
          });
        },
      ),
    ],
  );
}
void _updateReview(String reviewId, Map<String, dynamic> updatedData) async {
  try {
    // Upload newly selected images to Firebase Storage
    List<String> uploadedUrls = [];
    for (var image in selectedImages) {
      String? photoUrl = await _uploadImage(image);
      if (photoUrl != null) {
        uploadedUrls.add(photoUrl);
      }
    }

    // Add uploaded image URLs to the updated data
    updatedData['photoUrls'] = uploadedUrls;

    // Update the specific review in Firestore
    await FirebaseFirestore.instance
        .collection('trails')
        .doc(widget.trailId)
        .collection('reviews')
        .doc(reviewId)
        .update(updatedData);

    // Fetch all reviews for the trail to recalculate averages
    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('trails')
        .doc(widget.trailId)
        .collection('reviews')
        .get();

    // Initialize accumulators for averages
    double totalDifficulty = 0.0;
    double totalCondition = 0.0;
    double totalAmenities = 0.0;
    int reviewCount = reviewsSnapshot.docs.length;

    // Calculate new averages based on all reviews
    for (var doc in reviewsSnapshot.docs) {
      Map<String, dynamic> review = doc.data() as Map<String, dynamic>;
      totalDifficulty += (review['difficultyRating'] ?? 0.0) as double;
      totalCondition += (review['conditionRating'] ?? 0.0) as double;
      totalAmenities += (review['amenitiesRating'] ?? 0.0) as double;
    }

    // Calculate averages
    double averageDifficulty = reviewCount > 0 ? totalDifficulty / reviewCount : 0.0;
    double averageCondition = reviewCount > 0 ? totalCondition / reviewCount : 0.0;
    double averageAmenities = reviewCount > 0 ? totalAmenities / reviewCount : 0.0;

    // Update the trail document with recalculated arrays and number of ratings
    await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).update({
      'ratings': reviewsSnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['difficultyRating'] ?? 0.0).toList(),
      'trailConditionRatings': reviewsSnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['conditionRating'] ?? 0.0).toList(),
      'amenitiesRatings': reviewsSnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['amenitiesRating'] ?? 0.0).toList(),
      'numberOfRatings': reviewCount,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review updated successfully!")),
    );

    // Update the local state to reflect changes
    setState(() {
      userConditionRating = updatedData['conditionRating']?.toDouble() ?? 0.0;
      userAmenitiesRating = updatedData['amenitiesRating']?.toDouble() ?? 0.0;

      // Calculate overall average (optional, for local UI display)
      double overallAverageRating =
          (averageDifficulty + averageCondition + averageAmenities) / 3;

      // Use the calculated averages to update the UI dynamically
      overallAverageRating = overallAverageRating;
    });
  } catch (error) {
    print("Error updating review: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to update review. Please try again.")),
    );
  }
}

void _deleteReview(String trailId, String reviewId) async {
  try {
    // Get the review to delete
    DocumentSnapshot reviewDoc = await FirebaseFirestore.instance
        .collection('trails')
        .doc(trailId)
        .collection('reviews')
        .doc(reviewId)
        .get();

    if (!reviewDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review not found.")),
      );
      return;
    }

    // Parse the review data
    Map<String, dynamic> reviewData = reviewDoc.data() as Map<String, dynamic>;
    double difficultyRating = reviewData['difficultyRating'] ?? 0.0;
    double conditionRating = reviewData['conditionRating'] ?? 0.0;
    double amenitiesRating = reviewData['amenitiesRating'] ?? 0.0;

    // Delete the review document
    await FirebaseFirestore.instance
        .collection('trails')
        .doc(trailId)
        .collection('reviews')
        .doc(reviewId)
        .delete();

    // Fetch the trail document
    DocumentSnapshot trailDoc = await FirebaseFirestore.instance.collection('trails').doc(trailId).get();
    Map<String, dynamic> trailData = trailDoc.data() as Map<String, dynamic>;

    // Remove ratings from arrays
    List<double> ratings = List<double>.from(trailData['ratings'] ?? []);
    List<double> trailConditionRatings = List<double>.from(trailData['trailConditionRatings'] ?? []);
    List<double> amenitiesRatings = List<double>.from(trailData['amenitiesRatings'] ?? []);

    ratings.remove(difficultyRating);
    trailConditionRatings.remove(conditionRating);
    amenitiesRatings.remove(amenitiesRating);

    // Recalculate averages
    double averageDifficulty = ratings.isNotEmpty
        ? ratings.reduce((a, b) => a + b) / ratings.length
        : 0.0;
    double averageCondition = trailConditionRatings.isNotEmpty
        ? trailConditionRatings.reduce((a, b) => a + b) / trailConditionRatings.length
        : 0.0;
    double averageAmenities = amenitiesRatings.isNotEmpty
        ? amenitiesRatings.reduce((a, b) => a + b) / amenitiesRatings.length
        : 0.0;

    // Update the trail document with updated arrays and averages
    await FirebaseFirestore.instance.collection('trails').doc(trailId).update({
      'ratings': ratings,
      'trailConditionRatings': trailConditionRatings,
      'amenitiesRatings': amenitiesRatings,
      'numberOfRatings': ratings.length, // Update the count
      'averageDifficulty': averageDifficulty,
      'averageCondition': averageCondition,
      'averageAmenities': averageAmenities,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review deleted successfully!")),
    );
  } catch (error) {
    print("Error deleting review: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to delete review. Please try again.")),
    );
  }
}

void _confirmDelete(BuildContext context, String trailId, String reviewId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        title: Text("Delete Review"),
        content: Text("Are you sure you want to delete this review? This action cannot be undone."),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteReview(trailId, reviewId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      );
    },
  );
}

}
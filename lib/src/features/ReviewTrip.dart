
import 'package:awj/src/features/authentication/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TripReviewPage extends StatefulWidget {
  final String tripId;

  TripReviewPage({required this.tripId});

  @override
 _TripReviewPageState createState() => _TripReviewPageState();
}

class _TripReviewPageState extends State<TripReviewPage> {
 String selectedContentType = 'All'; // Filter: All, Photo, Text
  String selectedSortOrder = 'Most Recent'; 
  Stream<QuerySnapshot> reviewsStream = FirebaseFirestore.instance
      .collection('GroupTrips')
      .doc("exampleTrailId") // Replace with the actual trailId
      .collection('reviews')
      .orderBy('createdAt', descending: true)
      .snapshots();

       // Open filter modal
  void openFilterDialog() {
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
                        'Content Type',
                        selectedContentType,
                        ['All', 'Photo', 'Text'],
                        (value) {
                          setModalState(() => selectedContentType = value);
                        },
                      ),
                      // Sort by Order
                      buildFilterOption(
                        'Sort By',
                        selectedSortOrder,
                        ['Most Recent', 'Least Recent', 'Most Helpful','Highest Review'],
                        (value) {
                          setModalState(() => selectedSortOrder = value);
                        },
                      ),
                      const SizedBox(height: 16),
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

void _showEditDialog(BuildContext context, String tripId, String reviewId, String currentText) {
  TextEditingController editController = TextEditingController(text: currentText);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        title: Text("Edit Review"),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: InputDecoration(hintText: "Update your review"),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Save"),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('GroupTrips')
                  .doc(tripId)
                  .collection('reviews')
                  .doc(reviewId)
                  .update({
                    'reviewText': editController.text,
                    'editedAt': Timestamp.now(),
                  }).then((_) => Navigator.of(context).pop());
            },
          ),
        ],
      );
    },
  );
}

void _deleteReview(BuildContext context, String tripId, String reviewId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        title: Text("Delete Review"),
        content: Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('GroupTrips')
                  .doc(tripId)
                  .collection('reviews')
                  .doc(reviewId)
                  .delete()
                  .then((_) => Navigator.of(context).pop());
            },
          ),
        ],
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trip Reviews",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
         actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: openFilterDialog,
          ),
        ],
         iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
       backgroundColor: Color(0xFFEAE7D8), 


       
      body: StreamBuilder<QuerySnapshot>(
        
        stream: FirebaseFirestore.instance
            .collection('GroupTrips')
            .doc(widget.tripId) 
            .collection('reviews')
            .orderBy('createdAt', descending: true)
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
 // Get current user ID
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Separate current user reviews from other reviews
    List<DocumentSnapshot> userReviews = [];
    List<DocumentSnapshot> otherReviews = [];

    // Sort reviews by user and others
    snapshot.data!.docs.forEach((doc) {
      var reviewData = doc.data() as Map<String, dynamic>;
      if (reviewData['userId'] == currentUserId) {
        userReviews.add(doc);
      } else {
        otherReviews.add(doc);
      }
    });

    // Combine user reviews at the beginning
    List<DocumentSnapshot> sortedReviews = [...userReviews, ...otherReviews];
          List<DocumentSnapshot> reviews = snapshot.data!.docs;
          
 // Apply Content Filter
    if (selectedContentType == 'Photo') {
      reviews = reviews.where((doc) {
        var reviewData = doc.data() as Map<String, dynamic>;
        return reviewData['photoUrls'] != null && (reviewData['photoUrls'] as List).isNotEmpty;
      }).toList();
    } else if (selectedContentType == 'Text') {
      reviews = reviews.where((doc) {
        var reviewData = doc.data() as Map<String, dynamic>;
        return reviewData['reviewText']?.isNotEmpty ?? false;
      }).toList();
    }

     // Apply Sorting
reviews.sort((a, b) {
  var reviewA = a.data() as Map<String, dynamic>;
  var reviewB = b.data() as Map<String, dynamic>;

  double avgRatingA = ((reviewA['difficultyRating'] ?? 0) +
                      (reviewA['conditionRating'] ?? 0) +
                      (reviewA['amenitiesRating'] ?? 0)) / 3;

  double avgRatingB = ((reviewB['difficultyRating'] ?? 0) +
                      (reviewB['conditionRating'] ?? 0) +
                      (reviewB['amenitiesRating'] ?? 0)) / 3;

  if (selectedSortOrder == 'Most Recent') {
    return reviewB['createdAt'].compareTo(reviewA['createdAt']);
  } else if (selectedSortOrder == 'Least Recent') {
    return reviewA['createdAt'].compareTo(reviewB['createdAt']);
  } else if (selectedSortOrder == 'Most Helpful') {
    return (reviewB['helpfulCount'] ?? 0).compareTo(reviewA['helpfulCount'] ?? 0);
  } else if (selectedSortOrder == 'Highest Review') {
    return avgRatingB.compareTo(avgRatingA); // Compare average ratings
  }
  return 0;
});


          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index];
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
           // Overall Rating
Row(
  children: [
    Text(
      "Rating:",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    SizedBox(width: 8),
    RatingBarIndicator(
      rating: reviewData['rating']?.toDouble() ?? 0.0, // Use 'rating' instead of multiple ratings
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: 16.0,
      direction: Axis.horizontal,
    ),
  ],
),

            
          ],
          
        ),
        SizedBox(height: 12),

        // Review Text Section or Photos
        if (reviewData['reviewText']?.isNotEmpty ?? false ||
            (reviewData['photoUrls'] != null &&
                (reviewData['photoUrls'] as List).isNotEmpty))
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Review Text (if exists)
              if (reviewData['reviewText']?.isNotEmpty ?? false)
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
          if ((reviewData['reviewText']?.isNotEmpty ?? false) || 
    (reviewData['photoUrls'] != null && (reviewData['photoUrls'] as List).isNotEmpty)) 
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Date Section
      Text(
        "Created At: ${reviewData['createdAt']?.toDate()?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),

     // Check if the current user is the organizer
FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('GroupTrips')
      .doc(widget.tripId)
      .get(),
  builder: (context, tripSnapshot) {
    if (tripSnapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (tripSnapshot.hasError) {
      return Text("Error loading trip data.");
    }

    var tripData = tripSnapshot.data?.data() as Map<String, dynamic>?;
    bool isOrganizer = tripData?['organizerId'] == FirebaseAuth.instance.currentUser?.uid;

   return Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Date Section
  

    // Buttons Section
    FirebaseAuth.instance.currentUser?.uid == reviewData['userId']
        ? Row(
            children: [
              // Edit Button
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showEditDialog(
                    context,
                    widget.tripId,
                    review.id,
                    reviewData['reviewText'],
                  );
                },
              ),
              // Delete Button
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteReview(context, widget.tripId, review.id);
                },
              ),
            ],
          )
        : Row(
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
                    if (reviewData['helpfulBy'] != null &&
                        reviewData['helpfulBy'].contains(
                            FirebaseAuth.instance.currentUser?.uid)) {
                      // Remove helpful vote
                      FirebaseFirestore.instance
                          .collection('GroupTrips')
                          .doc(widget.tripId)
                          .collection('reviews')
                          .doc(review.id)
                          .update({
                        'helpfulBy': FieldValue.arrayRemove(
                            [FirebaseAuth.instance.currentUser?.uid]),
                        'helpfulCount': FieldValue.increment(-1),
                      });
                    } else {
                      // Add helpful vote
                      FirebaseFirestore.instance
                          .collection('GroupTrips')
                          .doc(widget.tripId)
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
              // Report Button
              IconButton(
                icon: Icon(
                  Icons.flag,
                  color: (reviewData['reportedBy'] != null &&
                          reviewData['reportedBy'].contains(
                              FirebaseAuth.instance.currentUser?.uid))
                      ? Colors.red
                      : Colors.grey,
                ),
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    _showLoginDialog();
                  } else {
                    if (!(reviewData['reportedBy'] != null &&
                        reviewData['reportedBy'].contains(
                            FirebaseAuth.instance.currentUser?.uid))) {
                      _showReportDialog(context, widget.tripId, review.id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "You have already reported this review."),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
  ],
);///////

  },
),

    ],
  )
else
  // If no content, only show the date
  Text(
    "Created At: ${reviewData['createdAt']?.toDate()?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}",
    style: TextStyle(fontSize: 12, color: Colors.grey),
  ),

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
}
// Define the condition options
final List<String> conditionOptions = [
  'Excellent (Clean & Well-maintained)',
  'Good (Minor Issues)',
  'Fair (Needs Improvement)',
  'Poor (Difficult to Navigate)',
  'Very Poor (Unsafe or Inaccessible)',
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
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrls[_currentIndex]),
                          fit: BoxFit.contain,
                        ),
                      ),
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

void _submitReport(BuildContext context, String trailDocId, String reviewDocId, String reason) {
  FirebaseFirestore.instance
      .collection('GroupTrips')
      .doc(trailDocId)
      .collection('reviews')
      .doc(reviewDocId)
      .update({
        'reportedBy': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
        'reportCount': FieldValue.increment(1),
      }).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thank you for your report. Our team will review this content soon.")),
    );
  }).catchError((error) {
    print('Error submitting report: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to submit report. Please try again.")),
    );
  });
}
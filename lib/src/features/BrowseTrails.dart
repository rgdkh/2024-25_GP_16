import 'authentication/login/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'maps/maps.dart';

class ExploreTrailsScreen extends StatefulWidget {
  final bool isGuest; // Pass whether the user is a guest or not

  const ExploreTrailsScreen({super.key, required this.isGuest});

  @override
  _ExploreTrailsScreenState createState() => _ExploreTrailsScreenState();
}

class _ExploreTrailsScreenState extends State<ExploreTrailsScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE7D8),
     appBar: AppBar(
  title: const Text(
    "Explore Trails",
    style: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: const Color(0xFF2A3A26), 
  centerTitle: true, 
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white), 
    onPressed: () {
      Navigator.pop(context); 
    },
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(60), 
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase(); 
          });
        },
        decoration: const InputDecoration(
          hintText: 'Search trails by name or city...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white), 
        ),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
  ),
),


      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trails').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }

List<DocumentSnapshot> filteredDocuments = snapshot.data!.docs.where((doc) {
  var trailData = doc.data() as Map<String, dynamic>;
  

  String trailName = trailData['Name'].toString().toLowerCase();
  String trailCity = trailData['City'].toString().toLowerCase();
  String query = searchQuery.toLowerCase();

  trailName = trailName.replaceFirst(RegExp(r'^al\s'), 'al');
  trailCity = trailCity.replaceFirst(RegExp(r'^al\s'), 'al');
  query = query.replaceFirst(RegExp(r'^al\s'), 'al');

  return trailName.contains(query) || trailCity.contains(query);
}).toList();

          if (filteredDocuments.isEmpty) {
            return Center(
              child: Text('No trail found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              String documentId = filteredDocuments[index].id;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TrailWidget(
                  documentId: documentId,
                  trailData: filteredDocuments[index].data() as Map<String, dynamic>, 
                  isGuest: widget.isGuest, 
                ),
              );
            },
          );
        },
      ),
    );
  }
}



class TrailWidget extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> trailData;
  final bool isGuest;

  const TrailWidget({Key? key, required this.documentId, required this.trailData, required this.isGuest}) : super(key: key);

  @override
  _TrailWidgetState createState() => _TrailWidgetState();
}

class _TrailWidgetState extends State<TrailWidget> {
  List<double> difficultyRatings = [];
  List<double> conditionRatings = [];
  List<double> amenitiesRatings = [];

  double userDifficultyRating = 0.0;
  double userConditionRating = 0.0;
  double userAmenitiesRating = 0.0;
  double overallAverageRating = 0.0;
  int numberOfRatings = 0; // Track the number of ratings
  bool isFavorited = false;
  final TextEditingController reviewController = TextEditingController();
  String? uploadedPhotoPath;
  
  @override
  void initState() {
    super.initState();
    fetchInitialRatings();
  }

bool isHovering = false;

  Widget _buildHoverableAspect({
    required String title,
    required String description,
    required double averageRating,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) {
            setState(() {
              isHovering = true;
            });
          },
          onExit: (_) {
            setState(() {
              isHovering = false;
            });
          },
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
          ),
        ),
        if (isHovering)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        buildProgressBar(title, averageRating),
      ],
    );
  }
  
  void fetchInitialRatings() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('trails').doc(widget.documentId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          difficultyRatings = List<double>.from(data['ratings'] ?? []);
          conditionRatings = List<double>.from(data['trailConditionRatings'] ?? []);
          amenitiesRatings = List<double>.from(data['amenitiesRatings'] ?? []);
          overallAverageRating = calculateOverallAverage();
          numberOfRatings = data['numberOfRatings'] ?? 0; // Set number of ratings
        });
      }
    } catch (e) {
      print("Error fetching initial ratings: $e");
    }
  }

  double calculateAverage(List<double> ratings) {
    if (ratings.isEmpty) return 0.0;
    double sum = ratings.fold(0.0, (previous, current) => previous + current);
    return sum / ratings.length;
  }

  double calculateOverallAverage() {
    double avgDifficulty = calculateAverage(difficultyRatings);
    double avgCondition = calculateAverage(conditionRatings);
    double avgAmenities = calculateAverage(amenitiesRatings);

    return (avgDifficulty + avgCondition + avgAmenities) / 3;
  }

  void _submitRatings() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('trails').doc(widget.documentId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Retrieve the current ratings from Firestore
        List<double> currentDifficultyRatings = List<double>.from(data['ratings'] ?? []);
        List<double> currentConditionRatings = List<double>.from(data['trailConditionRatings'] ?? []);
        List<double> currentAmenitiesRatings = List<double>.from(data['amenitiesRatings'] ?? []);

        // Add the new ratings to their respective arrays
        currentDifficultyRatings.add(userDifficultyRating);
        currentConditionRatings.add(userConditionRating);
        currentAmenitiesRatings.add(userAmenitiesRating);

        // Calculate new averages
        double newAverageDifficulty = calculateAverage(currentDifficultyRatings);
        double newAverageCondition = calculateAverage(currentConditionRatings);
        double newAverageAmenities = calculateAverage(currentAmenitiesRatings);

        // Increment the number of ratings
        int currentNumberOfRatings = data['numberOfRatings'] ?? 0;
        currentNumberOfRatings += 1;

        // Update the Firestore document with the new ratings and averages
        await FirebaseFirestore.instance.collection('trails').doc(widget.documentId).update({
          'ratings': currentDifficultyRatings,
          'trailConditionRatings': currentConditionRatings,
          'amenitiesRatings': currentAmenitiesRatings,
          'averageDifficulty': newAverageDifficulty,
          'averageTrailCondition': newAverageCondition,
          'averageAmenities': newAverageAmenities,
          'numberOfRatings': currentNumberOfRatings,
        });

       Future.delayed(Duration(milliseconds: 100), () {
  Navigator.of(context).pop();
});

        setState(() {
          fetchInitialRatings(); 
        });

      }
    } catch (e) {
      print("Error submitting ratings: $e");
    }
  }
void _showAspectDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A3A26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      overallAverageRating.toStringAsFixed(1), 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRatingDescription(overallAverageRating), 
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                        
                        },
                        child: Text(
                          'See $numberOfRatings detailed reviews',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2A3A26),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              _buildAspectRatings(),
              SizedBox(height: 16),

             
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: widget.isGuest ? _showGuestMessageRate : _showRatingInputDialog,
            child: Text('Rate'),
              style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF2A3A26), 
                    foregroundColor: Colors.white, 
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
          ),
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
               style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF2A3A26), 
                    foregroundColor: Colors.white, 
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), 
                    ),
                  ),
          ),
        ],
      );
    },
  );
}





String _getRatingDescription(double rating) {
  if (rating == 0) return ''; 
  if (rating >= 4.5) return 'Fabulous';
  if (rating >= 4) return 'Very Good';
  if (rating >= 3) return 'Good';
  if (rating >= 2.5) return 'Fair';
  if (rating >= 2) return 'Poor';
  return 'Very Poor';
}



  void _showRatingInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
         title: Text(
  "Rate and Review",
  style: TextStyle(
    color: Color(0xFF2A3A26),
  ),
),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserRatingInputs(),
                SizedBox(height: 16),
                // Add Review Section
                Text(
                  "Add Review (Optional)",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Write your review here...",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                // Add Photo Section
                Row(
                  children: [
                    Text(
                      "Add Photo (Optional)",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.add_a_photo, color: Color(0xFF2A3A26)),
                      onPressed: () async {
                       
                      },
                    ),
                    if (uploadedPhotoPath != null)
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
               style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF2A3A26), 
                    foregroundColor: Colors.white, 
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), 
                    ),
                  ),
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                _submitRatings(); 
               
              },
                 style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF2A3A26), 
                    foregroundColor: Colors.white, 
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), 
                    ),
                  ),
            ),
          ],
        );
      },
    );
  }

   void _showGuestMessageRate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Login Required"),
          content: Text("You need to login or sign up to rate a trail."),
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

  void _showGuestMessageFavorite() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Login Required"),
          content: Text("You need to login or sign up to add trail to favorites."),
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


  Widget _buildAspectRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHoverableAspect(
          title: "Difficulty",
          description: "Rate how challenging you found the trail.",
          averageRating: calculateAverage(difficultyRatings),
        ),
        SizedBox(height: 16),
        _buildHoverableAspect(
          title: "Condition",
          description: "Rate the overall condition of the trail (e.g., terrain, upkeep).",
          averageRating: calculateAverage(conditionRatings),
        ),
        SizedBox(height: 16),
        _buildHoverableAspect(
          title: "Facilities",
          description: "Rate the quality and availability of amenities (e.g., benches, signs).",
          averageRating: calculateAverage(amenitiesRatings),
        ),
      ],
    );
  }

  

  Widget _buildUserRatingInputs() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
  'Difficulty',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Color(0xFF2A3A26), 
  ),
),

      SizedBox(height: 4),
      Text(
        "Rate how challenging you found the trail.",
        style: TextStyle(fontSize: 12, color: Color(0xFF2A3A26)),
      ),
      SizedBox(height: 8),
      buildUserRatingBar(userDifficultyRating, (rating) {
        setState(() {
          userDifficultyRating = rating;
        });
      }),
      SizedBox(height: 16),
      
     Text(
  'Condition',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Color(0xFF2A3A26), 
  ),
),

      SizedBox(height: 4),
      Text(
        "Rate the overall condition of the trail (e.g., terrain, upkeep).",
        style: TextStyle(fontSize: 12, color: Color(0xFF2A3A26)),
      ),
      SizedBox(height: 8),
      buildUserRatingBar(userConditionRating, (rating) {
        setState(() {
          userConditionRating = rating;
        });
      }),
      SizedBox(height: 16),
      
      Text(
  'Facilities',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Color(0xFF2A3A26), 
  ),
),

      SizedBox(height: 4),
      Text(
        "Rate the quality and availability of amenities (e.g., benches, signs).",
        style: TextStyle(fontSize: 12, color: Color(0xFF2A3A26)),
      ),
      SizedBox(height: 8),
      buildUserRatingBar(userAmenitiesRating, (rating) {
        setState(() {
          userAmenitiesRating = rating;
        });
      }),
    ],
  );
}


  Widget buildProgressBar(String title, double averageRating) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: averageRating / 5,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
        SizedBox(width: 8),
        Text('${averageRating.toStringAsFixed(1)} / 5'),
      ],
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

  @override
Widget build(BuildContext context) {
  return InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage(trailId: widget.documentId))),
    child: Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(widget.trailData['images'][0], fit: BoxFit.cover, height: 200, width: double.infinity),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                    size: 30,
                  ),
                  onPressed: () {
                    if (widget.isGuest) {
                      _showGuestMessageFavorite();
                    } else {
                      setState(() {
                        isFavorited = !isFavorited; 
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.trailData['Name'], style: TextStyle(color: Color(0xFF2A3A26), fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF2A3A26), size: 16),
                              SizedBox(width: 4),
                              Text('City: ${widget.trailData['City']}', style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/distanceIcon.png',
                                width: 16,
                                height: 16,
                              ),
                              SizedBox(width: 4),
                              Text('Length: ${widget.trailData['Distance']} ', style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.landscape, color: Color(0xFF2A3A26), size: 16),
                              SizedBox(width: 4),
                              Text('Difficulty: ${widget.trailData['Difficulty Level']}', style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _showAspectDialog,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Rating: ', style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14)),
                              RatingBarIndicator(
                                rating: overallAverageRating,
                                itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 16.0,
                                direction: Axis.horizontal,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${overallAverageRating.toStringAsFixed(1)}',
                                style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '($numberOfRatings)', // Display number of ratings
                                style: TextStyle(color: Color(0xFF2A3A26), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        
                        // More Info Button
                    
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 38.0),
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapPage(trailId: widget.documentId)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text(
                  'See Trail Details', 
                  style: TextStyle(
                    color: Color(0xFF2A3A26),
                    fontSize: 14,
                    fontWeight: FontWeight.bold, 
                  ),
                ),
                Icon(
                  Icons.arrow_forward, 
                  color: Color(0xFF2A3A26),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),


                     
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
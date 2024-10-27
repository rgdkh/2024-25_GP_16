import 'dart:math';
import 'package:awj/src/features/authentication/login/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'picsComment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPage extends StatefulWidget {
  final String trailId;

  MapPage({required this.trailId});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool get isGuest => FirebaseAuth.instance.currentUser == null;
  Map<String, dynamic>? _selectedTrail;
  List<String> _images = [];
  LatLng? _initialPosition;
  LatLng? _endPosition;
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  int _currentPage = 0; 
  late PageController _pageController;

  // Rating variables
  double overallAverageRating = 0.0;
  int numberOfRatings = 0;
  double userDifficultyRating = 0.0;
  double userConditionRating = 0.0;
  double userAmenitiesRating = 0.0;
  List<double> difficultyRatings = [];
  List<double> conditionRatings = [];
  List<double> amenitiesRatings = [];

  final TextEditingController reviewController = TextEditingController();
  String? uploadedPhotoPath;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTrail();
    fetchInitialRatings();
  }

  Future<void> _loadTrail() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _selectedTrail = data;
            _images = List<String>.from(data['images'] ?? []);

            if (data['location'] != null) {
              GeoPoint startGeoPoint = data['location'];
              _initialPosition = LatLng(startGeoPoint.latitude, startGeoPoint.longitude);
              _addMarker(_initialPosition!, 'Start of Trail', 'Tap to open in Google Maps');
            }

            if (data['End Location'] != null) {
              GeoPoint endGeoPoint = data['End Location'];
              _endPosition = LatLng(endGeoPoint.latitude, endGeoPoint.longitude);
              _addMarker(_endPosition!, 'End of Trail', 'Tap to open in Google Maps');
            }

            if (_initialPosition != null && _endPosition != null) {
              List<LatLng> polylinePoints = _generateTrailPoints(_initialPosition!, _endPosition!, 10);
              _addPolyline(polylinePoints);
            }

            if (data['locations'] != null && data['locations'] is List) {
              List locations = data['locations'];
              for (int i = 0; i < locations.length; i++) {
                if (locations[i] is GeoPoint) {
                  LatLng position = LatLng(locations[i].latitude, locations[i].longitude);
                  _addMarker(position, 'Location ${i + 1}', 'Tap to open in Google Maps');
                }
              }
            }
          });
        }
      }
    } catch (e) {
      print("Error loading trail: $e");
    }
  }

  Future<void> fetchInitialRatings() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          difficultyRatings = List<double>.from(data['ratings'] ?? []);
          conditionRatings = List<double>.from(data['trailConditionRatings'] ?? []);
          amenitiesRatings = List<double>.from(data['amenitiesRatings'] ?? []);
          overallAverageRating = calculateOverallAverage();
          numberOfRatings = data['numberOfRatings'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching initial ratings: $e");
    }
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
  void _addMarker(LatLng position, String title, String snippet) {
    _markers.add(Marker(
      markerId: MarkerId(title),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
        onTap: () => _openGoogleMaps(position.latitude, position.longitude),
      ),
    ));
  }

  void _addPolyline(List<LatLng> points) {
    _polylines.add(Polyline(
      polylineId: PolylineId('trailLine'),
      points: points,
      color: Colors.red,
      width: 5,
    ));
  }

  List<LatLng> _generateTrailPoints(LatLng start, LatLng end, int numPoints) {
    List<LatLng> points = [];
    double latDiff = (end.latitude - start.latitude) / numPoints;
    double lngDiff = (end.longitude - start.longitude) / numPoints;

    for (int i = 0; i <= numPoints; i++) {
      double lat = start.latitude + latDiff * i;
      double lng = start.longitude + lngDiff * i;

      double latRandomOffset = (Random().nextDouble() - 0.5) * 0.002;
      double lngRandomOffset = (Random().nextDouble() - 0.5) * 0.002;

      lat += latRandomOffset;
      lng += lngRandomOffset;

      points.add(LatLng(lat, lng));
    }

    return points;
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps';
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
              // Overall Rating Section
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
                      Text(
                        'See $numberOfRatings detailed reviews', 
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2A3A26),
                          decoration: TextDecoration.underline,
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
            onPressed: isGuest ? _showGuestMessageRate : _showRatingDialog,
            style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF2A3A26), 
                    foregroundColor: Colors.white, 
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), 
                    ),
                  ),
            child: Text('Rate'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF2A3A26), 
                    foregroundColor: Colors.white, 
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), 
                    ),
                  ),
            child: Text('Close'),
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

  Widget _buildHoverableAspect({
    required String title,
    required String description,
    required double averageRating,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26))),
        buildProgressBar(title, averageRating),
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

  void _showRatingDialog() {
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


  void _submitRatings() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<double> currentDifficultyRatings = List<double>.from(data['ratings'] ?? []);
        List<double> currentConditionRatings = List<double>.from(data['trailConditionRatings'] ?? []);
        List<double> currentAmenitiesRatings = List<double>.from(data['amenitiesRatings'] ?? []);

        currentDifficultyRatings.add(userDifficultyRating);
        currentConditionRatings.add(userConditionRating);
        currentAmenitiesRatings.add(userAmenitiesRating);

        int currentNumberOfRatings = data['numberOfRatings'] ?? 0;
        currentNumberOfRatings += 1;

        await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).update({
          'ratings': currentDifficultyRatings,
          'trailConditionRatings': currentConditionRatings,
          'amenitiesRatings': currentAmenitiesRatings,
          'numberOfRatings': currentNumberOfRatings,
        });

     

        setState(() {
          fetchInitialRatings();
        });
      }
    } catch (e) {
      print("Error submitting ratings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE7D8),
     appBar: AppBar(
        title: const Text(
          "Hiking Trail",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _selectedTrail == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _images.isNotEmpty
                        ? Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _images.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          _images[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _images.length,
                                  (index) => buildDot(index),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedTrail?['Name'] ?? 'Name not available',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PicsComment()),
    );
  },
  child: Row(
    children: [
      Icon(
        Icons.camera_alt, 
        color: Color(0xFF2A3A26), 
        size: 20, 
      ),
      SizedBox(width: 4), 
      Text(
        "Hikers' Photos",
        style: TextStyle(
          color: Color(0xFF2A3A26), 
          fontWeight: FontWeight.bold, 
          decoration: TextDecoration.underline,
        ),
      ),
    ],
  ),
),

                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        _selectedTrail?['Description'] ?? 'Description not available',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showAspectDialog,
                      child: Row(
                        children: [
                          Text("Rating: ", style: TextStyle(color: Color(0xFF2A3A26))),
                          RatingBarIndicator(
                            rating: overallAverageRating,
                            itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                          SizedBox(width: 8),
                          Text('${overallAverageRating.toStringAsFixed(1)} ($numberOfRatings)', style: TextStyle(color: Color(0xFF2A3A26))),
                          SizedBox(width: 8),
                        TextButton(
                       onPressed: isGuest ? _showGuestMessageRate : _showRatingDialog,
                       child: Text(
                       "Rate",
                       style: TextStyle(color: Colors.white),
                       ),
                       style: TextButton.styleFrom(
                        padding: EdgeInsets.all(12.0), 
                        backgroundColor: Color(0xFFF7A22C),
                        shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(30), 
                        ),
                       ),
                      ),
                     ],
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'Details',
                        style: TextStyle(
                            color: Color(0xFF2A3A26),
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 3,
                        width: 80,
                        color: const Color(0xFFF7A22C),
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on, 'Region', _selectedTrail?['Region']),
                    _buildInfoRow(Icons.location_city, 'City', _selectedTrail?['City']),
                    _buildInfoRow(Icons.terrain, 'Difficulty Level', _selectedTrail?['Difficulty Level']),
                    Row(
                      children: [
                        SizedBox(width: 6),
                        Image.asset(
                          'assets/images/distanceIcon.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text('Length ${_selectedTrail?['Distance']} ', style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14)),
                      ],
                    ),
                    _buildInfoRow(Icons.access_time, 'Duration', _selectedTrail?['Duration']),
                    _buildInfoRow(Icons.vertical_align_top, 'Highest elevation above sea level', _selectedTrail?['Highest elevation above sea level']),
                    _buildInfoRow(Icons.vertical_align_bottom, 'Lowest elevation above sea level', _selectedTrail?['Lowest elevation above sea level']),
                   const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'Location',
                        style: TextStyle(
                            color: Color(0xFF2A3A26),
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 3,
                        width: 80,
                        color: const Color(0xFFF7A22C),
                      ),
                    ),
                   
                    SizedBox(height: 300, child: _buildMap()),
                 
                 
                 
                  ],
                  
                ),
              ),
            ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      height: 10,
      width: 10,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.black : Colors.grey,
      ),
    );
  }

  Widget _buildMap() {
    return _initialPosition == null
        ? Center(child: Text("Loading map..."))
        : GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialPosition!, zoom: 14.0),
            markers: _markers,
            polylines: _polylines,
          );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF2A3A26)),
          SizedBox(width: 8),
          Text('$label: ${value ?? 'N/A'}'),
        ],
      ),
    );
  }
}
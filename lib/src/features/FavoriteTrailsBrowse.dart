import 'package:awj/src/features/maps/maps.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteTrailsBrowse extends StatefulWidget {
  const FavoriteTrailsBrowse({super.key});

  @override
  _FavoriteTrailsBrowseState createState() => _FavoriteTrailsBrowseState();
}

class _FavoriteTrailsBrowseState extends State<FavoriteTrailsBrowse> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text(
          "Favorite Trails",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A3A26),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
             decoration: InputDecoration(
                  hintText: 'Search trails by name or city...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF2A3A26),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchFavoriteTrails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No favorite trails available'));
          }

          // Filter the documents based on the search query
          List<DocumentSnapshot> filteredDocuments =
              snapshot.data!.docs.where((doc) {
            var trailData = doc.data() as Map<String, dynamic>;

            // Convert to lowercase
            String trailName = trailData['Name'].toString().toLowerCase();
            String trailCity = trailData['City'].toString().toLowerCase();
            String query = searchQuery.toLowerCase();

            // Remove the space after "al" if "al " is at the beginning
            trailName = trailName.replaceFirst(RegExp(r'^al\s'), 'al');
            trailCity = trailCity.replaceFirst(RegExp(r'^al\s'), 'al');
            query = query.replaceFirst(RegExp(r'^al\s'), 'al');

            // Check if the modified trailName or trailCity contains the modified search query
            return trailName.contains(query) || trailCity.contains(query);
          }).toList();

          if (filteredDocuments.isEmpty) {
            return Center(
              child: Text('No trail found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              String documentId = filteredDocuments[index].id;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TrailCard(
                  documentId: documentId,
                  trailData: filteredDocuments[index].data() as Map<String,
                      dynamic>, 
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<QuerySnapshot> _fetchFavoriteTrails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User is not logged in");
      }

      // Fetch the user's favorite trail IDs
      final userFavoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      final favoriteTrailIds =
          userFavoritesSnapshot.docs.map((doc) => doc.id).toList();

      // Fetch the trail data for the favorite trails
      return FirebaseFirestore.instance
          .collection('trails')
          .where(FieldPath.documentId, whereIn: favoriteTrailIds)
          .get();
    } catch (e) {
      print("Error fetching favorite trails: $e");
      rethrow;
    }
  }
}
class TrailCard extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> trailData;

  const TrailCard({
    Key? key,
    required this.documentId,
    required this.trailData,
  }) : super(key: key);

  @override
  _TrailCardState createState() => _TrailCardState();
}
class _TrailCardState extends State<TrailCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.documentId)
          .get();
      setState(() {
        isFavorite = docSnapshot.exists; // True if the trail is already favorited
      });
    }
  }

  void toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userFavoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    if (isFavorite) {
      // Remove from favorites
      await userFavoritesRef.doc(widget.documentId).delete();
    } else {
      // Add to favorites
      await userFavoritesRef.doc(widget.documentId).set(widget.trailData);
    }

    // Update the UI state
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(trailId: widget.documentId),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(widget.trailData['images'][0],
                    fit: BoxFit.cover, height: 200, width: double.infinity),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: toggleFavorite,
                    child: Container(
                      padding: EdgeInsets.all(6),
                     
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.trailData['Name'],
                      style: TextStyle(
                          color: Color(0xFF2A3A26),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  SizedBox(height: 4),
                 
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Color(0xFF2A3A26), size: 16),
                      SizedBox(width: 4),
                      Text('City: ${widget.trailData['City']}',
                          style: TextStyle(
                              color: Color(0xFF2A3A26), fontSize: 14)),
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
                      Text('Length: ${widget.trailData['Distance']} ',
                          style: TextStyle(
                              color: Color(0xFF2A3A26), fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.landscape, color: Color(0xFF2A3A26), size: 16),
                      SizedBox(width: 4),
                      Text('Difficulty: ${widget.trailData['Difficulty Level']}',
                          style: TextStyle(
                              color: Color(0xFF2A3A26), fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MapPage(trailId: widget.documentId),
                        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

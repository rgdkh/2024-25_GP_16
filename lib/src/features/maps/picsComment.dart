import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PicsComment extends StatelessWidget {
  final String trailId;

  PicsComment({required this.trailId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text(
          "Hiker's Photos",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trails')
            .doc(trailId)
            .collection('reviews')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No photos available for this trail.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            );
          }

          final List<QueryDocumentSnapshot> reviews = snapshot.data!.docs;
          List<dynamic> allPhotos = [];
          for (var review in reviews) {
            final data = review.data() as Map<String, dynamic>;
            final List<dynamic> photoUrls = data['photoUrls'] ?? [];
            allPhotos.addAll(photoUrls);
          }

          if (allPhotos.isEmpty) {
            return Center(
              child: Text(
                'No photos available for this trail.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: allPhotos.map((url) {
                  return GestureDetector(
                    onTap: () {
                      _showFullImageCarousel(context, allPhotos, allPhotos.indexOf(url));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          url,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 250,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: Center(child: Text('Image not available')),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }

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


}

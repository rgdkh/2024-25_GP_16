import 'package:awj/src/features/authentication/login/login.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunityHikingTips extends StatefulWidget {
  const CommunityHikingTips({super.key});

  @override
  State<CommunityHikingTips> createState() => CommunityHikingTipsState();
}

class CommunityHikingTipsState extends State<CommunityHikingTips> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'Most Recent'; // or 'Most Helpful'
String _postFilter = 'All'; // Options: 'All', 'My Posts', 'Others'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hikers Community",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A3A26),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists)
                return const SizedBox();
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final level = userData['level'] ?? 1;
              final levelTitle = userData['levelTitle'] ?? '';
              final icon = userData['icon'] ?? '';
              return IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  _showAddTipDialog(
                    context,
                    userData['name'] ?? "Unknown",
                    level,
                    levelTitle,
                    icon,
                  );
                },
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3A26),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search Posts...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2A3A26),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: openFilterDialog,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFEAE7D8),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Text(
            'Share your hiking advice, tips, or any helpful thoughts with fellow hikers!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A3A26),
            ),
          ),
          const SizedBox(height: 20),
          _buildCommunityTipsList(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Basics of Hiking',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3A26),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Prepare well to make your hiking adventure safe and enjoyable.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGraphNode({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF2A3A26)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3A26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector() {
    return Center(
      child: Container(
        height: 40,
        width: 4,
        color: const Color(0xFF2A3A26),
      ),
    );
  }


  void _showAddTipDialog(
    BuildContext context,
    String userName,
    int level,
    String levelTitle,
    String icon,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFEAE7D8),
              title: const Text("Add Post"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Post Title"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: "Post Description"),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 10),
                   
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isNotEmpty &&
                        descriptionController.text.trim().isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('hikingTips')
                          .add({
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'createdBy': FirebaseAuth.instance.currentUser!.uid,
                        'userName': userName,
                        'level': level,
                        'levelTitle': levelTitle,
                        'icon': icon,
                        'timestamp': FieldValue.serverTimestamp(),
                        'helpfulCount': 0,
                        'helpfulBy': [],
                      });

                      titleController.clear();
                      descriptionController.clear();
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Your Post has been added!"),
                          backgroundColor: Color(0xFF2A3A26),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3A26),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData getIconData(String? iconCode, {IconData fallbackIcon = Icons.home}) {
    if (iconCode == null || iconCode.isEmpty) return fallbackIcon;
    try {
      return IconData(int.parse(iconCode), fontFamily: 'MaterialIcons');
    } catch (_) {
      return fallbackIcon;
    }
  }

  Widget _buildCommunityTipsList() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hikingTips')
          .orderBy(
            _sortOption == 'Most Helpful' ? 'helpfulCount' : 'timestamp',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((doc) {
  final data = doc.data() as Map<String, dynamic>;
  final title = data['title']?.toString().toLowerCase() ?? '';
  final desc = data['description']?.toString().toLowerCase() ?? '';
  final search = _searchController.text.toLowerCase();
  return title.contains(search) || desc.contains(search);
}).where((doc) {
  final data = doc.data() as Map<String, dynamic>;
  final createdBy = data['createdBy'] ?? '';
  if (_postFilter == 'My Posts') {
    return currentUser?.uid == createdBy;
  } else if (_postFilter == 'Others') {
    return currentUser?.uid != createdBy;
  }
  return true; // For 'All'
}).toList();


        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final tipId = doc.id;
            final title = data['title'] ?? 'No title';
            final desc = data['description'] ?? 'No description';
            final name = data['userName'] ?? 'Anonymous';
            final level = data['level'] ?? '0';
            final levelTitle = data['levelTitle'] ?? 'Explorer';
            final createdBy = data['createdBy'] ?? '';
            final helpfulCount = data['helpfulCount'] ?? 0;
            final helpfulBy = List<String>.from(data['helpfulBy'] ?? []);
            final iconCode = data['icon'];
            final isOwner = currentUser?.uid == createdBy;
            final isGuest = currentUser == null;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // avatar + name
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          child: Icon(getIconData(iconCode),
                              size: 40, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.normal,
                              color: Color(0xFF2A3A26)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // level + title
                    Row(
                      children: [
                        Text('Level: $level',
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF2A3A26))),
                        const SizedBox(width: 8),
                        Text('($levelTitle)',
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF2A3A26))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // tip title & desc
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A3A26),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                    // footer: timestamp + actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['timestamp'] != null
                              ? 'Created At: ${_formatTimestamp(data['timestamp'])}'
                              : 'Created At: N/A',
                          style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey),
                        ),
                       
                        Row(
                          children: [
                            Text("Helpful? ($helpfulCount)",
                                style: const TextStyle(fontSize: 12)),
                            if (!isOwner)
                              IconButton(
                                icon: Icon(
                                  helpfulBy.contains(currentUser?.uid)
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_off_alt,
                                  color: helpfulBy.contains(currentUser?.uid)
                                      ? Colors.green
                                      : null,
                                ),
                                onPressed: () async {
                                  if (currentUser == null) {
                                    showLoginDialog(context);
                                    return;
                                  }
                                  await _toggleHelpful(tipId, helpfulBy);
                                },
                              ),
                          // Report Flag
if (!isOwner)
  IconButton(
  icon: FutureBuilder<bool>(
    future: hasUserReportedTip(tipId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Icon(Icons.flag, color: Colors.grey);
      }

      if (snapshot.hasError) {
        return const Icon(Icons.flag, color: Colors.grey);
      }

      return Icon(
        Icons.flag,
        color: snapshot.data == true ? Colors.red : Colors.grey,
      );
    },
  ),
  onPressed: () async {
    if (isGuest) {
      showLoginDialog(context);
      return;
    }

    // Check if the tip has already been reported
    bool alreadyReported = await hasUserReportedTip(tipId);
    if (alreadyReported) {
      _showAlreadyReportedDialog(context);
    } else {
      _reportTip(tipId, context);
      setState(() {}); // Update UI immediately
    }
  },
),
       if (isOwner)
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showEditTipDialog(context, tipId, data),
                              ),
                            if (isOwner)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _confirmDeleteTip(context, tipId),
                              ),
                              
                          ],
                          
                        ),
                        
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
    
  }
Future<bool> hasUserReportedTip(String tipId) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return false;

  try {
    QuerySnapshot reportSnapshot = await FirebaseFirestore.instance
        .collection('hikingTips')
        .doc(tipId)
        .collection('reported_tips')
        .where('reportedBy', isEqualTo: currentUser.uid)
        .get();

    return reportSnapshot.docs.isNotEmpty;
  } catch (e) {
    print("Error checking report: $e");
    return false;
  }
}


  Future<void> _toggleHelpful(
      String tipId, List<String> currentHelpfulBy) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('hikingTips').doc(tipId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      final currentCount = data['helpfulCount'] ?? 0;
      final helpfulList = List<String>.from(data['helpfulBy'] ?? []);

      if (helpfulList.contains(user.uid)) {
        helpfulList.remove(user.uid);
        transaction.update(docRef, {
          'helpfulCount': currentCount > 0 ? currentCount - 1 : 0,
          'helpfulBy': helpfulList,
        });
      } else {
        helpfulList.add(user.uid);
        transaction.update(docRef, {
          'helpfulCount': currentCount + 1,
          'helpfulBy': helpfulList,
        });
      }
    });
  }

  void _showEditTipDialog(
      BuildContext context, String tipId, Map<String, dynamic> tipData) {
    final titleController = TextEditingController(text: tipData['title']);
    final descController = TextEditingController(text: tipData['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text("Edit Post"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Post Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Post Description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('hikingTips')
                    .doc(tipId)
                    .update({
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A26)),
               child: const Text(
    'Update',
    style: TextStyle(color: Colors.white), // makes the text white
  ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTip(BuildContext context, String tipId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this Post?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('hikingTips')
                    .doc(tipId)
                    .delete();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
               child: const Text(
    'Delete',
    style: TextStyle(color: Colors.white), 
  ),
            ),
          ],
        );
      },
    );
  }

 void _reportTip(String tipId, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      String? selectedReason;
      TextEditingController otherReasonController = TextEditingController();

      return AlertDialog(
        backgroundColor: const Color(0xFFEAE7D8),
        title: const Text("Report Post"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  hint: const Text("Select Reason"),
                  value: selectedReason,
                  items: const [
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
                    decoration: const InputDecoration(hintText: "Enter your reason"),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF2A3A26)),
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A3A26)),
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to report this post.')),
                );
                return;
              }

              String reportReason = selectedReason == "Other"
                  ? otherReasonController.text.trim()
                  : selectedReason ?? "No Reason Provided";

              try {
                await FirebaseFirestore.instance
                    .collection('hikingTips')
                    .doc(tipId)
                    .collection('reported_tips')
                    .add({
                  'tipId': tipId,
                  'reportedBy': user.uid,
                  'reason': reportReason,
                  'adminSeen': false,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // Update UI after reporting
                setState(() {});

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Thank you for reporting!"),
                    backgroundColor: Color(0xFF2A3A26),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
          ),
        ],
      );
    },
  );
}



  void showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text("Login Required"),
          content: const Text(
              "You need to login or sign up to perform this action."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => LoginScreen()));
              },
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2A3A26)),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

 void openFilterDialog() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEAE7D8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter & Sort Posts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Filter Section
                      const Text(
                        'Filter By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text('All Posts'),
                        value: 'All',
                        activeColor: Color(0xFF2A3A26),
                        groupValue: _postFilter,
                        onChanged: (value) {
                          setModalState(() => _postFilter = value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('My Posts'),
                        value: 'My Posts',
                        activeColor: Color(0xFF2A3A26),
                        groupValue: _postFilter,
                        onChanged: (value) {
                          setModalState(() => _postFilter = value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text("Others' Posts"),
                        value: 'Others',
                        activeColor: Color(0xFF2A3A26),
                        groupValue: _postFilter,
                        onChanged: (value) {
                          setModalState(() => _postFilter = value!);
                        },
                      ),

                      const Divider(height: 32),

                      // Sort Section
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text('Most Recent'),
                        value: 'Most Recent',
                        activeColor: Color(0xFF2A3A26),
                        groupValue: _sortOption,
                        onChanged: (value) {
                          setModalState(() => _sortOption = value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Most Helpful'),
                        value: 'Most Helpful',
                        activeColor: Color(0xFF2A3A26),
                        groupValue: _sortOption,
                        onChanged: (value) {
                          setModalState(() => _sortOption = value!);
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
                ),
              );
            },
          ),
        ),
      );
    },
  );
}


  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
          "You have already reported this Post. Thank you for your feedback.",
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
  

}

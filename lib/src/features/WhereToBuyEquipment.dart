import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhereToBuyEquipment extends StatefulWidget {
  @override
  _WhereToBuyEquipmentState createState() => _WhereToBuyEquipmentState();
}

class _WhereToBuyEquipmentState extends State<WhereToBuyEquipment> {
  final List<Map<String, dynamic>> stores = [
     {
      'name': 'Decathlon',
      'description':
          'Decathlon offers affordable, durable hiking gear, including boots, trekking poles, backpacks, and clothing. Great for all experience levels.',
      'location': 'Riyadh Park Mall, Riyadh',
      'phone': '+966 9200 23456',
      'website': 'www.decathlon.com',
      'images': [
        'assets/images/Decathlon.jpg',
        'assets/images/Decathlon4.jpg',
        'assets/images/Decathlon2.jpg',
      ],
      'products': 'Trekking Poles, Boots, Rain Jackets, Sleeping Bags',
       'type': 'Physical'
    },
    {
      'name': 'Sun & Sand Sports',
      'description':
          'Sun & Sand Sports provides high-quality hiking shoes, backpacks, and hydration systems. It features international brands like The North Face and Columbia.',
      'location': 'Mall of Arabia, Jeddah',
      'phone': '+966 9200 78910',
      'website': 'www.sssports.com',
      'images': [
        'assets/images/Sun&SandSports.jpg',
        'assets/images/Sun&SandSports1.jpg',
      ],
      'products': 'Waterproof Backpacks, Hydration Packs, Hiking Shoes',
       'type': 'Physical'
    },
    {
      'name': 'Adventure HQ',
      'description':
          'Adventure HQ specializes in premium camping and hiking gear, including tents, trekking poles, climbing tools, and emergency kits.',
      'location': 'Granada Mall, Riyadh',
      'phone': '+966 9200 11223',
      'website': 'www.adventurehq.ae',
      'images': [
        'assets/images/AdventureHQ.jpg',
        'assets/images/AdventureHQ1.webp',
      ],
      'products': 'Tents, Trekking Poles, Emergency Kits, Headlamps',
       'type': 'Physical'
    },
    {
      'name': 'Amazon - Outdoor Gear',
      'description':
          'Amazon provides an extensive range of hiking equipment, including multi-purpose tools, hydration systems, and emergency gear. Perfect for quick delivery and competitive pricing.',
      'website': 'www.amazon.com',
      'images': [
        'assets/images/Amazon.jpg',
        'assets/images/Amazon1.jpg',
      ],
      'products': 'GPS Devices, Multi-Tools, First Aid Kits',
       'type': 'Physical'
    },
    {
      'name': 'Wildcraft',
      'description':
          'Wildcraft specializes in technical hiking backpacks, weatherproof jackets, and durable clothing for all terrains. Their advanced gear is perfect for extreme outdoor adventures.',
      'location': 'Kingdom Centre, Riyadh',
      'phone': '+966 9200 55678',
      'website': 'www.wildcraft.com',
      'images': [
        'assets/images/Wildcraft1.jpg',
        'assets/images/Wildcraft.webp',
      ],
      'products': 'Weatherproof Jackets, Advanced Backpacks, Gear Covers',
       'type': 'Physical'
    },
    {
      'name': 'REI Co-op',
      'description':
          'REI Co-op offers high-end hiking shoes, GPS devices, sleeping bags, and trail-specific gear with excellent customer service. A globally renowned retailer.',
      'website': 'www.rei.com',
      'images': [
        'assets/images/REICo-op1.jpg',
      ],
      'products': 'Hiking Shoes, GPS Devices, Sleeping Bags, Trail Gear',
       'type': 'Physical'
    },
    {
      'name': 'Patagonia',
      'description':
          'Patagonia focuses on sustainable, premium outdoor clothing and gear. It offers eco-friendly options for jackets, pants, and hiking essentials.',
      'website': 'www.patagonia.com',
      'images': [
        'assets/images/Patagonia.jpg',
        'assets/images/Patagonia1.jpeg',
      ],
      'products': 'Eco-Friendly Jackets, Trail Pants, Base Layers',
       'type': 'Physical'
    },
    {
      'name': 'The North Face Store',
      'description':
          'The North Face offers industry-leading hiking boots, rain jackets, and backpacks. Perfect for professional hikers and adventurers.',
      'location': 'Panorama Mall, Riyadh',
      'phone': '+966 9200 34567',
      'website': 'www.thenorthface.com',
      'images': [
        'assets/images/TheNorthFace.jpg',
        'assets/images/TheNorthFace1.jpg',
      ],
      'products': 'Hiking Boots, Rain Jackets, Trekking Backpacks',
       'type': 'Physical'
    },
    {
      'name': 'Nike Online Store',
      'description':
          'Nike offers premium sports and hiking shoes designed for durability and comfort. Check out their range of clothing and accessories for outdoor activities.',
      'website': 'www.nike.com',
      'images': [
        'assets/images/Nike.jpg',
        'assets/images/Nike1.jpg',
      ],
      'products': 'Hiking Shoes, Sportswear, Running Accessories',
      'type': 'Online'
    },
    {
      'name': 'Adidas Online Store',
      'description':
          'Adidas provides top-quality hiking boots, trail shoes, and performance apparel. Explore their eco-friendly outdoor collection for hiking and running.',
      'website': 'www.adidas.com',
      'images': [
        'assets/images/Adidas.jpg',
      ],
      'products': 'Trail Shoes, Performance Apparel, Hiking Backpacks',
      'type': 'Online'
    },
  ];

  late List<Map<String, dynamic>> filteredStores;
  String searchQuery = '';
  String selectedStoreType = 'All';

  @override
  void initState() {
    super.initState();
    filteredStores = stores;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredStores = stores.where((store) {
        final name = store['name']!.toLowerCase();
        final description = store['description']!.toLowerCase();
        final matchesQuery = name.contains(searchQuery) || description.contains(searchQuery);
        final matchesType = selectedStoreType == 'All' || store['type'] == selectedStoreType;
        return matchesQuery && matchesType;
      }).toList();
    });
  }

  void updateStoreType(String type) {
    setState(() {
      selectedStoreType = type;
      updateSearchQuery(searchQuery);
    });
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
            decoration: BoxDecoration(
              color: const Color(0xFFEAE7D8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter Stores',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Store Type Filter
                      buildFilterOption(
                        'Store Type',
                        selectedStoreType,
                        ['All', 'Online', 'Physical'],
                        (value) {
                          setModalState(() => selectedStoreType = value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Apply Filters Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          updateStoreType(selectedStoreType);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A3A26),
                        ),
                        child: const Text(
                          'Apply Filters',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Where to Buy Hiking Equipment",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A3A26),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: openFilterDialog,
          ),
        ],
      ),
      backgroundColor: Color(0xFFEAE7D8),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search for stores or equipment...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // Store List
          Expanded(
            child: filteredStores.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: filteredStores.length,
                    itemBuilder: (context, index) {
                      final store = filteredStores[index];
                      return StoreCard(store: store);
                    },
                  )
                : Center(
                    child: Text(
                      'No matches found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final Map<String, dynamic> store;

  const StoreCard({required this.store});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse('https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (store.containsKey('images'))
            Image.asset(store['images'][0], width: double.infinity, height: 200, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(store['description']!),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL(store['website']!),
                  child: Text(store['website']!, style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

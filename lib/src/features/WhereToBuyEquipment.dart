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
    },
  ];

  late List<Map<String, dynamic>> filteredStores;
  String searchQuery = '';

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
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text(
          "Where to Buy Hiking Equipment",
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
      ),
      
      backgroundColor: Color(0xFFEAE7D8),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search for stores or equipment...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
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

class StoreCard extends StatefulWidget {
  final Map<String, dynamic> store;

  const StoreCard({required this.store});

  @override
  _StoreCardState createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    final store = widget.store;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (store.containsKey('images'))
            Stack(
              children: [
                Container(
                  height: 250,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: store['images'].length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        store['images'][index],
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      store['images'].length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Colors.white
                              : Colors.grey,
                        ),
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
                Text(
                  store['name']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3A26),
                  ),
                ),
                SizedBox(height: 4),
                Text(store['description']!),
                SizedBox(height: 8),
                if (store.containsKey('products'))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.list, color: Color(0xFF2A3A26)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Products: ${store['products']}"),
                      ),
                    ],
                  ),
                if (store.containsKey('location'))
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF2A3A26)),
                      SizedBox(width: 8),
                      Expanded(child: Text(store['location']!)),
                    ],
                  ),
                if (store.containsKey('phone'))
                  Row(
                    children: [
                      Icon(Icons.phone, color: Color(0xFF2A3A26)),
                      SizedBox(width: 8),
                      Text(store['phone']!),
                    ],
                  ),
                if (store.containsKey('website'))
                  Row(
                    children: [
                      Icon(Icons.web, color: Color(0xFF2A3A26)),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _launchURL(store['website']!),
                        child: Text(
                          store['website']!,
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

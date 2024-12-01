import 'package:flutter/material.dart';

class EquipmentGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text(
          "Equipment Guide",
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
      
      body: Container(
        color: Color(0xFFEAE7D8),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderSection(context),
            _buildGraphNode(
              icon: Icons.hiking,
              title: 'Hiking Boots',
              description:
                  'Choose boots that are comfortable, provide ankle support, and are suited for uneven terrain.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.backpack,
              title: 'Backpack',
              description:
                  'A durable backpack with adjustable straps and enough capacity for your essentials is crucial.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.local_drink,
              title: 'Hydration Systems',
              description:
                  'Bring water bottles to ensure you stay hydrated throughout your hike,(you can ckeck facilites rating on a trail reviews section).',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.map,
              title: 'Navigation Tools',
              description:
                  'Carry a GPS device to stay on track and avoid getting lost.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.medical_services,
              title: 'First Aid Kit',
              description:
                  'Include bandages, antiseptics, and any personal medications to handle minor injuries.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.umbrella,
              title: 'Rain Gear',
              description:
                  'Pack a lightweight rain jacket or poncho to stay dry during unexpected weather changes.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.fastfood,
              title: 'Snacks',
              description:
                  'Bring energy-rich snacks like nuts, energy bars, or dried fruits to maintain energy levels.',
            ),
            _buildQuickTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        // Add Image at the Beginning
        Image.asset(
          'assets/images/3.jpg', // Replace with your image path
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 16),
        Text(
          'Essential Equipment for Hiking',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3A26),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Equip yourself with the right gear to ensure a safe and enjoyable hiking experience.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
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
            Icon(icon, size: 36, color: Color(0xFF2A3A26)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3A26),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
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
        color: Color(0xFF2A3A26),
      ),
    );
  }

  Widget _buildQuickTip() {
    return Card(
      color: Color(0xFFDFF6DD),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Color(0xFF2A3A26), size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Quick Tip: Always check your gear before heading out to ensure everything is in good condition!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

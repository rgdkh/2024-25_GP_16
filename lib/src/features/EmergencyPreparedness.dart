import 'package:flutter/material.dart';

class EmergencyPreparedness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Emergency Preparedness",
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
        color: Color(0xFFF7E9E9),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderSection(context),
            _buildCardWithSteps(
              title: 'Essential Emergency Items',
              steps: [
                {
                  'icon': Icons.medical_services,
                  'text': 'First Aid Kit: Include bandages, antiseptics, pain relievers, and tweezers.'
                },
                {
                  'icon': Icons.battery_charging_full,
                  'text': 'Fully Charged Power Bank: For phone or GPS devices.'
                },
                {
                  'icon': Icons.lightbulb,
                  'text': 'Flashlight with Extra Batteries: Essential for night-time or low-visibility situations.'
                },
                {
                  'icon': Icons.water_drop,
                  'text': 'Water and Purification Tablets: Stay hydrated even if you run out of water.'
                },
              ],
            ),
            _buildCardWithSteps(
              title: 'Weather Precautions',
              steps: [
                {
                  'icon': Icons.cloud,
                  'text': 'Check the weather forecast before heading out to avoid extreme conditions.'
                },
                {
                  'icon': Icons.wind_power,
                  'text': 'Carry layered clothing for sudden temperature drops or rain.'
                },
                {
                  'icon': Icons.umbrella,
                  'text': 'Bring a lightweight rain jacket for unexpected showers.'
                },
              ],
            ),
            _buildCardWithSteps(
              title: 'Navigation Safety',
              steps: [
                {
                  'icon': Icons.map,
                  'text': 'Carry a physical map in case GPS fails.'
                },
                {
                  'icon': Icons.compass_calibration,
                  'text': 'Learn to use a compass to stay oriented.'
                },
                {
                  'icon': Icons.share_location,
                  'text': 'Share your location and hiking route with a trusted person.'
                },
              ],
            ),
            _buildCardWithSteps(
              title: 'Basic Survival Skills',
              steps: [
                {
                  'icon': Icons.fireplace,
                  'text': 'Learn to build a fire: Use dry wood and a lighter or flint.'
                },
                {
                  'icon': Icons.home_repair_service,
                  'text': 'Build a simple shelter with branches and a tarp.'
                },
                {
                  'icon': Icons.local_hospital,
                  'text': 'Learn how to treat minor injuries like cuts and sprains.'
                },
              ],
            ),
            _buildQuickTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
      
        SizedBox(height: 16),
        Text(
          'Be Ready for Any Emergency!',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 187, 30, 30)),
        ),
        SizedBox(height: 8),
        Text(
          'Preparing for emergencies during hiking is essential for safety. From packing the right gear to learning survival skills, these tips will ensure you are ready for the unexpected.',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCardWithSteps({required String title, required List<Map<String, dynamic>> steps}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 187, 30, 30)),
            ),
            SizedBox(height: 12),
            Column(
              children: steps
                  .map(
                    (step) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(step['icon'], color:  Color.fromARGB(255, 187, 30, 30)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step['text'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTip() {
    return Card(
      color: Color(0xFFF8D7DA),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color:  Color.fromARGB(255, 187, 30, 30), size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Quick Tip: Always inform someone about your hiking plan and expected return time. This can save precious time in an emergency!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

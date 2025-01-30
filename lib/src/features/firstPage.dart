import 'authentication/login/login.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _introData = [
    {
      "title": "Inspired by Nature",
      "subtitle":
          "Welcome to AWJ! Your ultimate guide to hiking and adventures in Saudi Arabia.",
    },
    {
      "title": "Explore Trails",
      "subtitle":
          "Discover the beauty of Saudi Arabia's landscape, mountains, trails and valleys.",
    },
    {
      "title": "Join Trips",
      "subtitle":
          "Go on a group hiking trip and explore the beauty of nature together!",
    },
  ];

  void _onNextPressed() {
    if (_currentPage < _introData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      body: Stack(
        children: [
          // Background image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/startup.png',
              fit: BoxFit.cover,
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo at the top
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 130,
                    height: 130,
                  ),
                ),
                // PageView for intro text
                SizedBox(
                  height: 100, // Fixed height to ensure central alignment
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _introData.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _introData[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFF8A32C),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Text(
                              _introData[index]["subtitle"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF2A3A26),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Dots Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _introData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 10,
                        width: _currentPage == index ? 20 : 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const  Color(0xFF2A3A26)
                              : const Color(0xFFC5C5C5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const  Color(0xFF2A3A26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _introData.length - 1
                              ? "Start"
                              : "Next",
                          style: const TextStyle(
                            fontSize: 20,
                            color:  Color(0xFFEAE7D8),
                          ),
                        ),
                        if (_currentPage < _introData.length - 1) // Show arrow only for "Next"
                          const SizedBox(width: 10),
                        if (_currentPage < _introData.length - 1)
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFEAE7D8),
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
    );
  }
}

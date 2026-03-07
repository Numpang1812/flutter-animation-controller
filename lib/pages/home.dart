import 'package:flutter/material.dart';
import '../widgets/animated_balloon.dart';
import '../widgets/background_elements.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balloon Animation', style: TextStyle(color: Colors.white),),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.lightBlueAccent, Colors.blue],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Moving Background Elements (Clouds)
          BackgroundElements(),

          // The Balloon
          AnimatedBalloonWidget(),
        ],
      ),
    );
  }
}
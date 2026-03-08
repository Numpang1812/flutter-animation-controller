import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_balloon.dart';
import '../widgets/background_elements.dart';
import '../providers/balloon_state.dart';

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
              'assets/images/background.jpg',
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

          // The Balloon logic
          Consumer<BalloonState>(
            builder: (context, balloonState, child) {
              return Stack(
                children: [
                  // Primary balloon
                  AnimatedBalloonWidget(
                    isPrimary: true,
                    onPop: () {
                      balloonState.popFirstBalloon();
                    },
                  ),
                  
                  // The 4 new balloons that spawn after the first one is popped
                  if (balloonState.firstBalloonPopped) ...[
                    // Top left balloon
                    AnimatedBalloonWidget(
                      isPrimary: false,
                      startDelay: const Duration(milliseconds: 200),
                      initialPositionOffset: const Offset(-80, 0),
                      colorFilter: Colors.blueAccent,
                      shadowPositionOffset: const Offset(40, -100),
                      shadowBlurRadius: 10,
                    ),
                    // Top right balloon
                    AnimatedBalloonWidget(
                      isPrimary: false,
                      startDelay: const Duration(milliseconds: 500),
                      initialPositionOffset: const Offset(100, 50),
                      colorFilter: Colors.green,
                      shadowPositionOffset: const Offset(-80, -50),
                      shadowBlurRadius: 12,
                    ),
                    // Bottom left balloon
                    AnimatedBalloonWidget(
                      isPrimary: false,
                      startDelay: const Duration(milliseconds: 800),
                      initialPositionOffset: const Offset(-50, 150),
                      colorFilter: Colors.orange,
                      shadowPositionOffset: const Offset(30, -150),
                      shadowBlurRadius: 6,
                    ),
                    // Bottom right balloon
                    AnimatedBalloonWidget(
                      isPrimary: false,
                      startDelay: const Duration(milliseconds: 1100),
                      initialPositionOffset: const Offset(80, 200),
                      colorFilter: Colors.purple,
                      shadowPositionOffset: const Offset(-50, -200),
                      shadowBlurRadius: 15,
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
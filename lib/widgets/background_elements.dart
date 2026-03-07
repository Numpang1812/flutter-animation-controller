import 'package:flutter/material.dart';
import 'dart:math';

class BackgroundElements extends StatefulWidget {
  @override
  _BackgroundElementsState createState() => _BackgroundElementsState();
}

class _BackgroundElementsState extends State<BackgroundElements>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildCloud(top: 50, speedScale: 1.0, scale: 1.2),
        _buildCloud(top: 150, speedScale: 0.7, scale: 0.8, offset: 0.5),
        _buildCloud(top: 300, speedScale: 1.2, scale: 1.0, offset: 0.2),
      ],
    );
  }

  Widget _buildCloud({
    required double top,
    required double speedScale,
    required double scale,
    double offset = 0.0,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double screenWidth = MediaQuery.of(context).size.width;
        // Calculate horizontal position based on animation value and speed scale
        double xPos = (screenWidth + 200) * ((_controller.value + offset) % 1.0) - 100;
        
        return Positioned(
          top: top,
          left: xPos,
          child: Opacity(
            opacity: 0.6,
            child: Transform.scale(
              scale: scale,
              child: Icon(
                Icons.cloud,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

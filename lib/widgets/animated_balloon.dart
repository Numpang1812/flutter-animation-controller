import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedBalloonWidget extends StatefulWidget {
  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget> with TickerProviderStateMixin {
  late AnimationController _controllerFloatUp;
  late AnimationController _controllerGrowSize;
  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;

  @override
  void initState() {
    super.initState();
    _controllerFloatUp = AnimationController(duration: Duration(seconds: 8), vsync: this);
    _controllerGrowSize = AnimationController(duration: Duration(seconds: 4), vsync: this);
  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _balloonHeight = MediaQuery.of(context).size.height / 2;
    double _balloonWidth = MediaQuery.of(context).size.height / 3;
    double _balloonBottomLocation = MediaQuery.of(context).size.height - _balloonHeight;

    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
      // Changed curves to Curves.easeInOut
        CurvedAnimation(parent: _controllerFloatUp, curve: Curves.easeInOut)
    );

    _animationGrowSize = Tween(begin: 50.0, end: _balloonWidth).animate(
      // Changed curves to Curves.elasticOut
        CurvedAnimation(parent: _controllerGrowSize, curve: Curves.elasticOut)
    );

    _controllerFloatUp.forward();
    _controllerGrowSize.forward();

    return AnimatedBuilder(
      animation: _animationFloatUp,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(
            top: _animationFloatUp.value,
          ),
          width: _animationGrowSize.value,
          height: _balloonHeight + 120.0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // TODO: Add Shadows
            Positioned(
              bottom: -200.0,
              child: IgnorePointer(
                child: Transform.scale(
                  scaleY: 0.2, // smaller = flatter shadow
                  scaleX: 0.7,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: _animationGrowSize.value * 1.2,
                      height: _animationGrowSize.value * 1.2, // keep this a circle base
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                ),
              ),
            ),
              child!,
            ],
          )
        );
      },
      child: GestureDetector(
        onTap: () {
          if (_controllerFloatUp.isCompleted) {
            _controllerFloatUp.reverse();
            _controllerGrowSize.reverse();
          } else {
            _controllerFloatUp.forward();
            _controllerGrowSize.forward();
          }
        },
        child: Image.asset(
          'lib/assets/images/BeginningGoogleFlutter-Balloon.png', // Keep as is or change
          height: _balloonHeight,
          width: _balloonWidth,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: _balloonHeight,
              width: _balloonWidth,
              color: Colors.blue,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    Text(
                      'Image not found',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Check assets path',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
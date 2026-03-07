import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedBalloonWidget extends StatefulWidget {
  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget>
    with TickerProviderStateMixin {
  late AnimationController _controllerFloatUp;
  late AnimationController _controllerGrowSize;
  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;
  late Animation<double> _animationShadowLocation;
  late AnimationController _controllerRotation;
  late Animation<double> _animationRotation;

  @override
  void initState() {
    super.initState();

    // Increasing duration (e.g., to 6s) makes the sway slower/lazier.
    // Decreasing it (e.g., to 2s) makes it a fast, nervous wobble.
    _controllerRotation = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Determines how long it takes to reach the top. Higher = slower rise.
    _controllerFloatUp = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Determines how fast the balloon "inflates" when starting.
    _controllerGrowSize = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _controllerFloatUp.addStatusListener((status) {
      if (status == AnimationStatus.forward ||
          status == AnimationStatus.reverse) {
        _controllerRotation.repeat(reverse: true);
      } else if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        // animateTo(0.5) moves the rotation back to the middle of the Tween (0.0 rad).
        // Changing duration here (1500ms) affects how slowly it stops swaying.
        _controllerRotation.animateTo(0.5,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOut);
      }
    });

    _controllerFloatUp.forward();
    _controllerGrowSize.forward();
  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    _controllerRotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Height and Width are derived from screen size. 
    // Changing the divisors (2 or 3) changes the balloon's relative size.
    double _balloonHeight = MediaQuery.of(context).size.height / 2.3;
    double _balloonWidth = MediaQuery.of(context).size.width / 1.5;
    
    // Changing the end value (0.0) would stop the balloon
    // higher or lower than the top of the screen.
    double _balloonBottomLocation =
        MediaQuery.of(context).size.height - _balloonHeight;

    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
      // Curves.easeInOut makes the start and end of the float feel smoother.
      CurvedAnimation(parent: _controllerFloatUp, curve: Curves.easeInOut),
    );

    // Changing 'begin: 50.0' changes the size the balloon starts at.
    _animationGrowSize = Tween(begin: 50.0, end: _balloonWidth).animate(
      // Changed to easeOut for smooth, slow growth without the "zoom/bounce" effect.
      CurvedAnimation(parent: _controllerGrowSize, curve: Curves.easeOut),
    );

    // This explicitly sets the shadow location for 'small' (begin) and 'big' (end).
    // You can adjust these two numbers to precisely place the shadow.
    // NOTE: Do NOT use elastic/bouncy curves here — they overshoot the Tween range,
    // producing values outside begin/end and defeating the clamp() limit.
    // easeOut is smooth and guaranteed to stay within the defined range.
    _animationShadowLocation = Tween(begin: 0.0, end: -450.0).animate(
      CurvedAnimation(parent: _controllerGrowSize, curve: Curves.easeOut),
    );

    // begin/end values (-0.15 to 0.15) control the maximum tilt angle in radians.
    // radians = degrees * (pi / 180). 0.15 is about 8.6 degrees.
    _animationRotation = Tween(begin: -0.15, end: 0.15).animate(
      // Curves.easeInOutSine makes the sway feel like a smooth pendulum.
      CurvedAnimation(parent: _controllerRotation, curve: Curves.easeInOutSine),
    );

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_controllerFloatUp, _controllerGrowSize, _controllerRotation]),
      builder: (context, child) {
        // Calculate dynamic height based on aspect ratio of the balloon
        double dynamicBalloonHeight = _animationGrowSize.value * (_balloonHeight / _balloonWidth);

        return Container(
          // Controls the vertical movement.
          margin: EdgeInsets.only(top: _animationFloatUp.value),
          width: _animationGrowSize.value,
          height: _balloonHeight + 200.0,
          child: Transform.rotate(
            angle: _animationRotation.value,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Shadow
                Positioned(
                  bottom: _animationShadowLocation.value.clamp(-450.0, 0.0),
                  child: IgnorePointer(
                    child: Transform.scale(
                      scaleY: 0.2,
                      scaleX: 0.7,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: _animationGrowSize.value * 1.2,
                          height: _animationGrowSize.value * 1.2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // The Balloon Image and Reflection inside the GestureDetector
                GestureDetector(
                  onTap: () {
                    if (_controllerFloatUp.isCompleted) {
                      _controllerFloatUp.reverse();
                      _controllerGrowSize.reverse();
                    } else {
                      _controllerFloatUp.forward();
                      _controllerGrowSize.forward();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // The balloon image — now scaling with _animationGrowSize
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.red,
                          BlendMode.srcATop,
                        ),
                        child: Image.asset(
                          'lib/assets/images/BeginningGoogleFlutter-Balloon.png',
                          height: dynamicBalloonHeight,
                          width: _animationGrowSize.value,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: dynamicBalloonHeight,
                              width: _animationGrowSize.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  center: const Alignment(-0.4, -0.4),
                                  radius: 0.85,
                                  colors: [
                                    Colors.lightBlue.shade100,
                                    Colors.blue.shade500,
                                    Colors.blue.shade900,
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Glossy specular highlight — now scaling and staying in position
                      Positioned(
                        top: dynamicBalloonHeight * 0.06,
                        left: _animationGrowSize.value * 0.15,
                        child: Container(
                          width: _animationGrowSize.value * 0.28,
                          height: dynamicBalloonHeight * 0.18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.65),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}




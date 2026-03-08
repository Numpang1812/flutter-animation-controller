import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

class AnimatedBalloonWidget extends StatefulWidget {
  final bool isPrimary;
  final Duration startDelay;
  final Offset initialPositionOffset;
  final Color? colorFilter;
  final double shadowBlurRadius; 
  final Offset shadowPositionOffset;
  final VoidCallback? onPop;

  const AnimatedBalloonWidget({
    Key? key,
    this.isPrimary = true,
    this.startDelay = Duration.zero,
    this.initialPositionOffset = Offset.zero,
    this.colorFilter,
    this.shadowBlurRadius = 8.0,
    this.shadowPositionOffset = Offset.zero,
    this.onPop,
  }) : super(key: key);

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

  // Track the manual drag position
  late Offset _dragOffset;
  bool _isPopped = false;

  late AudioPlayer _audioPlayer;
  AudioPlayer? _bgPlayer;

  // Helper method to play sounds safely
  Future<void> _playSound(String assetFileName) async {
    try {
      debugPrint("🔊 Attempting to play: $assetFileName");
      AudioPlayer tempPlayer = AudioPlayer();
      tempPlayer.onPlayerComplete.listen((_) => tempPlayer.dispose());
      await tempPlayer.play(AssetSource('audio/$assetFileName'));
    } catch (e) {
      debugPrint("❌ Error playing $assetFileName: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    
    _dragOffset = widget.initialPositionOffset;
    
    // Prevent foreground sounds from ducking/stopping the background sound
    AudioPlayer.global.setAudioContext(AudioContextConfig(
      respectSilence: false,
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build());
    _audioPlayer = AudioPlayer();
    
    // Only the primary balloon handles the background music
    if (widget.isPrimary) {
      _bgPlayer = AudioPlayer();
      _bgPlayer?.setReleaseMode(ReleaseMode.loop);
      _bgPlayer?.setVolume(1.0); // Full volume for testing
      _bgPlayer!
          .play(AssetSource('audio/wind.mp3'))
          .then((_) {
            debugPrint("✅ Background wind started successfully");
          })
          .catchError((e) {
            debugPrint("❌ Background wind failed: $e");
          });
    }

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
        _controllerRotation.animateTo(
          0.5,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut,
        );
      }
    });

    Future.delayed(widget.startDelay, () {
      if (mounted && !_isPopped) {
        _controllerFloatUp.forward();
        _controllerGrowSize.forward();
        _playSound('inflate.mp3'); // Play sound on initial growth
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    if (widget.isPrimary) {
      _bgPlayer?.dispose();
    }
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
        (MediaQuery.of(context).size.height - _balloonHeight) + 200.0;

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
    _animationShadowLocation = Tween(begin: 10.0, end: -350.0).animate(
      CurvedAnimation(parent: _controllerGrowSize, curve: Curves.easeOut),
    );

    // begin/end values (-0.15 to 0.15) control the maximum tilt angle in radians.
    // radians = degrees * (pi / 180). 0.15 is about 8.6 degrees.
    _animationRotation = Tween(begin: -0.15, end: 0.15).animate(
      // Curves.easeInOutSine makes the sway feel like a smooth pendulum.
      CurvedAnimation(parent: _controllerRotation, curve: Curves.easeInOutSine),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([
        _controllerFloatUp,
        _controllerGrowSize,
        _controllerRotation,
      ]),
      builder: (context, child) {
        // If the balloon was popped, completely hide it in the widget tree
        if (_isPopped) return const SizedBox.shrink();

        // Calculate dynamic height based on aspect ratio of the balloon
        double dynamicBalloonHeight =
            _animationGrowSize.value * (_balloonHeight / _balloonWidth);

        return Transform.translate(
          offset: _dragOffset,
          child: Container(
            // Controls the vertical movement.
            margin: EdgeInsets.only(top: _animationFloatUp.value),
            width: _animationGrowSize.value,
            height: _balloonHeight + 300.0,
            child: Transform.rotate(
              angle: _animationRotation.value,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Shadow
                  Positioned(
                    bottom: _animationShadowLocation.value.clamp(-450.0, 0.0) + widget.shadowPositionOffset.dy,
                    left: widget.shadowPositionOffset.dx != 0 ? widget.shadowPositionOffset.dx : null,
                    child: IgnorePointer(
                      child: Transform.scale(
                        scaleY: 0.2,
                        scaleX: 0.7,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: widget.shadowBlurRadius, sigmaY: widget.shadowBlurRadius),
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
                    // Manual drag: updates the balloon position instantly.
                    onPanUpdate: (details) {
                      setState(() {
                        _dragOffset += details.delta;
                      });
                    },
                    // Click/Tap: triggers the balloon float up/down animation.
                    onTap: () {
                      if (widget.isPrimary) {
                        _playSound('inflate.mp3'); 
                        if (_controllerFloatUp.isCompleted) {
                          // Burst logic for the primary balloon
                          setState(() {
                            _isPopped = true;
                          });
                          if(widget.onPop != null) {
                            widget.onPop!();
                          }
                        } else {
                          // If not fully completed, treat it like normal inflating/deflating toggle
                          if (_controllerFloatUp.isAnimating && _controllerFloatUp.status == AnimationStatus.forward) {
                             _controllerFloatUp.reverse();
                             _controllerGrowSize.reverse();
                          } else {
                             _controllerFloatUp.forward();
                             _controllerGrowSize.forward();
                          }
                        }
                      } else {
                        // The newly created balloons just deflate/inflate when clicked as usual
                        _playSound('inflate.mp3'); 
                        if (_controllerFloatUp.isCompleted) {
                          _controllerFloatUp.reverse();
                          _controllerGrowSize.reverse();
                        } else {
                          _controllerFloatUp.forward();
                          _controllerGrowSize.forward();
                        }
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // The balloon image — now scaling with _animationGrowSize
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            widget.colorFilter ?? Colors.red,
                            BlendMode.srcATop,
                          ),
                          child: Image.asset(
                            'assets/images/BeginningGoogleFlutter-Balloon.png',
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
          ),
        );
      },
    );
  }
}

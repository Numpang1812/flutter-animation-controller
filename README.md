## 1. Description of the Project

The **Balloon Animation** project is an interactive Flutter application designed to showcase advanced animation techniques using `AnimationController`, `Tween`, and `CurvedAnimation`. The project features a dynamic scene where users interact with balloons that naturally float up, sway with the wind, and respond to touch and movement.

### All core requirements were successfully implemented:
1.  **Easing and Curve improvement**: Implemented using `easeInOut` and `easeInOutSine`.
2.  **Balloon Shadow**: A blurred shadow reacts to the balloon's height and inflation level. Not 100% Perfect.
3.  **Rotation Animation**: A swaying rotation shows the drifting effect.
4.  **Pulse Animation**: Used growth and shrink functions during inflation and deflation animations.
5.  **Background Animation**: Animating clouds move across the screen.
6.  **Balloon Texture**: Enhanced 3D appearance with gradients and reflections.
7.  **Interaction**: User can tap to inflate/deflate and drag to reposition balloons. Works after the Sequential Animation.
8.  **Sound Effects**: Integration of `audioplayers` for inflation sounds and background sound.
9.  **Sequential Animations**: The primary balloon pops and triggers a subsequent spawn event where multiple balloons spawn.
10. **Multiple Balloons**: A dynamic scene with multiple varied balloons is created after the first popped event.

---

## 2. Screenshots of Outputs

** Main Menu (Background / Cloud / Balloon Texture) **

<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/79a526fc-3ee3-414c-b3e6-f66a87e374b2" />

** Balloon Drifts As It Floats **

<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/a7e52c77-7a13-4e17-9aa6-243da5b76bc8" />

** Balloon Able to Move Around ** 

<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/ed334266-eb90-40c4-b08e-3070aad70ff2" />

** Multiple Balloons **

<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/0655cfea-e57d-4801-9ba3-995b7866d336" />

** Multiple Balloons Able to Move Around / Shrink / Grow **

<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/a949003b-2de5-4a11-b1a1-91261d5b94c5" />



---

## 3. Source Code

### `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'providers/balloon_state.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BalloonState()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation Controller Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
```

### `lib/pages/home.dart`
```dart
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
        title: const Text('Balloon Animation', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          // Background Gradient/Image
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
          
          // Moving Background Elements
          BackgroundElements(),

          // Balloon interaction logic
          Consumer<BalloonState>(
            builder: (context, balloonState, child) {
              return Stack(
                children: [
                  // Initial Primary balloon
                  AnimatedBalloonWidget(
                    isPrimary: true,
                    onPop: () {
                      balloonState.popFirstBalloon();
                    },
                  ),
                  
                  // Spawned sequence of balloons
                  if (balloonState.firstBalloonPopped) ...[
                    // Multiple varied balloons
                    AnimatedBalloonWidget(
                      isPrimary: false,
                      startDelay: const Duration(milliseconds: 200),
                      initialPositionOffset: const Offset(-80, 0),
                      colorFilter: Colors.blueAccent,
                      shadowPositionOffset: const Offset(40, -100),
                    ),
                    AnimatedBalloonWidget(
                      isPrimary: false,
                      startDelay: const Duration(milliseconds: 500),
                      initialPositionOffset: const Offset(100, 50),
                      colorFilter: Colors.green,
                      shadowPositionOffset: const Offset(-80, -50),
                    ),
                    AnimatedBalloonWidget(
                      isPrimary: false,
                      startDelay: const Duration(milliseconds: 800),
                      initialPositionOffset: const Offset(-50, 150),
                      colorFilter: Colors.orange,
                      shadowPositionOffset: const Offset(30, -150),
                    ),
                    AnimatedBalloonWidget(
                      isPrimary: false,
                      startDelay: const Duration(milliseconds: 1100),
                      initialPositionOffset: const Offset(80, 200),
                      colorFilter: Colors.purple,
                      shadowPositionOffset: const Offset(-50, -200),
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
```

### `lib/providers/balloon_state.dart`
```dart
import 'package:flutter/material.dart';

class BalloonState extends ChangeNotifier {
  bool _firstBalloonPopped = false;
  
  bool get firstBalloonPopped => _firstBalloonPopped;

  void popFirstBalloon() {
    _firstBalloonPopped = true;
    notifyListeners();
  }

  void reset() {
    _firstBalloonPopped = false;
    notifyListeners();
  }
}
```

### `lib/widgets/animated_balloon.dart`
```dart
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

  late Offset _dragOffset;
  bool _isPopped = false;
  AudioPlayer? _bgPlayer;

  Future<void> _playSound(String assetFileName) async {
    try {
      AudioPlayer tempPlayer = AudioPlayer();
      tempPlayer.onPlayerComplete.listen((_) => tempPlayer.dispose());
      await tempPlayer.play(AssetSource('audio/$assetFileName'));
    } catch (e) {
      debugPrint("❌ Error playing sound: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _dragOffset = widget.initialPositionOffset;
    
    // Background and initial sound setup
    if (widget.isPrimary) {
      _bgPlayer = AudioPlayer();
      _bgPlayer?.setReleaseMode(ReleaseMode.loop);
      _bgPlayer?.play(AssetSource('audio/wind.mp3')).catchError((e) => debugPrint(e.toString()));
    }

    // Animation Controllers setup
    _controllerRotation = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _controllerFloatUp = AnimationController(duration: const Duration(seconds: 8), vsync: this);
    _controllerGrowSize = AnimationController(duration: const Duration(seconds: 6), vsync: this);

    _controllerFloatUp.addStatusListener((status) {
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        _controllerRotation.repeat(reverse: true);
      } else if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _controllerRotation.animateTo(0.5, duration: const Duration(milliseconds: 1500), curve: Curves.easeOut);
      }
    });

    Future.delayed(widget.startDelay, () {
      if (mounted && !_isPopped) {
        _controllerFloatUp.forward();
        _controllerGrowSize.forward();
        _playSound('inflate.mp3');
      }
    });
  }

  @override
  void dispose() {
    _bgPlayer?.dispose();
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    _controllerRotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _balloonHeight = MediaQuery.of(context).size.height / 2.3;
    double _balloonWidth = MediaQuery.of(context).size.width / 1.5;
    double _balloonBottomLocation = (MediaQuery.of(context).size.height - _balloonHeight) + 200.0;

    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
      CurvedAnimation(parent: _controllerFloatUp, curve: Curves.easeInOut),
    );
    _animationGrowSize = Tween(begin: 50.0, end: _balloonWidth).animate(
      CurvedAnimation(parent: _controllerGrowSize, curve: Curves.easeOut),
    );
    _animationShadowLocation = Tween(begin: 10.0, end: -350.0).animate(
      CurvedAnimation(parent: _controllerGrowSize, curve: Curves.easeOut),
    );
    _animationRotation = Tween(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _controllerRotation, curve: Curves.easeInOutSine),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_controllerFloatUp, _controllerGrowSize, _controllerRotation]),
      builder: (context, child) {
        if (_isPopped) return const SizedBox.shrink();
        double dynamicHeight = _animationGrowSize.value * (_balloonHeight / _balloonWidth);

        return Transform.translate(
          offset: _dragOffset,
          child: Container(
            margin: EdgeInsets.only(top: _animationFloatUp.value),
            width: _animationGrowSize.value,
            height: _balloonHeight + 300.0,
            child: Transform.rotate(
              angle: _animationRotation.value,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Blurred Shadow
                  Positioned(
                    bottom: _animationShadowLocation.value.clamp(-450.0, 0.0) + widget.shadowPositionOffset.dy,
                    left: widget.shadowPositionOffset.dx != 0 ? widget.shadowPositionOffset.dx : null,
                    child: IgnorePointer(
                      child: Transform.scale(
                        scaleY: 0.2, scaleX: 0.7,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: widget.shadowBlurRadius, sigmaY: widget.shadowBlurRadius),
                          child: Container(
                            width: _animationGrowSize.value * 1.2, height: _animationGrowSize.value * 1.2,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.22)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // GestureDetector for interaction
                  GestureDetector(
                    onPanUpdate: (details) => setState(() => _dragOffset += details.delta),
                    onTap: () {
                      _playSound('inflate.mp3'); 
                      if (widget.isPrimary && _controllerFloatUp.isCompleted) {
                        setState(() => _isPopped = true);
                        if(widget.onPop != null) widget.onPop!();
                      } else {
                        if (_controllerFloatUp.isAnimating && _controllerFloatUp.status == AnimationStatus.forward) {
                          _controllerFloatUp.reverse(); _controllerGrowSize.reverse();
                        } else {
                          _controllerFloatUp.forward(); _controllerGrowSize.forward();
                        }
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(widget.colorFilter ?? Colors.red, BlendMode.srcATop),
                          child: Image.asset('assets/images/BeginningGoogleFlutter-Balloon.png', height: dynamicHeight, width: _animationGrowSize.value,
                            errorBuilder: (context, e, s) => Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue)),
                          ),
                        ),
                        // Specular Highlight for 3D appearance
                        Positioned(
                          top: dynamicHeight * 0.06, left: _animationGrowSize.value * 0.15,
                          child: Container(
                            width: _animationGrowSize.value * 0.28, height: dynamicHeight * 0.18,
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white.withOpacity(0.65), Colors.white.withOpacity(0.0)])),
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
```

### `lib/widgets/background_elements.dart`
```dart
import 'package:flutter/material.dart';

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
    _controller = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat();
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

  Widget _buildCloud({required double top, required double speedScale, required double scale, double offset = 0.0,}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double screenWidth = MediaQuery.of(context).size.width;
        double xPos = (screenWidth + 200) * ((_controller.value + offset) % 1.0) - 100;
        return Positioned(
          top: top, left: xPos,
          child: Opacity(
            opacity: 0.6,
            child: Transform.scale(scale: scale, child: Icon(Icons.cloud, size: 100, color: Colors.white)),
          ),
        );
      },
    );
  }
}
```

---

## 4. GitHub Link

https://github.com/Numpang1812/flutter-animation-controller

---

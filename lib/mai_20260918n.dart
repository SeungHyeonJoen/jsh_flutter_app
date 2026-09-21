import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultiGameApp());
}

class MultiGameApp extends StatelessWidget {
  const MultiGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4종 미니게임 모음집',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

// ==========================================
// 메인 메뉴 화면
// ==========================================
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 4종 미니게임 세트'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '원하시는 게임을 선택하세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildGameCard(
                context,
                title: '1. 토끼 탈출기 (Parallax & Day-Night)',
                subtitle: '산속을 깡총깡총 달리는 토끼 어드벤처!',
                icon: Icons.directions_run,
                color: Colors.orange,
                targetScreen: const RabbitRunScreen(),
              ),
              const SizedBox(height: 16),
              _buildGameCard(
                context,
                title: '2. 3초 반응속도 테스트',
                subtitle: '화면이 초록색으로 바뀔 때 즉시 터치!',
                icon: Icons.timer,
                color: Colors.green,
                targetScreen: const ReactionTestScreen(),
              ),
              const SizedBox(height: 16),
              _buildGameCard(
                context,
                title: '3. 1to25 순발력 측정',
                subtitle: '1부터 25까지의 숫자를 최대한 빠르게 순서대로 터치!',
                icon: Icons.grid_on,
                color: Colors.purple,
                targetScreen: const OneToTwentyFiveScreen(),
              ),
              const SizedBox(height: 16),
              _buildGameCard(
                context,
                title: '4. Missile Escape',
                subtitle: '전투기를 조종하여 탄막을 피하고 필살기를 사용하세요!',
                icon: Icons.airplanemode_active,
                color: Colors.redAccent,
                targetScreen: const MissileEscapeScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget targetScreen,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 26,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
      ),
    );
  }
}

// ==========================================
// GAME 1: 토끼 탈출기 (RabbitRunScreen)
// ==========================================
enum RabbitState { run, jump, slide }
enum ObstacleType { ground, air }

class Obstacle {
  double x;
  final ObstacleType type;

  Obstacle({required this.x, required this.type});
}

class SpriteFrame {
  final double x, y, w, h;
  const SpriteFrame(this.x, this.y, this.w, this.h);

  Rect get src => Rect.fromLTWH(x, y, w, h);
}

const List<SpriteFrame> kRunFrames = [
  SpriteFrame(19, 21, 76, 96),
  SpriteFrame(129, 23, 77, 91),
  SpriteFrame(241, 16, 74, 103),
  SpriteFrame(355, 18, 72, 99),
  SpriteFrame(467, 13, 71, 108),
  SpriteFrame(570, 21, 76, 96),
];

const List<SpriteFrame> kJumpFrames = [
  SpriteFrame(41, 161, 78, 89),
  SpriteFrame(210, 150, 79, 99),
  SpriteFrame(383, 127, 68, 116),
  SpriteFrame(544, 157, 77, 94),
];

const List<SpriteFrame> kSlideFrames = [
  SpriteFrame(32, 296, 100, 63),
  SpriteFrame(201, 297, 99, 62),
  SpriteFrame(367, 300, 100, 59),
  SpriteFrame(534, 306, 101, 54),
];

List<SpriteFrame> framesFor(RabbitState state) {
  switch (state) {
    case RabbitState.run:
      return kRunFrames;
    case RabbitState.jump:
      return kJumpFrames;
    case RabbitState.slide:
      return kSlideFrames;
  }
}

const double kSpriteScale = 0.62;
const double kRabbitCenterX = 140.0;

const double kRabbitHitLeft = 115.0;
const double kRabbitHitWidth = 50.0;
const double kRabbitRunHeight = 55.0;
const double kRabbitSlideHeight = 28.0;

const double kGroundObsWidth = 34.0;
const double kGroundObsHeight = 42.0;

const double kAirObsWidth = 46.0;
const double kAirObsBottom = 42.0;
const double kAirObsTop = 175.0;

bool rabbitHitsObstacle({
  required RabbitState state,
  required double rabbitY,
  required ObstacleType type,
  required double obstacleX,
}) {
  final bool isGround = type == ObstacleType.ground;

  final double rabbitHeight =
      (state == RabbitState.slide) ? kRabbitSlideHeight : kRabbitRunHeight;

  final double obsWidth = isGround ? kGroundObsWidth : kAirObsWidth;
  final double obsBottom = isGround ? 0.0 : kAirObsBottom;
  final double obsTop = isGround ? kGroundObsHeight : kAirObsTop;

  final bool hitX = (kRabbitHitLeft < obstacleX + obsWidth) &&
      (kRabbitHitLeft + kRabbitHitWidth > obstacleX);
  final bool hitY = (rabbitY < obsTop) && (rabbitY + rabbitHeight > obsBottom);

  return hitX && hitY;
}

double _hash1(double n) {
  final double x = sin(n * 127.1) * 43758.5453;
  return x - x.floorToDouble();
}

double _noise1(double x) {
  final double i = x.floorToDouble();
  final double f = x - i;
  final double u = f * f * (3 - 2 * f);
  return _hash1(i) * (1 - u) + _hash1(i + 1) * u;
}

double _fbm(double x, int octaves) {
  double v = 0, amp = 0.5, freq = 1;
  for (int i = 0; i < octaves; i++) {
    v += amp * _noise1(x * freq);
    freq *= 2.07;
    amp *= 0.5;
  }
  return v;
}

double _ridgeNoise(double x, int octaves) {
  double v = 0, amp = 0.5, freq = 1, weight = 1;
  for (int i = 0; i < octaves; i++) {
    double n = _noise1(x * freq);
    n = 1.0 - (2 * n - 1).abs();
    n *= n;
    n *= weight;
    weight = (n * 2.2).clamp(0.0, 1.0);
    v += n * amp;
    freq *= 2.03;
    amp *= 0.5;
  }
  return (v * 1.35).clamp(0.0, 1.0);
}

class SpriteFramePainter extends CustomPainter {
  final ui.Image sheet;
  final SpriteFrame frame;

  const SpriteFramePainter({required this.sheet, required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = min(size.width / frame.w, size.height / frame.h);
    final double w = frame.w * scale;
    final double h = frame.h * scale;
    canvas.drawImageRect(
      sheet,
      frame.src,
      Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2, w, h),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant SpriteFramePainter old) =>
      old.sheet != sheet || old.frame != frame;
}

class RabbitRunScreen extends StatefulWidget {
  const RabbitRunScreen({super.key});

  @override
  State<RabbitRunScreen> createState() => _RabbitRunScreenState();
}

class _RabbitRunScreenState extends State<RabbitRunScreen> {
  ui.Image? spriteSheet;
  bool isImageLoading = true;

  Timer? _gameLoop;
  bool isPlaying = false;
  bool isGameOver = false;
  int score = 0;

  double rabbitY = 0;
  double jumpProgress = 0.0;
  final double jumpDurationSeconds = 0.75;
  final double maxJumpHeight = 135.0;

  double slideProgress = 0.0;
  final double slideDurationSeconds = 0.65;

  RabbitState rabbitState = RabbitState.run;
  int currentFrame = 0;
  int frameTimer = 0;

  double elapsedTime = 0.0;
  double gameSpeed = 3.0;
  double bgScrollOffset = 0.0;

  List<Obstacle> obstacles = [];
  double timeSinceLastSpawn = 0.0;
  ObstacleType? lastSpawnType;
  final Random _random = Random();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadAndCleanSpriteSheet();
  }

  Future<void> _loadAndCleanSpriteSheet() async {
    try {
      final ByteData data = await rootBundle.load('assets/rabbitSpritesheet.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image rawImage = frameInfo.image;

      final ByteData? rawByteData = await rawImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rawByteData == null) return;

      final Uint8List pixels = rawByteData.buffer.asUint8List();

      bool alreadyTransparent = false;
      for (int i = 3; i < pixels.length; i += 4) {
        if (pixels[i] == 0) {
          alreadyTransparent = true;
          break;
        }
      }

      if (!alreadyTransparent) {
        for (int i = 0; i < pixels.length; i += 4) {
          int r = pixels[i];
          int g = pixels[i + 1];
          int b = pixels[i + 2];

          if (r >= 250 && g >= 250 && b >= 250) {
            pixels[i + 3] = 0;
          }
        }
      }

      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromPixels(
        pixels,
        rawImage.width,
        rawImage.height,
        ui.PixelFormat.rgba8888,
        (ui.Image img) => completer.complete(img),
      );

      final ui.Image transparentImg = await completer.future;

      if (mounted) {
        setState(() {
          spriteSheet = transparentImg;
          isImageLoading = false;
        });
      }
    } catch (e) {
      debugPrint("이미지 로딩 오류: $e");
      if (mounted) {
        setState(() {
          isImageLoading = false;
        });
      }
    }
  }

  void _startGame() {
    setState(() {
      isPlaying = true;
      isGameOver = false;
      score = 0;
      rabbitY = 0;
      jumpProgress = 0.0;
      slideProgress = 0.0;
      rabbitState = RabbitState.run;
      obstacles.clear();
      elapsedTime = 0.0;
      gameSpeed = 3.0;
      bgScrollOffset = 0.0;
      timeSinceLastSpawn = 0.0;
      lastSpawnType = null;
      currentFrame = 0;
    });

    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame(0.016);
    });
  }

  void _updateGame(double dt) {
    if (!isPlaying || isGameOver) return;

    setState(() {
      elapsedTime += dt;
      timeSinceLastSpawn += dt;
      score = (elapsedTime * 10).toInt();

      if (elapsedTime < 20.0) {
        gameSpeed = 3.0;
      } else if (elapsedTime < 45.0) {
        gameSpeed = 3.6;
      } else if (elapsedTime < 75.0) {
        gameSpeed = 4.3;
      } else {
        gameSpeed = min(6.0, 4.3 + (elapsedTime - 75.0) * 0.02);
      }

      bgScrollOffset += gameSpeed;

      if (rabbitState == RabbitState.jump) {
        jumpProgress += dt / jumpDurationSeconds;
        if (jumpProgress >= 1.0) {
          jumpProgress = 0.0;
          rabbitY = 0;
          rabbitState = RabbitState.run;
          currentFrame = 0;
        } else {
          rabbitY = sin(jumpProgress * pi) * maxJumpHeight;
          currentFrame = (jumpProgress * 4).floor().clamp(0, 3);
        }
      }

      if (rabbitState == RabbitState.slide) {
        slideProgress += dt / slideDurationSeconds;
        if (slideProgress >= 1.0) {
          slideProgress = 0.0;
          rabbitState = RabbitState.run;
          currentFrame = 0;
        } else {
          currentFrame = (slideProgress * 4).floor().clamp(0, 3);
        }
      }

      if (rabbitState == RabbitState.run) {
        frameTimer++;
        int frameDelay = (8 - (gameSpeed * 0.5)).clamp(3, 8).toInt();
        if (frameTimer >= frameDelay) {
          frameTimer = 0;
          currentFrame = (currentFrame + 1) % 6;
        }
      }

      double minSafeTime = (elapsedTime < 30.0) ? 1.8 : 1.4;
      if (timeSinceLastSpawn >= minSafeTime) {
        timeSinceLastSpawn = 0.0;
        ObstacleType newType = _random.nextBool() ? ObstacleType.ground : ObstacleType.air;
        lastSpawnType = newType;
        obstacles.add(Obstacle(x: 900, type: newType));
      }

      for (int i = obstacles.length - 1; i >= 0; i--) {
        obstacles[i].x -= gameSpeed * 1.8;

        if (rabbitHitsObstacle(
          state: rabbitState,
          rabbitY: rabbitY,
          type: obstacles[i].type,
          obstacleX: obstacles[i].x,
        )) {
          _gameOver();
        }

        if (obstacles[i].x < -100) {
          obstacles.removeAt(i);
        }
      }
    });
  }

  void _jump() {
    if (rabbitState == RabbitState.run) {
      setState(() {
        rabbitState = RabbitState.jump;
        jumpProgress = 0.0;
        currentFrame = 0;
      });
    }
  }

  void _slide() {
    if (rabbitState == RabbitState.run) {
      setState(() {
        rabbitState = RabbitState.slide;
        slideProgress = 0.0;
        currentFrame = 0;
      });
    }
  }

  void _gameOver() {
    _gameLoop?.cancel();
    setState(() {
      isGameOver = true;
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _focusNode.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _syncLoopWithOrientation(bool isLandscape) {
    if (!isPlaying || isGameOver) return;
    final bool running = _gameLoop?.isActive ?? false;
    if (isLandscape && !running) {
      _gameLoop = Timer.periodic(
        const Duration(milliseconds: 16),
        (_) => _updateGame(0.016),
      );
      if (mounted) setState(() {});
    } else if (!isLandscape && running) {
      _gameLoop?.cancel();
      if (mounted) setState(() {});
    }
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final LogicalKeyboardKey k = event.logicalKey;

    if (!isPlaying) {
      if (k == LogicalKeyboardKey.space ||
          k == LogicalKeyboardKey.enter ||
          k == LogicalKeyboardKey.numpadEnter) {
        if (!isImageLoading) _startGame();
      }
      return;
    }

    if (k == LogicalKeyboardKey.space ||
        k == LogicalKeyboardKey.arrowUp ||
        k == LogicalKeyboardKey.keyW) {
      _jump();
    } else if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.keyS) {
      _slide();
    }
  }

  Widget _controlButton({
    required String label,
    required IconData icon,
    required SpriteFrame? motion,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    const double d = 96;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => onPressed() : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1.0 : 0.35,
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                width: d,
                height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (motion != null && spriteSheet != null)
                      Opacity(
                        opacity: 0.9,
                        child: CustomPaint(
                          size: const Size(d * 0.78, d * 0.78),
                          painter: SpriteFramePainter(
                            sheet: spriteSheet!,
                            frame: motion,
                          ),
                        ),
                      )
                    else
                      Icon(icon, size: 42, color: Colors.white.withValues(alpha: 0.75)),

                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 6),
                          Shadow(color: Colors.black54, blurRadius: 12),
                        ],
                      ),
                    ),

                    Positioned(
                      top: 8,
                      child: Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassChip({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildRotatePrompt() {
    return Container(
      color: const Color(0xFF16222A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.screen_rotation, size: 62, color: Colors.white70),
              const SizedBox(height: 18),
              const Text(
                '화면을 가로로 돌려주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '토끼 탈출기는 가로 화면 전용입니다.\n(Chrome 개발자도구에서는 상단 회전 아이콘을 누르세요)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.5),
              ),
              const SizedBox(height: 22),
              TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                label: const Text('메뉴로 돌아가기', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isLandscape = constraints.maxWidth >= constraints.maxHeight;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _syncLoopWithOrientation(isLandscape);
              });

              if (!isLandscape) return _buildRotatePrompt();

              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: RabbitGamePainter(
                      spriteSheet: spriteSheet,
                      rabbitY: rabbitY,
                      rabbitState: rabbitState,
                      currentFrame: currentFrame,
                      obstacles: obstacles,
                      elapsedTime: elapsedTime,
                      bgScrollOffset: bgScrollOffset,
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: _glassChip(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                          ),
                          const Spacer(),
                          _glassChip(
                            child: Text(
                              '점수 $score',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18, bottom: 16),
                        child: _controlButton(
                          label: '점프',
                          icon: Icons.keyboard_arrow_up_rounded,
                          motion: kJumpFrames[2],
                          onPressed: _jump,
                          enabled: isPlaying,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18, bottom: 16),
                        child: _controlButton(
                          label: '슬라이드',
                          icon: Icons.keyboard_arrow_down_rounded,
                          motion: kSlideFrames[1],
                          onPressed: _slide,
                          enabled: isPlaying,
                        ),
                      ),
                    ),
                  ),
                  if (!isPlaying && !isGameOver)
                    Center(
                      child: isImageLoading
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: _startGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text('게임 시작', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 14),
                                _glassChip(
                                  child: const Text(
                                    '땅의 장애물은 점프로,  떨어지는 바위는 슬라이드로!',
                                    style: TextStyle(fontSize: 13, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  if (isGameOver)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('GAME OVER', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            const SizedBox(height: 8),
                            Text('최종 점수: $score', style: const TextStyle(fontSize: 21, color: Colors.white)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text('다시 도전', style: TextStyle(fontSize: 17)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class RabbitGamePainter extends CustomPainter {
  final ui.Image? spriteSheet;
  final double rabbitY;
  final RabbitState rabbitState;
  final int currentFrame;
  final List<Obstacle> obstacles;
  final double elapsedTime;
  final double bgScrollOffset;

  RabbitGamePainter({
    required this.spriteSheet,
    required this.rabbitY,
    required this.rabbitState,
    required this.currentFrame,
    required this.obstacles,
    required this.elapsedTime,
    required this.bgScrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double groundY = size.height - 40;
    double cycleTime = (elapsedTime % 120.0) / 120.0;

    Color skyTop, skyBottom, mountainColor, forestColor;
    bool showStars = false;

    if (cycleTime < 0.2) {
      double t = cycleTime / 0.2;
      skyTop = Color.lerp(const Color(0xFF2C3E50), const Color(0xFF89F7FE), t)!;
      skyBottom = Color.lerp(const Color(0xFFFD746C), const Color(0xFF66A6FF), t)!;
      mountainColor = Color.lerp(const Color(0xFF34495E), const Color(0xFF5D6D7E), t)!;
      forestColor = Color.lerp(const Color(0xFF1E8449), const Color(0xFF27AE60), t)!;
    } else if (cycleTime < 0.5) {
      skyTop = const Color(0xFF00B4DB);
      skyBottom = const Color(0xFF0083B0);
      mountainColor = const Color(0xFF4A6572);
      forestColor = const Color(0xFF2E7D32);
    } else if (cycleTime < 0.7) {
      double t = (cycleTime - 0.5) / 0.2;
      skyTop = Color.lerp(const Color(0xFF00B4DB), const Color(0xFF2C3E50), t)!;
      skyBottom = Color.lerp(const Color(0xFF0083B0), const Color(0xFFFD746C), t)!;
      mountainColor = Color.lerp(const Color(0xFF4A6572), const Color(0xFF34495E), t)!;
      forestColor = Color.lerp(const Color(0xFF2E7D32), const Color(0xFF1B5E20), t)!;
    } else {
      double t = (cycleTime - 0.7) / 0.3;
      skyTop = Color.lerp(const Color(0xFF0F2027), const Color(0xFF2C3E50), t)!;
      skyBottom = Color.lerp(const Color(0xFF203A43), const Color(0xFFFD746C), t)!;
      mountainColor = const Color(0xFF1C2833);
      forestColor = const Color(0xFF0E6251);
      showStars = t < 0.8;
    }

    final double daylight = (cycleTime < 0.2)
        ? cycleTime / 0.2
        : (cycleTime < 0.5)
            ? 1.0
            : (cycleTime < 0.7)
                ? 1.0 - (cycleTime - 0.5) / 0.2
                : 0.0;
    final double cloudOpacity = 0.18 + daylight * 0.42;
    final double snowVisibility = 0.35 + daylight * 0.65;
    final Color birdColor = Color.lerp(
      const Color(0xFF9FB4C7),
      const Color(0xFF34495E),
      daylight,
    )!;

    Rect skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    Paint skyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [skyTop, skyBottom],
      );
    canvas.drawRect(skyRect, skyPaint);

    if (showStars) {
      Paint starPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (int i = 0; i < 20; i++) {
        double sx = (i * 77 + bgScrollOffset * 0.02) % size.width;
        double sy = (i * 33) % (size.height * 0.4);
        canvas.drawCircle(Offset(sx, sy), (i % 2 == 0) ? 1.5 : 2.5, starPaint);
      }
    }

    _drawCelestialBody(canvas, size, groundY, daylight);
    _drawClouds(canvas, size, groundY, bgScrollOffset * 0.03, cloudOpacity);

    _drawRidge(
      canvas, size, groundY,
      offset: bgScrollOffset * 0.05,
      color: Color.lerp(mountainColor, skyBottom, 0.50)!.withValues(alpha: 0.92),
      baseHeight: groundY * 0.20,
      amplitude: groundY * 0.58,
      frequency: 0.0032,
      seed: 3.1,
      snowLine: groundY * 0.50,
      snowColor: Colors.white.withValues(alpha: 0.72 * snowVisibility),
    );

    _drawRidge(
      canvas, size, groundY,
      offset: bgScrollOffset * 0.13,
      color: Color.lerp(mountainColor, Colors.black, 0.18)!,
      baseHeight: groundY * 0.13,
      amplitude: groundY * 0.40,
      frequency: 0.0055,
      seed: 17.7,
    );

    _drawBirds(canvas, size, groundY, birdColor);
    _drawHillLayer(canvas, size, groundY, bgScrollOffset * 0.30, Color.lerp(forestColor, mountainColor, 0.55)!);
    _drawForestLayer(canvas, size, groundY, bgScrollOffset * 0.50, forestColor);

    Paint groundPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, size.height - groundY), groundPaint);

    Paint grassPaint = Paint()..color = const Color(0xFF558B2F);
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, 10), grassPaint);

    final Paint bladePaint = Paint()
      ..color = const Color(0xFF7CB342)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final double bladeStart = -(bgScrollOffset % 26.0) - 26.0;
    for (double x = bladeStart; x < size.width + 26; x += 26) {
      canvas.drawLine(Offset(x, groundY + 9), Offset(x + 4, groundY + 1), bladePaint);
      canvas.drawLine(Offset(x + 13, groundY + 9), Offset(x + 10, groundY + 2), bladePaint);
    }

    final List<SpriteFrame> frames = framesFor(rabbitState);
    final SpriteFrame frame = frames[currentFrame.clamp(0, frames.length - 1)];

    double drawW = frame.w * kSpriteScale;
    double drawH = frame.h * kSpriteScale;
    double footY = groundY + 4 - rabbitY;
    Rect destRect = Rect.fromLTWH(
      kRabbitCenterX - drawW / 2,
      footY - drawH,
      drawW,
      drawH,
    );

    if (spriteSheet != null) {
      canvas.drawImageRect(
        spriteSheet!,
        frame.src,
        destRect,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      Paint fallbackPaint = Paint()..color = Colors.white;
      canvas.drawOval(destRect, fallbackPaint);
    }

    for (final obs in obstacles) {
      if (obs.type == ObstacleType.ground) {
        _drawGroundObstacle(canvas, obs.x, groundY);
      } else {
        _drawRockfall(canvas, obs.x, groundY);
      }
    }
  }

  void _drawGroundObstacle(Canvas canvas, double x, double groundY) {
    final double cx = x + kGroundObsWidth / 2;
    final double base = groundY;

    final Paint body = Paint()..color = const Color(0xFF7B4B2A);
    final Paint shade = Paint()..color = const Color(0xFF5D3620);
    final Paint light = Paint()..color = const Color(0x33FFFFFF);

    canvas.drawOval(Rect.fromCenter(center: Offset(cx, base - 7), width: kGroundObsWidth, height: 17), shade);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, base - 11), width: kGroundObsWidth - 2, height: 15), body);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 1, base - 22), width: kGroundObsWidth - 11, height: 14), body);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2, base - 31), width: kGroundObsWidth - 20, height: 11), body);

    final Path tip = Path()
      ..moveTo(cx + 1, base - 35)
      ..quadraticBezierTo(cx + 7, base - 41, cx + 4, base - 42)
      ..quadraticBezierTo(cx - 1, base - 42, cx - 1, base - 36)
      ..close();
    canvas.drawPath(tip, body);

    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 6, base - 25), width: 8, height: 5), light);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 8, base - 13), width: 10, height: 5), light);
  }

  void _drawRockfall(Canvas canvas, double x, double groundY) {
    final double bottom = groundY - kAirObsBottom;
    final double top = groundY - kAirObsTop;
    final double cx = x + kAirObsWidth / 2;

    final Paint streak = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final double sx = cx - 13 + i * 13.0;
      canvas.drawLine(Offset(sx, top - 14 - i * 5), Offset(sx, top - 3 - i * 5), streak);
    }

    final double span = bottom - top;
    _drawRock(canvas, Offset(cx + 5, top + span * 0.14), 15, 13, 2.3);
    _drawRock(canvas, Offset(cx - 6, top + span * 0.44), 19, 17, 8.9);
    _drawRock(canvas, Offset(cx + 2, top + span * 0.80), 23, 21, 14.1);
  }

  void _drawRock(Canvas canvas, Offset c, double rx, double ry, double seed) {
    const int n = 9;
    final Path p = Path();
    for (int i = 0; i < n; i++) {
      final double a = i / n * 2 * pi;
      final double k = 0.76 + _hash1(seed + i * 1.37) * 0.34;
      final double px = c.dx + cos(a) * rx * k;
      final double py = c.dy + sin(a) * ry * k;
      if (i == 0) {
        p.moveTo(px, py);
      } else {
        p.lineTo(px, py);
      }
    }
    p.close();

    canvas.drawPath(p, Paint()..color = const Color(0xFF78868B));
    canvas.save();
    canvas.clipPath(p);
    canvas.drawCircle(
      Offset(c.dx - rx * 0.30, c.dy - ry * 0.38),
      rx * 0.72,
      Paint()..color = const Color(0x40FFFFFF),
    );
    canvas.drawCircle(
      Offset(c.dx + rx * 0.45, c.dy + ry * 0.5),
      rx * 0.6,
      Paint()..color = const Color(0x33000000),
    );
    canvas.restore();
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawRidge(
    Canvas canvas,
    Size size,
    double groundY, {
    required double offset,
    required Color color,
    required double baseHeight,
    required double amplitude,
    required double frequency,
    required double seed,
    double snowLine = -1,
    Color? snowColor,
  }) {
    const double stepPx = 5.0;
    final Path ridge = Path()..moveTo(-24, groundY);

    for (double x = -24; x <= size.width + 24; x += stepPx) {
      final double n = _ridgeNoise((x + offset) * frequency + seed, 5);
      ridge.lineTo(x, groundY - (baseHeight + n * amplitude));
    }
    ridge.lineTo(size.width + 24, groundY);
    ridge.close();

    canvas.drawPath(ridge, Paint()..color = color);

    canvas.save();
    canvas.clipPath(ridge);
    canvas.drawRect(
      Rect.fromLTWH(0, groundY - baseHeight - amplitude, size.width, amplitude * 1.8),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, groundY - baseHeight - amplitude),
          Offset(0, groundY),
          [Colors.white.withValues(alpha: 0.10), Colors.transparent],
        ),
    );
    canvas.restore();

    if (snowLine > 0 && snowColor != null && snowColor.a > 0) {
      canvas.save();
      canvas.clipPath(ridge);
      final double snowY = groundY - snowLine;
      final Path snow = Path()..moveTo(-24, snowY);
      for (double x = -24; x <= size.width + 24; x += 9) {
        final double wobble = _noise1((x + offset) * 0.055 + seed + 41) * 16;
        snow.lineTo(x, snowY + wobble);
      }
      snow.lineTo(size.width + 24, -60);
      snow.lineTo(-24, -60);
      snow.close();
      canvas.drawPath(snow, Paint()..color = snowColor);
      canvas.restore();
    }
  }

  void _drawHillLayer(Canvas canvas, Size size, double groundY, double offset, Color color) {
    const double stepPx = 8.0;
    final Path path = Path()..moveTo(-24, groundY);
    for (double x = -24; x <= size.width + 24; x += stepPx) {
      final double n = _fbm((x + offset) * 0.0105 + 91.3, 3);
      path.lineTo(x, groundY - (40 + n * 96));
    }
    path.lineTo(size.width + 24, groundY);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawForestLayer(Canvas canvas, Size size, double groundY, double offset, Color color) {
    const double spacing = 30.0;
    final Paint leaf = Paint()..color = color;
    final Paint leafDark = Paint()..color = Color.lerp(color, Colors.black, 0.28)!;
    final Paint trunk = Paint()..color = const Color(0xFF4E342E);

    final double startX = -(offset % spacing) - spacing;
    for (double x = startX; x < size.width + spacing; x += spacing) {
      final double idx = ((x + offset) / spacing).roundToDouble();
      final double r = _hash1(idx * 3.73);
      final double r2 = _hash1(idx * 9.11 + 5);

      final double h = 42 + r * 34;
      final double halfW = h * 0.23;
      final double bx = x + (r2 - 0.5) * 14;
      final Paint p = (r2 > 0.5) ? leafDark : leaf;

      canvas.drawRect(Rect.fromLTWH(bx - 2.5, groundY - h * 0.22, 5, h * 0.24), trunk);

      for (int t = 0; t < 3; t++) {
        final double tierBottom = groundY - h * 0.18 - t * h * 0.25;
        final double tierW = halfW * (1 - t * 0.2);
        final Path tier = Path()
          ..moveTo(bx, tierBottom - h * 0.44)
          ..lineTo(bx - tierW, tierBottom)
          ..lineTo(bx + tierW, tierBottom)
          ..close();
        canvas.drawPath(tier, p);
      }
    }
  }

  void _drawClouds(Canvas canvas, Size size, double groundY, double offset, double opacity) {
    const double spacing = 260.0;
    final double startX = -(offset % spacing) - spacing;

    for (double x = startX; x < size.width + spacing; x += spacing) {
      final double idx = ((x + offset) / spacing).roundToDouble();
      final double r = _hash1(idx * 5.19);
      final double r2 = _hash1(idx * 12.7 + 3);

      final double scale = 0.7 + r2 * 0.55;
      final double cy = 34 * scale + 8 + r * (groundY * 0.26);

      final Paint p = Paint()
        ..color = Colors.white.withValues(alpha: opacity * (0.45 + r2 * 0.4))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

      final double baseY = cy + 10 * scale;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + 26 * scale, baseY), width: 96 * scale, height: 26 * scale),
        p,
      );
      canvas.drawCircle(Offset(x + 2 * scale, cy + 3 * scale), 17 * scale, p);
      canvas.drawCircle(Offset(x + 26 * scale, cy - 9 * scale), 24 * scale, p);
      canvas.drawCircle(Offset(x + 52 * scale, cy), 18 * scale, p);
    }
  }

  void _drawCelestialBody(Canvas canvas, Size size, double groundY, double daylight) {
    final double cx = size.width * 0.74;
    final double cy = groundY * (0.19 - daylight * 0.06);
    const double radius = 26;

    final bool isDay = daylight > 0.5;
    final Color core = isDay ? const Color(0xFFFFF2B2) : const Color(0xFFEDF2F7);
    final Color glow = isDay ? const Color(0xFFFFD54F) : const Color(0xFFB0BEC5);

    canvas.drawCircle(
      Offset(cx, cy),
      radius * 2.6,
      Paint()
        ..color = glow.withValues(alpha: isDay ? 0.22 : 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawCircle(Offset(cx, cy), radius, Paint()..color = core);

    if (!isDay) {
      final Paint crater = Paint()..color = const Color(0x1A37474F);
      canvas.drawCircle(Offset(cx - 8, cy - 6), 5.5, crater);
      canvas.drawCircle(Offset(cx + 7, cy + 4), 4.0, crater);
      canvas.drawCircle(Offset(cx - 2, cy + 10), 3.0, crater);
    }
  }

  void _drawBirds(Canvas canvas, Size size, double groundY, Color color) {
    const double cycle = 15.0;
    const double crossing = 0.68;
    const int flocks = 2;

    for (int f = 0; f < flocks; f++) {
      final double t = elapsedTime / cycle + f * 0.47;
      final double lap = t.floorToDouble();
      final double phase = t - lap;
      if (phase > crossing) continue;

      final double progress = phase / crossing;
      final double headX = size.width + 70 - progress * (size.width + 150);

      final double r = _hash1(lap * 7.31 + f * 23.9);
      final double baseY = 34 + r * (groundY * 0.34);
      final int count = 3 + ((_hash1(lap * 2.7 + f) * 10).floor() % 2);

      for (int i = 0; i < count; i++) {
        final double bx = headX + i * 24.0;
        final double by = baseY + i * 7.0 + (i.isOdd ? 9 : 0);
        _drawBird(canvas, Offset(bx, by), 8.0 - i * 0.6, elapsedTime * 7.5 + i * 0.85, color);
      }
    }
  }

  void _drawBird(Canvas canvas, Offset c, double s, double phase, Color color) {
    final double tipY = c.dy - s * 0.55 * sin(phase);

    final Path wings = Path()
      ..moveTo(c.dx - s, tipY)
      ..quadraticBezierTo(c.dx - s * 0.45, c.dy - s * 0.32, c.dx, c.dy)
      ..quadraticBezierTo(c.dx + s * 0.45, c.dy - s * 0.32, c.dx + s, tipY);

    canvas.drawPath(
      wings,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// GAME 2: 3초 반응속도 테스트 (ReactionTestScreen)
// ==========================================
class ReactionTestScreen extends StatefulWidget {
  const ReactionTestScreen({super.key});

  @override
  State<ReactionTestScreen> createState() => _ReactionTestScreenState();
}

enum ReactionState { waiting, ready, result, tooEarly }

class _ReactionTestScreenState extends State<ReactionTestScreen> {
  ReactionState _state = ReactionState.waiting;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  int? _reactionTimeMs;

  void _startTest() {
    setState(() {
      _state = ReactionState.ready;
    });

    int randomDelay = 2000 + Random().nextInt(3000);
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: randomDelay), () {
      if (_state == ReactionState.ready) {
        setState(() {
          _state = ReactionState.result;
          _stopwatch.reset();
          _stopwatch.start();
        });
      }
    });
  }

  void _handleTap() {
    if (_state == ReactionState.ready) {
      _timer?.cancel();
      setState(() {
        _state = ReactionState.tooEarly;
      });
    } else if (_state == ReactionState.result) {
      _stopwatch.stop();
      setState(() {
        _reactionTimeMs = _stopwatch.elapsedMilliseconds;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.blue;
    String message = "터치하여 반응속도 테스트를 시작하세요";

    if (_state == ReactionState.ready) {
      bgColor = Colors.red;
      message = "초록색으로 바뀌면 즉시 터치하세요!";
    } else if (_state == ReactionState.result) {
      if (_reactionTimeMs == null) {
        bgColor = Colors.green;
        message = "지금 터치하세요!";
      } else {
        bgColor = Colors.indigo;
        message = "반응 속도: $_reactionTimeMs ms\n(다시 하려면 터치)";
      }
    } else if (_state == ReactionState.tooEarly) {
      bgColor = Colors.orange;
      message = "너무 빨랐습니다!\n초록색이 된 후에 터치하세요. (다시 하려면 터치)";
    }

    return Scaffold(
      appBar: AppBar(title: const Text('3초 반응속도 테스트'), backgroundColor: Colors.green),
      body: GestureDetector(
        onTap: () {
          if (_state == ReactionState.waiting || _state == ReactionState.tooEarly || _reactionTimeMs != null) {
            _reactionTimeMs = null;
            _startTest();
          } else {
            _handleTap();
          }
        },
        child: Container(
          color: bgColor,
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// GAME 3: 1to25 순발력 측정 (OneToTwentyFiveScreen)
// ==========================================
class OneToTwentyFiveScreen extends StatefulWidget {
  const OneToTwentyFiveScreen({super.key});

  @override
  State<OneToTwentyFiveScreen> createState() => _OneToTwentyFiveScreenState();
}

class _OneToTwentyFiveScreenState extends State<OneToTwentyFiveScreen> {
  List<int> numbers = [];
  int currentTarget = 1;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String elapsedTime = "0.00 초";
  bool isCompleted = false;
  bool isGameStarted = false;

  void _initGame() {
    numbers = List.generate(25, (index) => index + 1)..shuffle();
    currentTarget = 1;
    elapsedTime = "0.00 초";
    isCompleted = false;
    isGameStarted = true;

    _stopwatch.reset();
    _stopwatch.start();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          elapsedTime = "${(_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} 초";
        });
      }
    });
  }

  void _onNumberTap(int number) {
    if (!isGameStarted || isCompleted) return;

    if (number == currentTarget) {
      setState(() {
        if (currentTarget == 25) {
          _stopwatch.stop();
          _timer?.cancel();
          isCompleted = true;
        } else {
          currentTarget++;
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1to25 순발력 측정'), backgroundColor: Colors.purple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('다음 숫자: $currentTarget', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('경과 시간: $elapsedTime', style: const TextStyle(fontSize: 20, color: Colors.purple, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            if (!isGameStarted)
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: _initGame,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                    child: const Text('게임 시작', style: TextStyle(fontSize: 22)),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    int num = numbers[index];
                    bool isCleared = num < currentTarget;

                    return ElevatedButton(
                      onPressed: isCleared ? null : () => _onNumberTap(num),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCleared ? Colors.grey.shade300 : Colors.purple.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isCleared ? '' : '$num',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('🎉 완료! 기록: $elapsedTime', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _initGame, child: const Text('다시 도전')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// GAME 4: Missile Escape (개선된 구현)
// ==========================================

// 게임 제어 전역 상수
const Size kPlayerRenderSize = Size(74, 91);
const double kPlayerHitboxRadius = 18.0;
const double kBulletRadius = 7.0;
const double kBulletHitboxRadius = 5.0;

const double kJoystickBaseRadius = 65.0;
const double kJoystickStickRadius = 28.0;
const double kPlayerMaxSpeed = 380.0;

const int kSpecialStockScoreStep = 300;
const int kMaxSpecialStock = 3;
const double kInvincibleDuration = 3.0;

class Missile {
  Offset position;
  Offset velocity;

  Missile({
    required this.position,
    required this.velocity,
  });
}

class CloudParticle {
  Offset position;
  double scale;
  double speed;
  double opacity;

  CloudParticle({
    required this.position,
    required this.scale,
    required this.speed,
    required this.opacity,
  });
}

class Shockwave {
  Offset center;
  double radius;
  double maxRadius;
  double opacity;

  Shockwave({
    required this.center,
    required this.radius,
    required this.maxRadius,
    this.opacity = 1.0,
  });
}

class MissileEscapeDifficulty {
  final double spawnInterval;
  final double missileSpeed;
  final int maxMissiles;
  final int burstCount;

  const MissileEscapeDifficulty({
    required this.spawnInterval,
    required this.missileSpeed,
    required this.maxMissiles,
    required this.burstCount,
  });
}

class MissileEscapeScreen extends StatefulWidget {
  const MissileEscapeScreen({super.key});

  @override
  State<MissileEscapeScreen> createState() => _MissileEscapeScreenState();
}

class _MissileEscapeScreenState extends State<MissileEscapeScreen> {
  Timer? _gameTimer;
  bool isPlaying = false;
  bool isGameOver = false;
  bool isReady = false;

  double elapsedTime = 0.0;
  int score = 0;

  Offset playerPosition = Offset.zero;
  Offset joystickDir = Offset.zero;
  Offset joystickStickPos = Offset.zero;

  Size screenSize = Size.zero;

  List<Missile> missiles = [];
  List<CloudParticle> clouds = [];
  List<Shockwave> shockwaves = [];

  double timeSinceLastSpawn = 0.0;
  double bgScrollOffset = 0.0;

  // 필살기 관련 상태
  int specialStocks = 0;
  double specialProgress = 0.0;
  double invincibleTimeRemaining = 0.0;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
  }

  void _initClouds(Size size) {
    clouds.clear();
    for (int i = 0; i < 8; i++) {
      clouds.add(
        CloudParticle(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          scale: 0.6 + _random.nextDouble() * 0.8,
          speed: 30.0 + _random.nextDouble() * 50.0,
          opacity: 0.15 + _random.nextDouble() * 0.25,
        ),
      );
    }
  }

  MissileEscapeDifficulty _getDifficulty(double t) {
    double spawnInterval = max(0.08, 1.15 * exp(-t / 35.0));
    int maxMissiles = min(120, 12 + (t * 1.25).toInt());
    double missileSpeed = min(480.0, 160.0 + t * 3.5);
    int burstCount = 1 + (t / 40.0).floor().clamp(0, 2);

    return MissileEscapeDifficulty(
      spawnInterval: spawnInterval,
      missileSpeed: missileSpeed,
      maxMissiles: maxMissiles,
      burstCount: burstCount,
    );
  }

  void _onStartPressed() {
    setState(() {
      isReady = true;
    });

    Timer(const Duration(seconds: 1), () {
      if (mounted && isReady) {
        _startGame();
      }
    });
  }

  void _startGame() {
    setState(() {
      isPlaying = true;
      isGameOver = false;
      isReady = false;
      elapsedTime = 0.0;
      score = 0;
      timeSinceLastSpawn = 0.0;
      specialStocks = 0;
      specialProgress = 0.0;
      invincibleTimeRemaining = 0.0;
      joystickDir = Offset.zero;
      joystickStickPos = Offset.zero;
      missiles.clear();
      shockwaves.clear();

      if (screenSize != Size.zero) {
        playerPosition = Offset(
          screenSize.width / 2,
          screenSize.height * 0.75,
        );
      }
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame(0.016);
    });
  }

  void _updateGame(double dt) {
    if (!isPlaying || isGameOver) return;

    setState(() {
      elapsedTime += dt;
      score = (elapsedTime * 10).toInt();

      // 필살기 게이지 충전
      int calculatedStocks = min(kMaxSpecialStock, score ~/ kSpecialStockScoreStep);
      if (specialStocks < kMaxSpecialStock) {
        specialProgress = (score % kSpecialStockScoreStep) / kSpecialStockScoreStep;
        if (calculatedStocks > specialStocks) {
          specialStocks = calculatedStocks;
          if (specialStocks == kMaxSpecialStock) {
            specialProgress = 1.0;
          }
        }
      } else {
        specialProgress = 1.0;
      }

      // 무적 잔여 시간 계산
      if (invincibleTimeRemaining > 0) {
        invincibleTimeRemaining = max(0.0, invincibleTimeRemaining - dt);
      }

      // 플레이어 이동 연산 (조이스틱 입력)
      if (joystickDir != Offset.zero) {
        Offset moveDelta = joystickDir * kPlayerMaxSpeed * dt;
        double clampedX = (playerPosition.dx + moveDelta.dx).clamp(
          kPlayerRenderSize.width / 2,
          screenSize.width - kPlayerRenderSize.width / 2,
        );
        double clampedY = (playerPosition.dy + moveDelta.dy).clamp(
          kPlayerRenderSize.height / 2,
          screenSize.height - kPlayerRenderSize.height / 2,
        );
        playerPosition = Offset(clampedX, clampedY);
      }

      timeSinceLastSpawn += dt;
      bgScrollOffset += dt * 100.0;

      // 구름 이동
      for (var cloud in clouds) {
        cloud.position = Offset(
          cloud.position.dx,
          cloud.position.dy + cloud.speed * dt,
        );
        if (cloud.position.dy > screenSize.height + 100) {
          cloud.position = Offset(
            _random.nextDouble() * screenSize.width,
            -100,
          );
        }
      }

      // 충격파 애니메이션
      for (int i = shockwaves.length - 1; i >= 0; i--) {
        var sw = shockwaves[i];
        sw.radius += dt * 800.0;
        sw.opacity = max(0.0, 1.0 - (sw.radius / sw.maxRadius));
        if (sw.radius >= sw.maxRadius) {
          shockwaves.removeAt(i);
        }
      }

      // 탄환 스폰 처리
      final difficulty = _getDifficulty(elapsedTime);
      if (timeSinceLastSpawn >= difficulty.spawnInterval &&
          missiles.length < difficulty.maxMissiles) {
        timeSinceLastSpawn = 0.0;
        for (int b = 0; b < difficulty.burstCount; b++) {
          if (missiles.length < difficulty.maxMissiles) {
            _spawnMissile(difficulty.missileSpeed);
          }
        }
      }

      // 탄환 이동 및 충돌 체크
      for (int i = missiles.length - 1; i >= 0; i--) {
        var m = missiles[i];
        m.position += m.velocity * dt;

        if (m.position.dx < -50 ||
            m.position.dx > screenSize.width + 50 ||
            m.position.dy < -50 ||
            m.position.dy > screenSize.height + 50) {
          missiles.removeAt(i);
          continue;
        }

        // 무적 상태가 아닐 때 피격 검사
        if (invincibleTimeRemaining <= 0.0 && _checkCollision(m)) {
          _gameOver();
          break;
        }
      }
    });
  }

  void _spawnMissile(double speed) {
    if (screenSize == Size.zero) return;

    int edge = _random.nextInt(4);
    double startX = 0;
    double startY = 0;

    switch (edge) {
      case 0:
        startX = _random.nextDouble() * screenSize.width;
        startY = -20;
        break;
      case 1:
        startX = _random.nextDouble() * screenSize.width;
        startY = screenSize.height + 20;
        break;
      case 2:
        startX = -20;
        startY = _random.nextDouble() * screenSize.height;
        break;
      case 3:
        startX = screenSize.width + 20;
        startY = _random.nextDouble() * screenSize.height;
        break;
    }

    Offset startPos = Offset(startX, startY);
    Offset dir = playerPosition - startPos;
    double distance = dir.distance;
    if (distance == 0) return;

    Offset normalizedDir = dir / distance;
    Offset velocity = normalizedDir * speed;

    missiles.add(Missile(
      position: startPos,
      velocity: velocity,
    ));
  }

  bool _checkCollision(Missile missile) {
    double distanceSq = (playerPosition - missile.position).distanceSquared;
    double minDistance = kPlayerHitboxRadius + kBulletHitboxRadius;
    return distanceSq <= (minDistance * minDistance);
  }

  void _useSpecialSkill() {
    if (!isPlaying || isGameOver || specialStocks <= 0) return;

    setState(() {
      specialStocks--;
      if (specialStocks < kMaxSpecialStock) {
        specialProgress = (score % kSpecialStockScoreStep) / kSpecialStockScoreStep;
      }
      invincibleTimeRemaining = kInvincibleDuration;

      // 발동 이펙트
      shockwaves.add(Shockwave(
        center: playerPosition,
        radius: 10.0,
        maxRadius: max(screenSize.width, screenSize.height) * 1.2,
      ));

      // 맵의 모든 탄환 격파
      missiles.clear();
    });
  }

  void _gameOver() {
    _gameTimer?.cancel();
    setState(() {
      isGameOver = true;
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  Widget _glassChip({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildJoystick() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) => _updateJoystick(details.localPosition),
      onPanUpdate: (details) => _updateJoystick(details.localPosition),
      onPanEnd: (_) => _resetJoystick(),
      onPanCancel: () => _resetJoystick(),
      child: Container(
        width: kJoystickBaseRadius * 2,
        height: kJoystickBaseRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: joystickStickPos,
            child: Container(
              width: kJoystickStickRadius * 2,
              height: kJoystickStickRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withValues(alpha: 0.6),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.cyanAccent, blurRadius: 10, spreadRadius: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateJoystick(Offset localPos) {
    Offset center = const Offset(kJoystickBaseRadius, kJoystickBaseRadius);
    Offset delta = localPos - center;
    double dist = delta.distance;

    double maxDist = kJoystickBaseRadius - kJoystickStickRadius;
    if (dist > maxDist) {
      joystickStickPos = (delta / dist) * maxDist;
    } else {
      joystickStickPos = delta;
    }

    joystickDir = (dist == 0) ? Offset.zero : delta / dist;
  }

  void _resetJoystick() {
    setState(() {
      joystickStickPos = Offset.zero;
      joystickDir = Offset.zero;
    });
  }

  Widget _buildSpecialButton() {
    bool canUse = specialStocks > 0;
    return GestureDetector(
      onTap: canUse ? _useSpecialSkill : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: specialStocks == kMaxSpecialStock ? 1.0 : specialProgress,
              strokeWidth: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              color: canUse ? Colors.amberAccent : Colors.white54,
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canUse ? Colors.amber.shade700.withValues(alpha: 0.8) : Colors.grey.shade800.withValues(alpha: 0.6),
              border: Border.all(color: canUse ? Colors.amberAccent : Colors.white24, width: 2),
              boxShadow: canUse
                  ? [
                      BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_on, color: canUse ? Colors.white : Colors.white38, size: 26),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(kMaxSpecialStock, (index) {
                    bool active = index < specialStocks;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? Colors.cyanAccent : Colors.white24,
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (screenSize != Size(constraints.maxWidth, constraints.maxHeight)) {
            screenSize = Size(constraints.maxWidth, constraints.maxHeight);
            if (!isPlaying && !isGameOver) {
              playerPosition = Offset(
                screenSize.width / 2,
                screenSize.height * 0.75,
              );
              _initClouds(screenSize);
            }
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: MissileGamePainter(
                  playerPosition: playerPosition,
                  playerRenderSize: kPlayerRenderSize,
                  missiles: missiles,
                  clouds: clouds,
                  shockwaves: shockwaves,
                  invincibleTimeRemaining: invincibleTimeRemaining,
                  elapsedTime: elapsedTime,
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: _glassChip(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                          ),
                        ),
                        const Spacer(),
                        _glassChip(
                          child: Row(
                            children: [
                              Text(
                                'SCORE $score',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'TIME ${elapsedTime.toStringAsFixed(1)}s',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isPlaying && !isGameOver) ...[
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 20),
                      child: _buildJoystick(),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24, bottom: 24),
                      child: _buildSpecialButton(),
                    ),
                  ),
                ),
              ],

              if (!isPlaying && !isGameOver && !isReady)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.airplanemode_active, size: 60, color: Colors.cyanAccent),
                        const SizedBox(height: 12),
                        const Text(
                          'MISSILE ESCAPE',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '조이스틱으로 기체를 조종하고,\n필살기로 탄막을 전멸시키며 생존하세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _onStartPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('게임 시작', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

              if (isReady && !isPlaying)
                const Center(
                  child: Text(
                    'READY...',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.amberAccent,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 10),
                      ],
                    ),
                  ),
                ),

              if (isGameOver)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'GAME OVER',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('최종 점수: $score', style: const TextStyle(fontSize: 22, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('생존 시간: ${elapsedTime.toStringAsFixed(1)}초', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('다시 도전', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class MissileGamePainter extends CustomPainter {
  final Offset playerPosition;
  final Size playerRenderSize;
  final List<Missile> missiles;
  final List<CloudParticle> clouds;
  final List<Shockwave> shockwaves;
  final double invincibleTimeRemaining;
  final double elapsedTime;

  // 정적 Paint 객체 재사용으로 매 프레임 객체 생성 방지
  static final Paint _skyPaint = Paint();
  static final Paint _bulletCorePaint = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _bulletGlowPaint = Paint()..color = const Color(0xFFFF9800);
  static final Paint _bulletTrailPaint = Paint()
    ..color = const Color(0xFFFF5722)
    ..strokeCap = StrokeCap.round;

  MissileGamePainter({
    required this.playerPosition,
    required this.playerRenderSize,
    required this.missiles,
    required this.clouds,
    required this.shockwaves,
    required this.invincibleTimeRemaining,
    required this.elapsedTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 하늘 배경 그라데이션
    Rect skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    _skyPaint.shader = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.height),
      [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C3E50)],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(skyRect, _skyPaint);

    // 2. 구름
    for (var cloud in clouds) {
      _drawCloud(canvas, cloud.position, cloud.scale, cloud.opacity);
    }

    // 3. 충격파
    for (var sw in shockwaves) {
      final Paint swPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..color = Colors.cyanAccent.withValues(alpha: sw.opacity);
      canvas.drawCircle(sw.center, sw.radius, swPaint);
    }

    // 4. 전투기 (방안 B: 벡터)
    _drawVectorFighter(canvas, playerPosition, playerRenderSize);

    // 무적 무지개/실드 이펙트
    if (invincibleTimeRemaining > 0) {
      _drawInvincibleShield(canvas, playerPosition, invincibleTimeRemaining);
    }

    // 5. 원형 탄환
    for (var missile in missiles) {
      _drawBullet(canvas, missile);
    }
  }

  void _drawCloud(Canvas canvas, Offset pos, double scale, double opacity) {
    final Paint p = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    double baseRadius = 25 * scale;
    canvas.drawCircle(pos, baseRadius, p);
    canvas.drawCircle(Offset(pos.dx - 20 * scale, pos.dy + 5 * scale), baseRadius * 0.8, p);
    canvas.drawCircle(Offset(pos.dx + 22 * scale, pos.dy + 8 * scale), baseRadius * 0.85, p);
    canvas.drawCircle(Offset(pos.dx - 10 * scale, pos.dy - 12 * scale), baseRadius * 0.7, p);
  }

  void _drawVectorFighter(Canvas canvas, Offset center, Size renderSize) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    double w = renderSize.width;
    double h = renderSize.height;

    // 엔진 분사 화염 이펙트 (맥동 효과)
    double flamePulse = 0.8 + 0.2 * sin(elapsedTime * 30.0);
    final Path flamePath = Path()
      ..moveTo(-w * 0.1, h * 0.38)
      ..lineTo(0, h * (0.38 + 0.18 * flamePulse))
      ..lineTo(w * 0.1, h * 0.38)
      ..close();
    canvas.drawPath(
      flamePath,
      Paint()
        ..color = Colors.cyanAccent
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 메인 주 날개 및 기체 몸통 (실버/스틸 블루)
    final Path mainBody = Path()
      ..moveTo(0, -h * 0.5) // 기수
      ..lineTo(w * 0.12, -h * 0.18)
      ..lineTo(w * 0.5, h * 0.18) // 우측 날개 끝
      ..lineTo(w * 0.18, h * 0.22)
      ..lineTo(w * 0.22, h * 0.42) // 우측 수평꼬리날개
      ..lineTo(0, h * 0.38)
      ..lineTo(-w * 0.22, h * 0.42) // 좌측 수평꼬리날개
      ..lineTo(-w * 0.18, h * 0.22)
      ..lineTo(-w * 0.5, h * 0.18) // 좌측 날개 끝
      ..lineTo(-w * 0.12, -h * 0.18)
      ..close();

    // 몸통 그라데이션
    Paint bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, -h * 0.5),
        Offset(0, h * 0.4),
        [const Color(0xFFE0F7FA), const Color(0xFF78909C), const Color(0xFF37474F)],
      );
    canvas.drawPath(mainBody, bodyPaint);

    // 기체 시안 외곽선 네온 링
    Paint outlinePaint = Paint()
      ..color = const Color(0xFF4DD0E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(mainBody, outlinePaint);

    // 캐노피 조종석 (밝은 하늘색)
    final Path canopy = Path()
      ..moveTo(0, -h * 0.3)
      ..cubicTo(w * 0.1, -h * 0.2, w * 0.1, 0, 0, h * 0.05)
      ..cubicTo(-w * 0.1, 0, -w * 0.1, -h * 0.2, 0, -h * 0.3);

    Paint canopyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, -h * 0.3),
        Offset(0, h * 0.05),
        [Colors.white, const Color(0xFF00E5FF)],
      );
    canvas.drawPath(canopy, canopyPaint);

    canvas.restore();
  }

  void _drawInvincibleShield(Canvas canvas, Offset center, double timeRemaining) {
    // 0.8초 미만으로 남았을 때 깜빡임 경고
    if (timeRemaining < 0.8 && ((timeRemaining * 15).toInt() % 2 == 0)) {
      return;
    }

    double pulse = 1.0 + 0.06 * sin(elapsedTime * 20.0);
    double radius = (kPlayerRenderSize.height * 0.6) * pulse;

    final Paint shieldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = Colors.cyanAccent.withValues(alpha: 0.85);

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.cyanAccent.withValues(alpha: 0.15);

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, shieldPaint);
  }

  void _drawBullet(Canvas canvas, Missile missile) {
    Offset pos = missile.position;
    Offset vel = missile.velocity;
    double speed = vel.distance;

    if (speed > 0) {
      Offset trailDir = -(vel / speed);
      double trailLength = 14.0;
      Offset trailEnd = pos + trailDir * trailLength;

      _bulletTrailPaint.strokeWidth = kBulletRadius * 1.4;
      _bulletTrailPaint.shader = ui.Gradient.linear(
        pos,
        trailEnd,
        [const Color(0xFFFF9800).withValues(alpha: 0.8), const Color(0x00FF5722)],
      );
      canvas.drawLine(pos, trailEnd, _bulletTrailPaint);
    }

    // 외곽 발광 원
    canvas.drawCircle(pos, kBulletRadius + 2.5, _bulletGlowPaint);
    // 중심 코어 원
    canvas.drawCircle(pos, kBulletRadius - 1.5, _bulletCorePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const NeoBrainLabApp());
}

class NeoBrainLabApp extends StatelessWidget {
  const NeoBrainLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BRAIN LAB : Reflex & Run',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF06B6D4),
          tertiary: Color(0xFF84CC16),
          surface: Color(0xFF131927),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainHomeScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// [1] 메인 홈 화면 (게임 3종 고정)
// -----------------------------------------------------------------------------
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int? _bestRabbitRun;
  int? _bestReflex;
  double? _best1to25;

  @override
  void initState() {
    super.initState();
    _loadBestRecords();
  }

  Future<void> _loadBestRecords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestRabbitRun = prefs.getInt('best_rabbit_run');
      _bestReflex = prefs.getInt('best_reflex');
      _best1to25 = prefs.getDouble('best_1to25');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'BRAIN LAB STUDIO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '순발력 & 피지컬 Lab',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131927),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Color(0xFF10B981)),
                  )
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 1. 토끼 탈출기
                    _buildModernGameCard(
                      tag: 'ACTION RUN',
                      title: '🐰 토끼 탈출기',
                      subtitle: '💩 똥은 점프! 🪨 돌멩이는 슬라이딩!\n산속을 달리는 스릴 만점 러닝 게임',
                      recordText: _bestRabbitRun != null ? '${_bestRabbitRun}m' : '미측정',
                      accentColor: const Color(0xFF84CC16),
                      gradient: const [Color(0xFF65A30D), Color(0xFF15803D)],
                      icon: Icons.directions_run_rounded,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const RabbitRunScreen()));
                        _loadBestRecords();
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. 3초 반응속도 테스트
                    _buildModernGameCard(
                      tag: 'NEURO SPEED',
                      title: '⚡ 3초 반응속도 테스트',
                      subtitle: '시각 자극에 반응하는 뇌의 속도를 ms 단위로 정밀 측정',
                      recordText: _bestReflex != null ? '${_bestReflex}ms' : '미측정',
                      accentColor: const Color(0xFF06B6D4),
                      gradient: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                      icon: Icons.speed_rounded,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const ReflexTestScreen()));
                        _loadBestRecords();
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. 1to25순발력 측정
                    _buildModernGameCard(
                      tag: 'FOCUS AGILITY',
                      title: '🧩 1to25순발력 측정',
                      subtitle: '1부터 25까지의 숫자를 최단 시간 내에 순서대로 터치',
                      recordText: _best1to25 != null ? '${_best1to25!.toStringAsFixed(2)}초' : '미측정',
                      accentColor: const Color(0xFF10B981),
                      gradient: const [Color(0xFF059669), Color(0xFF047857)],
                      icon: Icons.grid_view_rounded,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const OneToTwentyFiveScreen()));
                        _loadBestRecords();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF131927),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '최고 기록 달성 후 스코어 카드를 공유해보세요!',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
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
  }

  Widget _buildModernGameCard({
    required String tag,
    required String title,
    required String subtitle,
    required String recordText,
    required Color accentColor,
    required List<Color> gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF131927),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Text('BEST $recordText', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5), height: 1.3)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// [2] 토끼 탈출기 Screen & 3D Vector Bunny Painter
// -----------------------------------------------------------------------------
enum ObstacleType { poop, rock }

class Obstacle {
  double x;
  ObstacleType type;
  Obstacle({required this.x, required this.type});
}

class Cloud {
  double x;
  double y;
  double scale;
  Cloud({required this.x, required this.y, required this.scale});
}

class RabbitRunScreen extends StatefulWidget {
  const RabbitRunScreen({super.key});

  @override
  State<RabbitRunScreen> createState() => _RabbitRunScreenState();
}

class _RabbitRunScreenState extends State<RabbitRunScreen> {
  bool _isPlaying = false;
  bool _isGameOver = false;

  int _scoreDistance = 0;
  double _gameSpeed = 0.016;

  bool _isJumping = false;
  bool _isSliding = false;
  double _rabbitY = 0.0;
  int _animFrame = 0;

  bool _isHitShaking = false;

  List<Obstacle> _obstacles = [];
  List<Cloud> _clouds = [];
  Timer? _gameLoopTimer;
  Timer? _spawnTimer;
  Timer? _animTimer;

  @override
  void initState() {
    super.initState();
    _clouds = [
      Cloud(x: -0.6, y: 0.1, scale: 0.8),
      Cloud(x: 0.2, y: 0.2, scale: 1.2),
      Cloud(x: 0.8, y: 0.05, scale: 0.6),
    ];
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _scoreDistance = 0;
      _gameSpeed = 0.016;
      _rabbitY = 0.0;
      _isJumping = false;
      _isSliding = false;
      _isHitShaking = false;
      _obstacles.clear();
    });

    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _updateGame());

    _animTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (_isPlaying) {
        setState(() {
          _animFrame = (_animFrame + 1) % 4;
        });
      }
    });

    _spawnObstacleLoop();
  }

  void _spawnObstacleLoop() {
    if (!_isPlaying) return;
    final randomMs = Random().nextInt(800) + 1000;
    _spawnTimer = Timer(Duration(milliseconds: randomMs), () {
      if (_isPlaying) {
        final type = Random().nextBool() ? ObstacleType.poop : ObstacleType.rock;
        setState(() {
          _obstacles.add(Obstacle(x: 1.2, type: type));
        });
        _spawnObstacleLoop();
      }
    });
  }

  void _updateGame() {
    if (!_isPlaying) return;

    setState(() {
      _scoreDistance += 1;
      _gameSpeed += 0.000005;

      for (var cloud in _clouds) {
        cloud.x -= _gameSpeed * 0.2;
        if (cloud.x < -1.4) {
          cloud.x = 1.4;
          cloud.y = Random().nextDouble() * 0.2 + 0.05;
        }
      }

      if (_isJumping) {
        _rabbitY = -sin((_scoreDistance % 30) / 30.0 * pi) * 0.7;
        if ((_scoreDistance % 30) >= 29) {
          _isJumping = false;
          _rabbitY = 0.0;
        }
      }

      for (var ob in _obstacles) {
        ob.x -= _gameSpeed;
      }

      _obstacles.removeWhere((ob) => ob.x < -1.2);

      const rabbitX = -0.55;
      for (var ob in _obstacles) {
        if ((ob.x - rabbitX).abs() < 0.12) {
          if (ob.type == ObstacleType.poop && !_isJumping) {
            _triggerHitAndGameOver();
          }
          if (ob.type == ObstacleType.rock && !_isSliding) {
            _triggerHitAndGameOver();
          }
        }
      }
    });
  }

  void _triggerJump() {
    if (_isJumping || _isSliding || !_isPlaying) return;
    setState(() {
      _isJumping = true;
    });
  }

  void _triggerSlide() {
    if (_isSliding || _isJumping || !_isPlaying) return;
    setState(() {
      _isSliding = true;
    });

    Timer(const Duration(milliseconds: 550), () {
      if (mounted) {
        setState(() => _isSliding = false);
      }
    });
  }

  void _triggerHitAndGameOver() {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _animTimer?.cancel();

    setState(() {
      _isHitShaking = true;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isGameOver = true;
          _isHitShaking = false;
        });
        _saveRecord(_scoreDistance);
      }
    });
  }

  Future<void> _saveRecord(int record) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('best_rabbit_run');
    if (current == null || record > current) {
      await prefs.setInt('best_rabbit_run', record);
    }
  }

  List<Color> _calculateSkyGradient(int distance) {
    double cycle = (distance % 800) / 800.0;
    if (cycle < 0.35) {
      return [const Color(0xFF38BDF8), const Color(0xFFBAE6FD)];
    } else if (cycle < 0.6) {
      return [const Color(0xFFC026D3), const Color(0xFFF97316), const Color(0xFFFDE047)];
    } else if (cycle < 0.85) {
      return [const Color(0xFF0F172A), const Color(0xFF1E1B4B)];
    } else {
      return [const Color(0xFF4338CA), const Color(0xFFF43F5E), const Color(0xFFFDE68A)];
    }
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _animTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skyColors = _calculateSkyGradient(_scoreDistance);
    double cycle = (_scoreDistance % 800) / 800.0;
    bool isNight = cycle >= 0.6 && cycle < 0.85;

    return Scaffold(
      appBar: AppBar(
        title: const Text('토끼 탈출기', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.forest_rounded, color: Color(0xFF84CC16), size: 18),
                      const SizedBox(width: 6),
                      Text('산속 탐험 중', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6))),
                    ],
                  ),
                  Text('${_scoreDistance}m', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF84CC16))),
                ],
              ),
            ),

            // 산속 배경 게임 필드
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: skyColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(color: skyColors.first.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // 태양 / 달
                      Positioned(
                        top: 25,
                        right: 35,
                        child: isNight
                            ? Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF08A),
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Color(0xFFFEF08A), blurRadius: 15, spreadRadius: 2)],
                                ),
                              )
                            : Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFACC15),
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Color(0xFFFACC15), blurRadius: 20, spreadRadius: 4)],
                                ),
                              ),
                      ),

                      // 구름 배경
                      ..._clouds.map((cloud) {
                        return Align(
                          alignment: Alignment(cloud.x, -0.6 + cloud.y),
                          child: CustomPaint(
                            size: Size(70 * cloud.scale, 35 * cloud.scale),
                            painter: CloudPainter(isNight: isNight),
                          ),
                        );
                      }),

                      // 풍성한 3D 산맥 레이어
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MountainBackgroundPainter(isNight: isNight),
                        ),
                      ),

                      // 바닥 지면
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: isNight ? const Color(0xFF064E3B) : const Color(0xFF15803D),
                            border: const Border(top: BorderSide(color: Color(0xFF84CC16), width: 6)),
                          ),
                        ),
                      ),

                      if (_isHitShaking) Container(color: Colors.red.withOpacity(0.3)),

                      // 세밀하게 구현된 캐릭터 토끼
                      Align(
                        alignment: Alignment(-0.55, 0.54 + _rabbitY),
                        child: Transform.translate(
                          offset: Offset(_isHitShaking ? Random().nextDouble() * 10 - 5 : 0, 0),
                          child: CustomPaint(
                            size: _isSliding ? const Size(70, 42) : const Size(54, 72),
                            painter: DynamicBunnyPainter(
                              isJumping: _isJumping,
                              isSliding: _isSliding,
                              animFrame: _animFrame,
                            ),
                          ),
                        ),
                      ),

                      // 장애물
                      ..._obstacles.map((ob) {
                        final isPoop = ob.type == ObstacleType.poop;
                        return Align(
                          alignment: Alignment(ob.x, isPoop ? 0.65 : 0.60),
                          child: Text(
                            isPoop ? '💩' : '🪨',
                            style: TextStyle(fontSize: isPoop ? 30 : 34),
                          ),
                        );
                      }),

                      // 준비 화면
                      if (!_isPlaying && !_isGameOver) ...[
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🐰 산속 토끼 탈출기', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 6),
                              Text('💩 똥은 점프! 🪨 돌멩이는 슬라이딩!', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                              const SizedBox(height: 18),
                              _buildModern3DButton(
                                label: '달리기 시작 🚀',
                                color: const Color(0xFF84CC16),
                                shadowColor: const Color(0xFF4D7C0F),
                                onTap: _startGame,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 게임오버
                      if (_isGameOver) ...[
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withOpacity(0.92),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('💥 장애물 충돌!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                                const SizedBox(height: 8),
                                Text('달린 거리: ${_scoreDistance}m', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildModern3DButton(
                                      label: '다시하기',
                                      color: const Color(0xFF3B82F6),
                                      shadowColor: const Color(0xFF1D4ED8),
                                      onTap: _startGame,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildModern3DButton(
                                      label: '기록 공유',
                                      color: const Color(0xFF84CC16),
                                      shadowColor: const Color(0xFF4D7C0F),
                                      onTap: () => _showShareCard(context, '🐰 토끼 탈출기', '${_scoreDistance}m', '산속 대탈출 성공!'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ),

            // 하단 아케이드 컨트롤러
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildArcadeGameButton(
                      title: 'SLIDE',
                      subtitle: '🪨 돌멩이 회피',
                      icon: Icons.south_rounded,
                      buttonColor: const Color(0xFF0284C7),
                      shadowColor: const Color(0xFF0369A1),
                      onTap: _triggerSlide,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildArcadeGameButton(
                      title: 'JUMP',
                      subtitle: '💩 똥 회피',
                      icon: Icons.north_rounded,
                      buttonColor: const Color(0xFF84CC16),
                      shadowColor: const Color(0xFF4D7C0F),
                      onTap: _triggerJump,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArcadeGameButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color buttonColor,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setBtnState) {
        bool isPressed = false;
        return GestureDetector(
          onTapDown: (_) => setBtnState(() => isPressed = true),
          onTapUp: (_) {
            setBtnState(() => isPressed = false);
            onTap();
          },
          onTapCancel: () => setBtnState(() => isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            margin: EdgeInsets.only(top: isPressed ? 6 : 0, bottom: isPressed ? 0 : 6),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: isPressed
                  ? []
                  : [
                      BoxShadow(color: shadowColor, offset: const Offset(0, 6), blurRadius: 0),
                      BoxShadow(color: buttonColor.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 12),
                    ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.25), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                      Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.85))),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModern3DButton({
    required String label,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: shadowColor, borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// [토끼 디테일 렌더링 Painter] - 명확한 귀, 얼굴, 수염, 몸통, 꼬리 구현
// -----------------------------------------------------------------------------
class DynamicBunnyPainter extends CustomPainter {
  final bool isJumping;
  final bool isSliding;
  final int animFrame;

  DynamicBunnyPainter({
    required this.isJumping,
    required this.isSliding,
    required this.animFrame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final earInnerPaint = Paint()..color = const Color(0xFFFFB2C9)..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final cheekPaint = Paint()..color = const Color(0xFFFF8DA1)..style = PaintingStyle.fill;
    final eyePaint = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.fill;
    final eyeHighlight = Paint()..color = Colors.white..style = PaintingStyle.fill;

    if (isSliding) {
      // --- [슬라이딩 토끼] ---
      // 납작해진 몸통
      RRect body = RRect.fromRectAndRadius(
        Rect.fromLTWH(4, size.height * 0.35, size.width * 0.85, size.height * 0.55),
        const Radius.circular(18),
      );
      canvas.drawRRect(body, bodyPaint);
      canvas.drawRRect(body, strokePaint);

      // 뒤로 넘겨진 토끼 귀
      for (int i = 0; i < 2; i++) {
        canvas.save();
        canvas.translate(14, 14 + (i * 7));
        canvas.rotate(-0.35);
        RRect ear = RRect.fromRectAndRadius(const Rect.fromLTWH(-28, 0, 32, 10), const Radius.circular(6));
        canvas.drawRRect(ear, bodyPaint);
        canvas.drawRRect(ear, strokePaint);
        RRect inner = RRect.fromRectAndRadius(const Rect.fromLTWH(-24, 2.5, 24, 5), const Radius.circular(3));
        canvas.drawRRect(inner, earInnerPaint);
        canvas.restore();
      }

      // 얼굴 요소
      canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.5), 3.5, eyePaint);
      canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.48), 1.2, eyeHighlight);
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.62), 4.5, cheekPaint);

      // 동그란 토끼 꼬리
      canvas.drawCircle(Offset(0, size.height * 0.62), 6, bodyPaint);
      canvas.drawCircle(Offset(0, size.height * 0.62), 6, strokePaint);
    } else if (isJumping) {
      // --- [점프 토끼] ---
      canvas.save();

      // 위로 세워진 귀 (바람에 약 젖힘)
      for (int i = 0; i < 2; i++) {
        double xPos = (i == 0) ? size.width * 0.32 : size.width * 0.52;
        canvas.save();
        canvas.translate(xPos, size.height * 0.22);
        canvas.rotate(i == 0 ? -0.2 : 0.15);
        RRect ear = RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -34, 12, 34), const Radius.circular(8));
        canvas.drawRRect(ear, bodyPaint);
        canvas.drawRRect(ear, strokePaint);
        RRect inner = RRect.fromRectAndRadius(const Rect.fromLTWH(-3.5, -28, 7, 26), const Radius.circular(5));
        canvas.drawRRect(inner, earInnerPaint);
        canvas.restore();
      }

      // 동그란 몸통
      RRect body = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.22, size.width * 0.65, size.height * 0.58),
        const Radius.circular(24),
      );
      canvas.drawRRect(body, bodyPaint);
      canvas.drawRRect(body, strokePaint);

      // 눈 & 볼터치 & 수염
      double eyeX = size.width * 0.62;
      double eyeY = size.height * 0.42;
      canvas.drawCircle(Offset(eyeX, eyeY), 4, eyePaint);
      canvas.drawCircle(Offset(eyeX + 1.2, eyeY - 1.2), 1.3, eyeHighlight);
      canvas.drawCircle(Offset(size.width * 0.52, eyeY + 10), 5.5, cheekPaint);

      // 수염
      canvas.drawLine(Offset(eyeX + 4, eyeY + 4), Offset(eyeX + 14, eyeY + 2), strokePaint);
      canvas.drawLine(Offset(eyeX + 4, eyeY + 7), Offset(eyeX + 13, eyeY + 9), strokePaint);

      // 접은 다리
      canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.82), 6.5, bodyPaint);
      canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.82), 6.5, strokePaint);
      canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.82), 6.5, bodyPaint);
      canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.82), 6.5, strokePaint);

      // 꼬리
      canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.55), 6.5, bodyPaint);
      canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.55), 6.5, strokePaint);

      canvas.restore();
    } else {
      // --- [달리는 토끼] ---
      double bounce = (animFrame % 2 == 0 ? -3.0 : 3.0);
      double earAngleLeft = (animFrame % 2 == 0 ? -0.12 : 0.08);
      double earAngleRight = (animFrame % 2 == 0 ? 0.08 : -0.12);

      // 토끼 귀 (애니메이션 펄럭임)
      canvas.save();
      canvas.translate(size.width * 0.35, size.height * 0.28 + bounce);
      canvas.rotate(earAngleLeft);
      RRect leftEar = RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -32, 12, 32), const Radius.circular(8));
      canvas.drawRRect(leftEar, bodyPaint);
      canvas.drawRRect(leftEar, strokePaint);
      RRect leftInner = RRect.fromRectAndRadius(const Rect.fromLTWH(-3.5, -26, 7, 24), const Radius.circular(5));
      canvas.drawRRect(leftInner, earInnerPaint);
      canvas.restore();

      canvas.save();
      canvas.translate(size.width * 0.55, size.height * 0.28 + bounce);
      canvas.rotate(earAngleRight);
      RRect rightEar = RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -32, 12, 32), const Radius.circular(8));
      canvas.drawRRect(rightEar, bodyPaint);
      canvas.drawRRect(rightEar, strokePaint);
      RRect rightInner = RRect.fromRectAndRadius(const Rect.fromLTWH(-3.5, -26, 7, 24), const Radius.circular(5));
      canvas.drawRRect(rightInner, earInnerPaint);
      canvas.restore();

      // 몸통
      RRect body = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.25 + bounce, size.width * 0.65, size.height * 0.55),
        const Radius.circular(24),
      );
      canvas.drawRRect(body, bodyPaint);
      canvas.drawRRect(body, strokePaint);

      // 얼굴 & 수염
      double eyeX = size.width * 0.62;
      double eyeY = size.height * 0.42 + bounce;
      canvas.drawCircle(Offset(eyeX, eyeY), 4, eyePaint);
      canvas.drawCircle(Offset(eyeX + 1.2, eyeY - 1.2), 1.3, eyeHighlight);
      canvas.drawCircle(Offset(size.width * 0.52, eyeY + 10), 6, cheekPaint);

      canvas.drawLine(Offset(eyeX + 4, eyeY + 4), Offset(eyeX + 14, eyeY + 2), strokePaint);
      canvas.drawLine(Offset(eyeX + 4, eyeY + 7), Offset(eyeX + 13, eyeY + 9), strokePaint);

      // 교대 교차하는 발걸음
      double legOffset = (animFrame % 2 == 0) ? 7 : -7;
      canvas.drawCircle(Offset(size.width * 0.28 + legOffset, size.height * 0.8 + bounce), 6, bodyPaint);
      canvas.drawCircle(Offset(size.width * 0.28 + legOffset, size.height * 0.8 + bounce), 6, strokePaint);

      canvas.drawCircle(Offset(size.width * 0.62 - legOffset, size.height * 0.8 + bounce), 6, bodyPaint);
      canvas.drawCircle(Offset(size.width * 0.62 - legOffset, size.height * 0.8 + bounce), 6, strokePaint);

      // 꼬리
      canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.55 + bounce), 7, bodyPaint);
      canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.55 + bounce), 7, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant DynamicBunnyPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// 산 배경 Graphic Painter
// -----------------------------------------------------------------------------
class MountainBackgroundPainter extends CustomPainter {
  final bool isNight;

  MountainBackgroundPainter({required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final farMountainPaint = Paint()
      ..color = isNight ? const Color(0xFF1E293B) : const Color(0xFF86EFAC).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final farPath = Path();
    farPath.moveTo(0, size.height);
    farPath.lineTo(0, size.height * 0.55);
    farPath.quadraticBezierTo(size.width * 0.2, size.height * 0.35, size.width * 0.45, size.height * 0.5);
    farPath.quadraticBezierTo(size.width * 0.7, size.height * 0.6, size.width, size.height * 0.4);
    farPath.lineTo(size.width, size.height);
    farPath.close();
    canvas.drawPath(farPath, farMountainPaint);

    final midMountainPaint = Paint()
      ..color = isNight ? const Color(0xFF0F172A) : const Color(0xFF4ADE80).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final midPath = Path();
    midPath.moveTo(0, size.height);
    midPath.lineTo(0, size.height * 0.65);
    midPath.lineTo(size.width * 0.25, size.height * 0.48);
    midPath.lineTo(size.width * 0.55, size.height * 0.72);
    midPath.lineTo(size.width * 0.8, size.height * 0.52);
    midPath.lineTo(size.width, size.height * 0.68);
    midPath.lineTo(size.width, size.height);
    midPath.close();
    canvas.drawPath(midPath, midMountainPaint);
  }

  @override
  bool shouldRepaint(covariant MountainBackgroundPainter oldDelegate) => true;
}

class CloudPainter extends CustomPainter {
  final bool isNight;
  CloudPainter({required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isNight ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addOval(Rect.fromLTWH(0, size.height * 0.3, size.width * 0.6, size.height * 0.6));
    path.addOval(Rect.fromLTWH(size.width * 0.25, 0, size.width * 0.5, size.height * 0.8));
    path.addOval(Rect.fromLTWH(size.width * 0.45, size.height * 0.2, size.width * 0.5, size.height * 0.7));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// [3] 게임 2: 3초 반응속도 테스트 Screen
// -----------------------------------------------------------------------------
enum ReflexState { ready, waiting, go, tooEarly, result }

class ReflexTestScreen extends StatefulWidget {
  const ReflexTestScreen({super.key});

  @override
  State<ReflexTestScreen> createState() => _ReflexTestScreenState();
}

class _ReflexTestScreenState extends State<ReflexTestScreen> {
  ReflexState _state = ReflexState.ready;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  int _reactionTime = 0;

  void _startTest() {
    setState(() => _state = ReflexState.waiting);

    final delay = Random().nextInt(2500) + 1500;
    _timer = Timer(Duration(milliseconds: delay), () {
      if (mounted && _state == ReflexState.waiting) {
        setState(() => _state = ReflexState.go);
        _stopwatch.reset();
        _stopwatch.start();
      }
    });
  }

  void _handleTap() {
    if (_state == ReflexState.ready) {
      _startTest();
    } else if (_state == ReflexState.waiting) {
      _timer?.cancel();
      setState(() => _state = ReflexState.tooEarly);
    } else if (_state == ReflexState.go) {
      _stopwatch.stop();
      _reactionTime = _stopwatch.elapsedMilliseconds;
      _saveRecord(_reactionTime);
      setState(() => _state = ReflexState.result);
    } else if (_state == ReflexState.tooEarly || _state == ReflexState.result) {
      _startTest();
    }
  }

  Future<void> _saveRecord(int record) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('best_reflex');
    if (current == null || record < current) {
      await prefs.setInt('best_reflex', record);
    }
  }

  int _calculateBrainAge(int ms) {
    if (ms < 180) return 18;
    if (ms < 220) return 22;
    if (ms < 260) return 28;
    if (ms < 310) return 35;
    if (ms < 370) return 43;
    if (ms < 450) return 52;
    return 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget bodyContent;

    switch (_state) {
      case ReflexState.ready:
        bgColor = const Color(0xFF090D16);
        bodyContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF06B6D4).withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.touch_app_rounded, size: 48, color: Color(0xFF06B6D4)),
            ),
            const SizedBox(height: 24),
            const Text('터치하여 시작', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('화면이 초록색으로 바뀔 때 즉시 터치하세요!', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
          ],
        );
        break;

      case ReflexState.waiting:
        bgColor = const Color(0xFFE11D48);
        bodyContent = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('대기하세요...', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
            SizedBox(height: 8),
            Text('초록색 신호가 켜질 때까지 기다리세요', style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        );
        break;

      case ReflexState.go:
        bgColor = const Color(0xFF10B981);
        bodyContent = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('지금 터치!', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
          ],
        );
        break;

      case ReflexState.tooEarly:
        bgColor = const Color(0xFF131927);
        bodyContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text('너무 빨랐습니다!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('초록색으로 바뀐 후에 터치해주세요.\n터치하여 다시 시작하세요.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
          ],
        );
        break;

      case ReflexState.result:
        bgColor = const Color(0xFF090D16);
        final age = _calculateBrainAge(_reactionTime);
        bodyContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('REACTION TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 8),
            Text('${_reactionTime}ms', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF131927), borderRadius: BorderRadius.circular(20)),
              child: Text('측정 뇌 연령: $age세', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () => _showShareCard(context, '3초 반응속도 테스트', '${_reactionTime}ms', '신경 반응속도 뇌 연령 $age세'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('결과 카드 공유하기 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 16),
            Text('터치하여 다시 시도하기', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3))),
          ],
        );
        break;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('3초 반응속도 테스트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: SizedBox.expand(child: bodyContent),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// [4] 게임 3: 1to25순발력 측정 Screen
// -----------------------------------------------------------------------------
class OneToTwentyFiveScreen extends StatefulWidget {
  const OneToTwentyFiveScreen({super.key});

  @override
  State<OneToTwentyFiveScreen> createState() => _OneToTwentyFiveScreenState();
}

class _OneToTwentyFiveScreenState extends State<OneToTwentyFiveScreen> {
  List<int> _numbers = [];
  int _nextTarget = 1;
  bool _isPlaying = false;
  bool _isFinished = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  double _elapsed = 0.0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    final list = List.generate(25, (i) => i + 1)..shuffle();
    setState(() {
      _numbers = list;
      _nextTarget = 1;
      _isPlaying = false;
      _isFinished = false;
      _elapsed = 0.0;
    });
    _stopwatch.reset();
    _timer?.cancel();
  }

  void _onTileTap(int num) {
    if (_isFinished) return;

    if (!_isPlaying && num == 1) {
      _isPlaying = true;
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        if (mounted) {
          setState(() {
            _elapsed = _stopwatch.elapsedMilliseconds / 1000.0;
          });
        }
      });
    }

    if (_isPlaying && num == _nextTarget) {
      setState(() {
        _nextTarget++;

        if (_nextTarget > 25) {
          _stopwatch.stop();
          _timer?.cancel();
          _isPlaying = false;
          _isFinished = true;
          _saveRecord(_elapsed);
        }
      });
    }
  }

  Future<void> _saveRecord(double record) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getDouble('best_1to25');
    if (current == null || record < current) {
      await prefs.setDouble('best_1to25', record);
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
      appBar: AppBar(
        title: const Text('1to25순발력 측정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _resetGame),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF131927),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TARGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white.withOpacity(0.4))),
                        const SizedBox(height: 4),
                        Text(
                          _nextTarget <= 25 ? '$_nextTarget' : 'CLEAR!',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white.withOpacity(0.4))),
                        const SizedBox(height: 4),
                        Text(
                          '${_elapsed.toStringAsFixed(2)}s',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 25,
                    itemBuilder: (context, index) {
                      final num = _numbers[index];
                      final isCleared = num < _nextTarget;

                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: isCleared ? 0.15 : 1.0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onTileTap(num),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCleared ? Colors.transparent : const Color(0xFF131927),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCleared ? Colors.transparent : const Color(0xFF10B981).withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$num',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isCleared ? Colors.grey : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (_isFinished) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _showShareCard(context, '1to25순발력 측정', '${_elapsed.toStringAsFixed(2)}초', '최고의 집중력과 손가락 순발력!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('기록 공유하기 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// [5] 결과 카드 모달
// -----------------------------------------------------------------------------
void _showShareCard(BuildContext context, String title, String score, String evalText) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Color(0xFF131927),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withOpacity(0.35),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 12),
                Text(
                  score,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                  child: Text(evalText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 24),
                Text('BRAIN LAB CERTIFIED', style: TextStyle(fontSize: 9, letterSpacing: 3, color: Colors.white.withOpacity(0.4))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카드 저장 완료!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF090D16),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('카드 저장', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('공유 링크가 복사되었습니다!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('스토리 공유 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
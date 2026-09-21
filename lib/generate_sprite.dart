import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 1536x768 (256x256 per cell, 6 cols x 3 rows) 크기의 
/// 완전 투명 배경(Alpha 0) 토끼 스프라이트 시트 PNG를 생성하는 유틸리티
///
/// 주의: 현재 게임(main.dart)은 이 유틸리티가 만드는 균등 격자 시트가 아니라
/// assets/rabbitSpritesheet.png (669x373, 불균등 배치) 를 쓰고 있고,
/// 프레임 좌표를 main.dart 의 kRunFrames / kJumpFrames / kSlideFrames 에
/// 직접 적어 두었다. 이 유틸리티로 시트를 다시 만들어 교체한다면
/// 그 좌표표도 256x256 균등 격자에 맞게 함께 고쳐야 한다.
Future<void> generateAndSaveRabbitSpriteSheet(String savePath) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1536, 768));

  const double cell = 256.0;

  // ROW 0: RUN 01 ~ 06 (6 frames)
  for (int col = 0; col < 6; col++) {
    final center = Offset(col * cell + cell / 2, 0 * cell + cell / 2);
    _drawRabbitCharacter(canvas, center, state: 'RUN', frameIndex: col);
  }

  // ROW 1: JUMP 01 ~ 04 (4 frames)
  for (int col = 0; col < 4; col++) {
    final center = Offset(col * cell + cell / 2, 1 * cell + cell / 2);
    _drawRabbitCharacter(canvas, center, state: 'JUMP', frameIndex: col);
  }

  // ROW 2: SLIDE 01 ~ 04 (4 frames)
  for (int col = 0; col < 4; col++) {
    final center = Offset(col * cell + cell / 2, 2 * cell + cell / 2);
    _drawRabbitCharacter(canvas, center, state: 'SLIDE', frameIndex: col);
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(1536, 768);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  if (byteData != null) {
    final file = File(savePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    debugPrint("투명 스프라이트 시트 생성 완료: $savePath");
  }
}

void _drawRabbitCharacter(Canvas canvas, Offset center, {required String state, required int frameIndex}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);

  // 캐릭터 기본 묘사 변수
  double bodyY = 0;
  double bodyScaleY = 1.0;
  double bodyScaleX = 1.0;
  double earAngle = 0.0; 
  double legFrontOffset = 0.0;
  double legBackOffset = 0.0;

  if (state == 'RUN') {
    switch (frameIndex) {
      case 0: bodyY = 5; bodyScaleY = 0.9; bodyScaleX = 1.05; earAngle = 0.1; break;
      case 1: bodyY = 0; bodyScaleY = 1.0; bodyScaleX = 1.0; legBackOffset = -10; earAngle = -0.1; break;
      case 2: bodyY = -8; bodyScaleY = 1.05; bodyScaleX = 0.95; legFrontOffset = 10; legBackOffset = -10; earAngle = -0.2; break;
      case 3: bodyY = -3; bodyScaleY = 0.98; bodyScaleX = 1.02; legFrontOffset = 5; earAngle = 0.0; break;
      case 4: bodyY = 6; bodyScaleY = 0.88; bodyScaleX = 1.08; earAngle = 0.2; break;
      case 5: bodyY = 2; bodyScaleY = 0.95; bodyScaleX = 1.02; earAngle = 0.1; break;
    }
  } else if (state == 'JUMP') {
    switch (frameIndex) {
      case 0: bodyY = 10; bodyScaleY = 0.8; earAngle = 0.3; legBackOffset = -10; break;
      case 1: bodyY = -10; bodyScaleY = 1.15; bodyScaleX = 0.9; earAngle = -0.3; legBackOffset = -15; break;
      case 2: bodyY = -15; bodyScaleY = 0.95; bodyScaleX = 1.05; earAngle = -0.1; legFrontOffset = 8; legBackOffset = 8; break;
      case 3: bodyY = -2; bodyScaleY = 1.0; bodyScaleX = 1.0; earAngle = 0.1; legFrontOffset = 10; break;
    }
  } else if (state == 'SLIDE') {
    switch (frameIndex) {
      case 0: bodyY = 15; bodyScaleY = 0.7; bodyScaleX = 1.2; earAngle = 0.8; break;
      case 1: 
      case 2: bodyY = 25; bodyScaleY = 0.5; bodyScaleX = 1.4; earAngle = 1.2; break;
      case 3: bodyY = 10; bodyScaleY = 0.8; bodyScaleX = 1.1; earAngle = 0.5; break;
    }
  }

  // 1. 꼬리
  final tailPaint = Paint()..color = const Color(0xFFFFF0F5);
  canvas.drawCircle(Offset(-32 * bodyScaleX, 10 + bodyY), 10, tailPaint);

  // 2. 다리
  final legPaint = Paint()..color = const Color(0xFFFFF8F0);
  canvas.drawOval(Rect.fromLTWH(-15 + legBackOffset, 18 + bodyY, 18, 14), legPaint);
  canvas.drawOval(Rect.fromLTWH(8 + legFrontOffset, 20 + bodyY, 15, 12), legPaint);

  // 3. 몸통
  final bodyPaint = Paint()..color = const Color(0xFFFAFAFA);
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(-5, 8 + bodyY),
      width: 55 * bodyScaleX,
      height: 45 * bodyScaleY,
    ),
    bodyPaint,
  );

  // 4. 머리
  final headCenter = Offset(12, -15 + bodyY);
  canvas.drawCircle(headCenter, 28, bodyPaint);

  // 5. 볼터치
  final blushPaint = Paint()..color = const Color(0xFFFFB6C1).withOpacity(0.6);
  canvas.drawCircle(Offset(headCenter.dx + 12, headCenter.dy + 8), 6, blushPaint);

  // 6. 귀
  canvas.save();
  canvas.translate(headCenter.dx - 6, headCenter.dy - 22);
  canvas.rotate(earAngle);

  final earOuterPaint = Paint()..color = const Color(0xFFFAFAFA);
  final earInnerPaint = Paint()..color = const Color(0xFFFFC0CB);

  final earPath1 = Path()
    ..moveTo(-5, 0)
    ..quadraticBezierTo(-10, -35, 0, -40)
    ..quadraticBezierTo(10, -35, 5, 0)
    ..close();
  canvas.drawPath(earPath1, earOuterPaint);

  final earInnerPath1 = Path()
    ..moveTo(-2.5, -4)
    ..quadraticBezierTo(-5, -30, 0, -34)
    ..quadraticBezierTo(5, -30, 2.5, -4)
    ..close();
  canvas.drawPath(earInnerPath1, earInnerPaint);

  canvas.translate(8, 2);
  canvas.drawPath(earPath1, earOuterPaint);
  canvas.drawPath(earInnerPath1, earInnerPaint);
  canvas.restore();

  // 7. 눈
  final eyeCenter = Offset(headCenter.dx + 14, headCenter.dy - 3);
  final eyePaint = Paint()..color = const Color(0xFF1A1A1A);
  canvas.drawCircle(eyeCenter, 5.5, eyePaint);

  final eyeHighlight = Paint()..color = Colors.white;
  canvas.drawCircle(Offset(eyeCenter.dx + 1.5, eyeCenter.dy - 1.5), 2, eyeHighlight);

  // 8. 코
  final nosePaint = Paint()..color = const Color(0xFFFF69B4);
  canvas.drawCircle(Offset(headCenter.dx + 26, headCenter.dy + 3), 2.5, nosePaint);

  canvas.restore();
}
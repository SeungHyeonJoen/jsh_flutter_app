import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_fortune/main.dart';

/// 점프/슬라이드를 포함한 모든 프레임에서 토끼가 화면에 온전히 그려지는지 검증한다.
/// 스프라이트 시트를 6x3 균등 격자로 자르면 JUMP/SLIDE 에서 빈 여백이 잘려
/// 캐릭터가 사라지는데, 그 회귀를 이 테스트가 잡아낸다.
void main() {
  const int w = 900;
  const int h = 600;
  const int groundY = h - 40; // painter 의 groundY 와 동일
  const Size canvasSize = Size(900, 600);
  const Rect canvasRect = Rect.fromLTWH(0, 0, 900, 600);

  late ui.Image sheet;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final ByteData data = await rootBundle.load('assets/rabbitSpritesheet.png');
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    sheet = (await codec.getNextFrame()).image;
  });

  Future<Map<String, int>> measure(
    RabbitState state,
    int frame,
    double rabbitY,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, canvasRect);
    RabbitGamePainter(
      spriteSheet: sheet,
      rabbitY: rabbitY,
      rabbitState: state,
      currentFrame: frame,
      obstacles: const [],
      elapsedTime: 30.0, // 한낮 배경 (별 등 흰 픽셀이 섞이지 않도록)
      bgScrollOffset: 0,
    ).paint(canvas, canvasSize);

    final img = await recorder.endRecording().toImage(w, h);
    final px =
        (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();

    int count = 0, minY = 1 << 30, maxY = -1, minX = 1 << 30, maxX = -1;
    for (int y = 0; y < h; y++) {
      for (int x = 80; x < 220; x++) {
        final int i = (y * w + x) * 4;
        if (px[i] > 230 && px[i + 1] > 222 && px[i + 2] > 195) {
          count++;
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    return {
      'count': count,
      'minX': minX,
      'maxX': maxX,
      'minY': minY,
      'maxY': maxY,
    };
  }

  test('모든 상태/프레임에서 토끼가 렌더링되고 지면 위에 머문다', () async {
    final cases = <String, List<Object>>{};
    for (int f = 0; f < kRunFrames.length; f++) {
      cases['RUN $f'] = [RabbitState.run, f, 0.0];
    }
    for (int f = 0; f < kJumpFrames.length; f++) {
      // 해당 프레임이 재생되는 구간의 중간 시점 점프 높이
      final double p = (f + 0.5) / kJumpFrames.length;
      cases['JUMP $f'] = [RabbitState.jump, f, math.sin(p * math.pi) * 135.0];
    }
    for (int f = 0; f < kSlideFrames.length; f++) {
      cases['SLIDE $f'] = [RabbitState.slide, f, 0.0];
    }

    for (final e in cases.entries) {
      final m = await measure(
        e.value[0] as RabbitState,
        e.value[1] as int,
        e.value[2] as double,
      );

      // 1) 프레임이 비어 있지 않다 (빈 셀을 잘라오면 여기서 실패)
      expect(m['count']!, greaterThan(400), reason: '${e.key}: 토끼가 거의 안 보임 -> $m');
      // 2) 화면 위/아래로 잘리지 않는다
      expect(m['minY']!, greaterThanOrEqualTo(0), reason: '${e.key}: 위로 잘림 -> $m');
      expect(m['maxY']!, lessThan(h), reason: '${e.key}: 아래로 잘림 -> $m');
      // 3) 발이 지면 근처에 놓인다 (땅 밑으로 파고들지 않는다)
      expect(m['maxY']!, lessThanOrEqualTo(groundY + 6),
          reason: '${e.key}: 지면 아래로 내려감 -> $m');
      // 4) 히트박스(x 115~165) 부근에 머문다
      expect(m['minX']!, greaterThan(90), reason: '${e.key}: 너무 왼쪽 -> $m');
      expect(m['maxX']!, lessThan(215), reason: '${e.key}: 너무 오른쪽 -> $m');

      // ignore: avoid_print
      print('${e.key.padRight(8)} -> $m');
    }
  });
}

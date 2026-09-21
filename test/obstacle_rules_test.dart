import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:daily_fortune/main.dart';

/// 장애물 규칙 검증
///  - 땅 장애물(💩)  : 점프로만 넘는다
///  - 공중 장애물(낙석): 슬라이드로만 지난다 (점프하면 반드시 부딪힌다)
void main() {
  // 토끼(115~165)와 확실히 겹치는 x 위치
  const double overlapX = 130.0;
  const double maxJumpHeight = 135.0;

  /// 점프 궤적 전체를 촘촘히 훑는다.
  List<double> jumpArc() => List<double>.generate(
        201,
        (i) => math.sin(i / 200 * math.pi) * maxJumpHeight,
      );

  bool hit(RabbitState state, double y, ObstacleType type) => rabbitHitsObstacle(
        state: state,
        rabbitY: y,
        type: type,
        obstacleX: overlapX,
      );

  group('땅 장애물 (💩)', () {
    test('달리면 부딪힌다', () {
      expect(hit(RabbitState.run, 0, ObstacleType.ground), isTrue);
    });

    test('슬라이드로는 피할 수 없다', () {
      expect(hit(RabbitState.slide, 0, ObstacleType.ground), isTrue);
    });

    test('점프 궤적 어딘가에는 확실히 넘는 구간이 있다', () {
      final safe = jumpArc().where((y) => !hit(RabbitState.jump, y, ObstacleType.ground));
      expect(safe, isNotEmpty);
      // 최고점에서는 반드시 안전해야 한다
      expect(hit(RabbitState.jump, maxJumpHeight, ObstacleType.ground), isFalse);
    });
  });

  group('공중 장애물 (낙석)', () {
    test('달리면 부딪힌다', () {
      expect(hit(RabbitState.run, 0, ObstacleType.air), isTrue);
    });

    test('슬라이드하면 안전하게 지나간다', () {
      expect(hit(RabbitState.slide, 0, ObstacleType.air), isFalse);
    });

    test('점프로는 절대 피할 수 없다 (궤적의 모든 지점에서 충돌)', () {
      for (final y in jumpArc()) {
        expect(hit(RabbitState.jump, y, ObstacleType.air), isTrue,
            reason: '점프 높이 ${y.toStringAsFixed(1)} 에서 낙석을 피해버림');
      }
    });
  });

  test('슬라이드 여유와 달리기 충돌 마진이 충분하다', () {
    // 슬라이드 키(28) 와 낙석 아랫면(42) 사이 여유
    expect(kAirObsBottom - kRabbitSlideHeight, greaterThanOrEqualTo(10));
    // 달리는 키(55)가 낙석 아랫면(42)보다 확실히 높다
    expect(kRabbitRunHeight - kAirObsBottom, greaterThanOrEqualTo(10));
    // 최대 점프(135) + 토끼 키(55) 가 낙석 윗면(175)을 넘지 못한다
    expect(maxJumpHeight, lessThan(kAirObsTop));
  });
}

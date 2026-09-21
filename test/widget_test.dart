// 앱이 정상적으로 뜨고 메인 메뉴가 그려지는지 확인하는 스모크 테스트.

import 'package:flutter_test/flutter_test.dart';

import 'package:daily_fortune/main.dart';

void main() {
  testWidgets('메인 메뉴에 3종 게임이 모두 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(const MultiGameApp());

    expect(find.text('원하시는 게임을 선택하세요'), findsOneWidget);
    expect(find.textContaining('토끼 탈출기'), findsOneWidget);
    expect(find.textContaining('3초 반응속도 테스트'), findsOneWidget);
    expect(find.textContaining('1to25 순발력 측정'), findsOneWidget);
  });
}

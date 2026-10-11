import 'package:flutter_test/flutter_test.dart';

import 'package:imposter_flutter_project/main.dart';

void main() {
  testWidgets('zeigt die Spielkonfiguration und startet eine Runde',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pumpAndSettle();

    expect(find.text('IMPOSTER'), findsOneWidget);
    expect(find.text('SPIEL STARTEN'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.ensureVisible(find.text('SPIEL STARTEN'));
    await tester.tap(find.text('SPIEL STARTEN'));
    await tester.pumpAndSettle();

    expect(find.text('Bereit für die Runde?'), findsOneWidget);
    expect(find.text('5 Spieler • 1 Imposter • Alle'), findsOneWidget);
  });
}

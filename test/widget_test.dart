import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ummahconnect/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: UmmahConnectApp(),
      ),
    );

    // Verify app renders
    expect(find.byType(UmmahConnectApp), findsOneWidget);
  });
}

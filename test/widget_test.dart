import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitra_pos/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders Splash screen initially with Mitra Digital POS title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MitraPosApp(),
      ),
    );

    // Verify that our app renders Splash screen title
    expect(find.text('Mitra Digital POS'), findsOneWidget);
  });
}

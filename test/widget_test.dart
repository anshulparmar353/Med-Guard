import 'package:flutter_test/flutter_test.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/main.dart';

/// Fake AuthBloc (minimal stub)
class FakeAuthBloc {}

void main() {
  testWidgets('App starts on Splash screen', (WidgetTester tester) async {
    // Create fake notifier (no real bloc needed)
    final authNotifier = AuthNotifier(FakeAuthBloc() as dynamic);

    final router = AppGoRouter.createRouter(authNotifier);

    await tester.pumpWidget(MyApp(router: router));

    await tester.pumpAndSettle();

    // Check SplashPage renders
    expect(find.textContaining('Splash'), findsWidgets);
  });
}
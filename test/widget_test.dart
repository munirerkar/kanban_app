import 'package:flutter_test/flutter_test.dart';
import 'package:kanban_project/main.dart';
import 'package:kanban_project/viewmodels/auth_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts with auth bootstrap state', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final authViewModel = AuthViewModel();
    await authViewModel.checkLoginStatus();

    await tester.pumpWidget(MyApp(authViewModel: authViewModel));
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('shows the save user form', (WidgetTester tester) async {
    await tester.pumpWidget(const UserApp());

    expect(find.text('Збереження користувача'), findsOneWidget);
    expect(find.text('Зберегти'), findsOneWidget);
  });
}

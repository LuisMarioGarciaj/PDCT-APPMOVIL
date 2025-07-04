import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdct_appmovil/main.dart';

void main() {
  testWidgets('LoginPage smoke test', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify LoginPage shows 'Bienvenido'
    expect(find.text('Bienvenido'), findsOneWidget);

    // Enter valid credentials
    await tester.enterText(find.byType(TextFormField).first, 'admin@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, '1234');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    // After login, should find 'Cámara apagada' placeholder
    expect(find.text('Cámara apagada'), findsOneWidget);
  });
}

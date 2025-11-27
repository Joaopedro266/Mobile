import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planetas_astros_firebase/views/home_page.dart';

void main() {
  testWidgets('Verifica se a HomePage carrega corretamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));

    expect(find.text('Planetas e Astros'), findsOneWidget);

    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

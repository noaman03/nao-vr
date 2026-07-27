import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nao_vr/main.dart';

void main() {
  testWidgets('configures the NAO VR application title', (tester) async {
    late BuildContext buildContext;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          buildContext = context;
          return const SizedBox.shrink();
        },
      ),
    );

    final app = const MyApp().build(buildContext) as MaterialApp;

    expect(app.title, 'NAO VR');
    expect(app.home, isA<MainNavigationPage>());
  });
}

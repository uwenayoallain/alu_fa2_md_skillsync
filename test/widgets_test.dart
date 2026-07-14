import 'package:fa2/core/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PrimaryButton shows spinner and disables while busy',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PrimaryButton(label: 'Apply', busy: true, onPressed: () => taps++),
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Apply'), findsNothing);
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('SkillPicker toggles suggestions and adds custom skills',
      (tester) async {
    List<String> selected = [];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: SkillPicker(
              selected: selected,
              suggestions: const ['Flutter', 'Figma'],
              onChanged: (s) => setState(() => selected = s),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Flutter'));
    await tester.pump();
    expect(selected, ['Flutter']);

    await tester.enterText(find.byType(TextField), 'Kinyarwanda');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(selected, ['Flutter', 'Kinyarwanda']);
  });
}

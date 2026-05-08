import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_story/main.dart';

void main() {
  testWidgets('VoiceStory AI Splash Screen Smoke Test', (WidgetTester tester) async {
    // 1. Setup the test environment
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    // 2. Build our app and PROVIDE the missing parameter
    // Change 'VoiceStoryApp' to whatever your class is named in main.dart
    await tester.pumpWidget(const VoiceStoryApp(isLoggedIn: false));

    // 3. Allow animations and transitions to finish
    await tester.pumpAndSettle();

    // 4. Verify your UI elements
    expect(find.textContaining("Speak your story"), findsOneWidget);
    expect(find.text('Start!'), findsOneWidget);

    // 5. Clean up
    addTearDown(tester.view.resetPhysicalSize);
  });
}
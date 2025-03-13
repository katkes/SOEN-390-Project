import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/profile/profile_screen.dart'; // Replace 'your_file_name.dart' with your actual file name

void main() {
  testWidgets('UserProfileScreen displays initials when photoUrl is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserProfileScreen(
          displayName: 'Test User',
          email: 'test@example.com',
          photoUrl: null,
          onSignOut: () {},
          onViewCalendar: () {},
        ),
      ),
    );

    expect(find.text('T'), findsOneWidget);
    final CircleAvatar avatar = tester.firstWidget(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
  });

  testWidgets('UserProfileScreen displays loading indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserProfileScreen(
          displayName: 'Test User',
          email: 'test@example.com',
          photoUrl: null,
          onSignOut: () {},
          onViewCalendar: () {},
          isLoading: true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('UserProfileScreen displays error message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserProfileScreen(
          displayName: 'Test User',
          email: 'test@example.com',
          photoUrl: null,
          onSignOut: () {},
          onViewCalendar: () {},
          errorMessage: 'An error occurred',
        ),
      ),
    );

    expect(find.text('An error occurred'), findsOneWidget);
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.style?.color == Colors.red),
        findsOneWidget);
  });

  testWidgets('UserProfileScreen calls onSignOut and onViewCalendar',
      (WidgetTester tester) async {
    bool signOutCalled = false;
    bool viewCalendarCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: UserProfileScreen(
          displayName: 'Test User',
          email: 'test@example.com',
          photoUrl: null,
          onSignOut: () {
            signOutCalled = true;
          },
          onViewCalendar: () {
            viewCalendarCalled = true;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();
    expect(signOutCalled, isTrue);

    await tester.tap(find.text('View My Calendar'));
    await tester.pump();
    expect(viewCalendarCalled, isTrue);
  });

  testWidgets(
      'UserProfileScreen displays default User when displayName is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserProfileScreen(
          displayName: null,
          email: 'test@example.com',
          photoUrl: null,
          onSignOut: () {},
          onViewCalendar: () {},
        ),
      ),
    );

    expect(find.text('User'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
  });
}

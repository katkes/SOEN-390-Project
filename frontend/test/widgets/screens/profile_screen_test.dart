import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/profile/profile_screen.dart';

void main() {
  testWidgets('UserProfileScreen displays initials when photoUrl is null',
      (WidgetTester tester) async {
    // Test: UserProfileScreen is built with a null photoUrl.
    // Expected: The user's initial is displayed in the CircleAvatar, and the CircleAvatar's backgroundImage is null.
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
    // Test: UserProfileScreen is built with isLoading set to true.
    // Expected: The CircularProgressIndicator is displayed.

    // where specific error messages or loading states might be implemented
    // differently. Update the test accordingly when the real implementation
    // is in place. This is for task 4.1.1
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
    // Test: UserProfileScreen is built with an error message.
    // Expected: The error message is displayed, and it is displayed with red color.
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
    // Test: UserProfileScreen's logout and view calendar buttons are tapped.
    // Expected: The onSignOut and onViewCalendar callbacks are called.
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
    // Test: UserProfileScreen is built with a null displayName.
    // Expected: The default display name "User" and the default initial "?" are shown.
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

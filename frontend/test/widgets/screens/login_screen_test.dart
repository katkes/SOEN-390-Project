import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/screens/login/login_screen.dart';
import 'package:soen_390/widgets/google_sign_in_button.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('LoginScreen Tests', () {
    late MockVoidCallback mockOnGoogleSignIn;

    setUp(() {
      mockOnGoogleSignIn = MockVoidCallback();
    });

    testWidgets('renders correctly with default state',
        (WidgetTester tester) async {
      // Test: Verifies that the LoginScreen renders correctly with the default state.
      // Expected: Welcome text, description text, GoogleSignInButton, and logo should be present.
      // Expected: CircularProgressIndicator and error message should not be present.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onGoogleSignIn: mockOnGoogleSignIn.call,
            isLoading: false,
          ),
        ),
      );

      expect(find.text('Welcome to Your Calendar'), findsOneWidget);
      expect(
          find.text('Sign in with Google to access your calendars and events'),
          findsOneWidget);
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Container), findsWidgets); //checking for containers.
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });

    testWidgets('displays loading indicator when isLoading is true',
        (WidgetTester tester) async {
      // Test: Verifies that the LoginScreen displays a loading indicator when isLoading is true.
      // Expected: CircularProgressIndicator should be present.
      // Expected: GoogleSignInButton should not be present.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onGoogleSignIn: mockOnGoogleSignIn.call,
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(GoogleSignInButton), findsNothing);
    });

    testWidgets('displays error message when errorMessage is not null',
        (WidgetTester tester) async {
      // Test: Verifies that the LoginScreen displays an error message when errorMessage is not null.
      // Expected: The error message text should be present.
      // Expected: Containers should be present.
      const errorMessage = 'Authentication failed.';
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onGoogleSignIn: mockOnGoogleSignIn.call,
            isLoading: false,
            errorMessage: errorMessage,
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('calls onGoogleSignIn when button is tapped',
        (WidgetTester tester) async {
      // Test: Verifies that the onGoogleSignIn callback is called when the GoogleSignInButton is tapped.
      // Expected: The mockOnGoogleSignIn callback should be called once.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onGoogleSignIn: mockOnGoogleSignIn.call,
            isLoading: false,
          ),
        ),
      );

      await tester.tap(find.byType(GoogleSignInButton));
      verify(mockOnGoogleSignIn()).called(1);
    });

    testWidgets(
        'does not display error message when errorMessage is null or empty',
        (WidgetTester tester) async {
      // Test: Verifies that the LoginScreen does not display an error message when errorMessage is null or empty.
      // Expected: The error message text should not be present.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onGoogleSignIn: mockOnGoogleSignIn.call,
            isLoading: false,
            errorMessage: null,
          ),
        ),
      );

      expect(find.text('Authentication failed.'), findsNothing);
    });

    testWidgets('displays the correct logo', (WidgetTester tester) async {
      // Test: Verifies that the LoginScreen displays the correct logo.
      // Expected: The Icons.calendar_month_rounded icon should be present.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onGoogleSignIn: mockOnGoogleSignIn.call,
            isLoading: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });

    testWidgets('displays the correct welcome text',
        (WidgetTester tester) async {
      // Test: Verifies that the LoginScreen displays the correct welcome text.
      // Expected: The "Welcome to Your Calendar" text should be present.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onGoogleSignIn: mockOnGoogleSignIn.call,
            isLoading: false,
          ),
        ),
      );
      expect(find.text('Welcome to Your Calendar'), findsOneWidget);
    });

    testWidgets('displays the correct description text',
        (WidgetTester tester) async {
      // Test: Verifies that the LoginScreen displays the correct description text.
      // Expected: The "Sign in with Google to access your calendars and events" text should be present.
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onGoogleSignIn: mockOnGoogleSignIn.call,
            isLoading: false,
          ),
        ),
      );
      expect(
          find.text('Sign in with Google to access your calendars and events'),
          findsOneWidget);
    });
  });
}

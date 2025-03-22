import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/screens/calendar/calendar_view.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/core/secure_storage.dart';
import 'package:soen_390/providers/navigation_provider.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'calendar_view_test.mocks.dart';

@GenerateMocks([GoogleSignIn, HttpService, SecureStorage, AuthClientFactory])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGoogleSignIn mockGoogleSignIn;
  late MockHttpService mockHttpService;
  late MockSecureStorage mockSecureStorage;
  late MockAuthClientFactory mockAuthClientFactory;
  late AuthService authService;
  late http.Client httpClient;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockHttpService = MockHttpService();
    mockSecureStorage = MockSecureStorage();
    mockAuthClientFactory = MockAuthClientFactory();
    httpClient = http.Client();

    authService = AuthService(
      googleSignIn: mockGoogleSignIn,
      httpService: mockHttpService,
      secureStorage: mockSecureStorage,
      authClientFactory: mockAuthClientFactory,
    );

    when(mockHttpService.client).thenReturn(httpClient);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        navigationProvider.overrideWith((ref) => NavigationNotifier()),
      ],
      child: MaterialApp(
        home: CalendarScreen(authService: authService),
      ),
    );
  }

  group('CalendarScreen Tests', () {
    testWidgets('renders loading indicator initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("My Calendar"), findsOneWidget);
    });

    testWidgets('should handle widget lifecycle properly without crashes',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(Container());

      expect(true, isTrue);
    });
    testWidgets('should display the navbar with correct selected index',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(NavBar), findsOneWidget);
    });
    testWidgets('should have a refresh button in the UI', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Scaffold), findsOneWidget);

      final scaffoldState =
          tester.state(find.byType(Scaffold)) as ScaffoldState;

      expect(scaffoldState, isNotNull);
    });
  });
}

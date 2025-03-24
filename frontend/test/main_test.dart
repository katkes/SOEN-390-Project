import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/core/secure_storage.dart';
import 'package:soen_390/main.dart';
import 'package:soen_390/providers/service_providers.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/building_info_api.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';

/// Test suite for the main application and services in the SOEN-390 project.
///
/// This file contains tests for the core components of the application, including:
/// - The integration of various mocked services such as `RouteService`, `HttpService`, and `LocationService`.
/// - Tests for UI elements like the `MaterialApp`, `NavigationBar`, and different screens in the app.
/// - Mocking of network requests and handling of map tiles for testing purposes.
///
/// The tests use the `flutter_test` package for widget testing, the `mockito` package
/// for mocking service classes, and `flutter_riverpod` for overriding providers in
/// the test environment. The purpose of these tests is to ensure that the application
/// initializes correctly with the mocked dependencies and that the main UI components
/// are rendered and navigated correctly.

// Generate mocks for the interfaces - using GenerateNiceMocks for better behavior
@GenerateNiceMocks([
  MockSpec<IRouteService>(),
  MockSpec<HttpService>(),
  MockSpec<http.Client>(),
  MockSpec<BuildingPopUps>(),
  MockSpec<GoogleMapsApiClient>(),
  MockSpec<GeocodingService>(),
  MockSpec<LocationService>(),
  MockSpec<AuthService>(),
  MockSpec<SecureStorage>(),
  MockSpec<auth.AuthClient>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
])
import 'main_test.mocks.dart';

// Create a test wrapper for overriding providers
class TestWrapper extends StatelessWidget {
  final Widget child;
  final IRouteService mockRouteService;
  final HttpService mockHttpService;
  final GoogleMapsApiClient mockMapsApiClient;
  final BuildingPopUps mockBuildingPopUps;
  final GeocodingService mockGeocodingService;
  final LocationService mockLocationService;

  const TestWrapper({
    required this.child,
    required this.mockRouteService,
    required this.mockHttpService,
    required this.mockMapsApiClient,
    required this.mockBuildingPopUps,
    required this.mockGeocodingService,
    required this.mockLocationService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        routeServiceProvider.overrideWithValue(mockRouteService),
        httpServiceProvider.overrideWithValue(mockHttpService),
        buildingToCoordinatesProvider.overrideWithValue(mockGeocodingService),
        locationServiceProvider.overrideWithValue(mockLocationService),
      ],
      child: child,
    );
  }
}

void main() {
  late MockIRouteService mockRouteService;
  late MockHttpService mockHttpService;
  late MockClient mockHttpClient;
  late MockGoogleMapsApiClient mockMapsApiClient;
  late MockBuildingPopUps mockBuildingPopUps;
  late MockGeocodingService mockGeocodingService;
  late MockLocationService mockLocationService;
  late MockAuthService mockAuthService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late MockAuthClient mockAuthClient;

  setUpAll(() async {
    // Mock dotenv to avoid loading the actual ..env file in tests
    dotenv.testLoad(fileInput: '''
      GOOGLE_MAPS_API_KEY=mocked_api_key
    ''');
  });

  setUp(() {
    mockRouteService = MockIRouteService();
    mockHttpService = MockHttpService();
    mockHttpClient = MockClient();
    mockMapsApiClient = MockGoogleMapsApiClient();
    mockBuildingPopUps = MockBuildingPopUps();
    mockGeocodingService = MockGeocodingService();
    mockLocationService = MockLocationService();
    mockAuthService = MockAuthService();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockAuthClient = MockAuthClient();

    // Stub the Google Sign-In behavior
    when(mockAuthService.googleSignIn).thenReturn(mockGoogleSignIn);
    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleSignInAuthentication);
    when(mockGoogleSignInAuthentication.accessToken)
        .thenReturn("mock_access_token");
    when(mockGoogleSignInAuthentication.idToken).thenReturn("mock_id_token");
    when(mockGoogleSignIn.currentUser).thenReturn(mockGoogleSignInAccount);

    // Stub the signIn method in AuthService to return a mock AuthClient
    when(mockAuthService.signIn()).thenAnswer((_) async => mockAuthClient);

    // Set up mock behavior for getRoute method
    when(mockRouteService.getRoute(
      from: anyNamed('from'),
      to: anyNamed('to'),
    )).thenAnswer((_) async {
      return RouteResult(
        distance: 1000.0,
        duration: 600.0,
        routePoints: [
          const LatLng(45.497856, -73.579588),
          const LatLng(45.498000, -73.580000),
        ],
        steps: [
          StepResult(
            distance: 500.0,
            duration: 300.0,
            instruction: "Turn left onto Main St.",
            maneuver: "turn-left",
            startLocation: const LatLng(45.497856, -73.579588),
            endLocation: const LatLng(45.498000, -73.580000),
          ),
        ],
      );
    });

    // Mock the client property on the HttpService
    when(mockHttpService.client).thenReturn(mockHttpClient);

    // Add transparent PNG mock response for map tiles
    final transparentPixelPng = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82
    ]);

    when(mockHttpClient.readBytes(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => transparentPixelPng);
  });

  testWidgets('Main initializes with mocked dependencies',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      TestWrapper(
        mockRouteService: mockRouteService,
        mockHttpService: mockHttpService,
        mockBuildingPopUps: mockBuildingPopUps,
        mockMapsApiClient: mockMapsApiClient,
        mockGeocodingService: mockGeocodingService,
        mockLocationService: mockLocationService,
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pumpAndSettle();

    final MyHomePage homePage =
        tester.widget<MyHomePage>(find.byType(MyHomePage));
    expect(homePage.routeService, equals(mockRouteService));
    expect(homePage.httpService, equals(mockHttpService));
  });

  testWidgets('UI renders correctly with mocked services',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      TestWrapper(
        mockRouteService: mockRouteService,
        mockHttpService: mockHttpService,
        mockBuildingPopUps: mockBuildingPopUps,
        mockMapsApiClient: mockMapsApiClient,
        mockGeocodingService: mockGeocodingService,
        mockLocationService: mockLocationService,
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Campus Map'), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets);
  });

  testWidgets('Navigation works with mocked services',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      TestWrapper(
        mockRouteService: mockRouteService,
        mockHttpService: mockHttpService,
        mockBuildingPopUps: mockBuildingPopUps,
        mockMapsApiClient: mockMapsApiClient,
        mockGeocodingService: mockGeocodingService,
        mockLocationService: mockLocationService,
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    expect(navigationBar, findsOneWidget);

    final profileDestination = find.byWidgetPredicate(
      (widget) => widget is NavigationDestination && widget.label == 'Profile',
      description: 'Profile navigation destination',
    );
    expect(profileDestination, findsOneWidget);
  });

  test('Providers return mocked instances in container', () {
    final container = ProviderContainer(
      overrides: [
        routeServiceProvider.overrideWithValue(mockRouteService),
        httpServiceProvider.overrideWithValue(mockHttpService),
      ],
    );

    final routeService = container.read(routeServiceProvider);
    final httpService = container.read(httpServiceProvider);

    expect(routeService, equals(mockRouteService));
    expect(httpService, equals(mockHttpService));
  });

  test('RouteService getRoute mock works', () async {
    final result = await mockRouteService.getRoute(
      from: const LatLng(45.0, -73.0),
      to: const LatLng(46.0, -74.0),
    );

    expect(result, isNotNull);
    expect(result!.distance, equals(1000.0));
    expect(result.duration, equals(600.0));
    expect(result.routePoints.length, equals(2));

    verify(mockRouteService.getRoute(
      from: anyNamed('from'),
      to: anyNamed('to'),
    )).called(1);
  });
  testWidgets('Location updates on user movement', (WidgetTester tester) async {
    await tester.pumpWidget(
      TestWrapper(
        mockRouteService: mockRouteService,
        mockHttpService: mockHttpService,
        mockBuildingPopUps: mockBuildingPopUps,
        mockMapsApiClient: mockMapsApiClient,
        mockGeocodingService: mockGeocodingService,
        mockLocationService: mockLocationService,
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Home Page'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('_handleCampusSelected updates selected campus',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      TestWrapper(
        mockRouteService: mockRouteService,
        mockHttpService: mockHttpService,
        mockBuildingPopUps: mockBuildingPopUps,
        mockMapsApiClient: mockMapsApiClient,
        mockGeocodingService: mockGeocodingService,
        mockLocationService: mockLocationService,
        child: const MyApp(),
      ),
    );

    final myHomePageState =
        tester.state<MyHomePageState>(find.byType(MyHomePage));
    const testCampus = 'Loyola';

    myHomePageState.handleCampusSelected(testCampus);
    await tester.pump();

    expect(myHomePageState.selectedCampus, testCampus);
  });

  testWidgets('_handleLocationChanged updates current location',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      TestWrapper(
        mockRouteService: mockRouteService,
        mockHttpService: mockHttpService,
        mockBuildingPopUps: mockBuildingPopUps,
        mockMapsApiClient: mockMapsApiClient,
        mockLocationService: mockLocationService,
        mockGeocodingService: mockGeocodingService,
        child: const MyApp(),
      ),
    );

    final myHomePageState =
        tester.state<MyHomePageState>(find.byType(MyHomePage));
    final newLocation = const LatLng(45.5100, -73.5700);

    myHomePageState.handleLocationChanged(newLocation);
    await tester.pump();

    expect(myHomePageState.currentLocation, newLocation);
  });
  testWidgets('signIn sets isLoggedIn to true', (WidgetTester tester) async {
    // Create a mock AuthClient to return
    final mockAuthClient = MockAuthClient();

    // Stub the signIn method to return the mocked AuthClient
    when(mockAuthService.signIn()).thenAnswer((_) async => mockAuthClient);

    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
      home: MyHomePage(
        title: 'Test App',
        routeService: mockRouteService,
        httpService: mockHttpService,
        authService: mockAuthService,
      ),
    )));

    final myHomePageState =
        tester.state<MyHomePageState>(find.byType(MyHomePage));

    // Call the signIn method
    await myHomePageState.signIn();
    await tester.pumpAndSettle(); // Allow UI to update

    // Check that isLoggedIn is set to true
    expect(myHomePageState.isLoggedIn, true);
  });

  testWidgets('signOut sets isLoggedIn to false', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MyHomePage(
            title: 'Test App',
            routeService: mockRouteService,
            httpService: mockHttpService,
            authService: MockAuthService(),
          ),
        ),
      ),
    );

    final myHomePageState =
        tester.state<MyHomePageState>(find.byType(MyHomePage));

    myHomePageState.signIn();
    await tester.pumpAndSettle();

    myHomePageState.signOut();
    await tester.pumpAndSettle();

    expect(myHomePageState.isLoggedIn, false);
  });
}

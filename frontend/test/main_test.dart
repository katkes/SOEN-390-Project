import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:soen_390/main.dart';
import 'package:soen_390/providers/service_providers.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/widgets/nav_bar.dart';

// Generate mocks for the interfaces - using GenerateNiceMocks for better behavior
@GenerateNiceMocks([
  MockSpec<IRouteService>(),
  MockSpec<HttpService>(),
  MockSpec<http.Client>()
])
import 'main_test.mocks.dart';

// Create a test wrapper for overriding providers
class TestWrapper extends StatelessWidget {
  final Widget child;
  final IRouteService mockRouteService;
  final HttpService mockHttpService;

  const TestWrapper({
    required this.child,
    required this.mockRouteService,
    required this.mockHttpService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        routeServiceProvider.overrideWithValue(mockRouteService),
        httpServiceProvider.overrideWithValue(mockHttpService),
      ],
      child: child,
    );
  }
}

void main() {
  late MockIRouteService mockRouteService;
  late MockHttpService mockHttpService;
  late MockClient mockHttpClient;

  setUp(() {
    mockRouteService = MockIRouteService();
    mockHttpService = MockHttpService();
    mockHttpClient = MockClient();

    // Set up mock behavior for getRoute method
    when(mockRouteService.getRoute(
      from: anyNamed('from'),
      to: anyNamed('to'),
    )).thenAnswer((_) async {
      return RouteResult(
        distance: 1000.0,
        duration: 600.0,
        routePoints: [
          LatLng(45.497856, -73.579588),
          LatLng(45.498000, -73.580000),
        ],
      );
    });

    // Mock the client property on the HttpService
    // This is the key fix for the first error
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
    // Wrap MyApp with our test wrapper that injects the mocks
    await tester.pumpWidget(
      TestWrapper(
        mockRouteService: mockRouteService,
        mockHttpService: mockHttpService,
        child: const MyApp(),
      ),
    );

    // Verify MyApp is in the widget tree
    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Allow the widget tree to build completely
    await tester.pumpAndSettle();

    // Find MyHomePage and verify it's using our mocked dependencies
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
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Test that UI elements are properly rendered
    expect(find.text('Campus Map'), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets);
  });

  testWidgets('Navigation works with mocked services',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      TestWrapper(
        mockRouteService: mockRouteService,
        mockHttpService: mockHttpService,
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Find the NavigationBar
    final navigationBar = find.byType(NavigationBar);
    expect(navigationBar, findsOneWidget);

    // Find and tap the Profile navigation destination
    final profileDestination = find.byWidgetPredicate(
      (widget) => widget is NavigationDestination && widget.label == 'Profile',
      description: 'Profile navigation destination',
    );
    expect(profileDestination, findsOneWidget);

    // Tap the profile destination
    await tester.tap(profileDestination);
    await tester.pumpAndSettle();

    // Verify navigation happened
    expect(find.text('Profile Page'), findsOneWidget);
  });

  test('Providers return mocked instances in container', () {
    final container = ProviderContainer(
      overrides: [
        routeServiceProvider.overrideWithValue(mockRouteService),
        httpServiceProvider.overrideWithValue(mockHttpService),
      ],
    );

    // Verify the providers return our mocked instances
    final routeService = container.read(routeServiceProvider);
    final httpService = container.read(httpServiceProvider);

    expect(routeService, equals(mockRouteService));
    expect(httpService, equals(mockHttpService));
  });

  test('RouteService getRoute mock works', () async {
    // Test that our mock behaves as expected
    final result = await mockRouteService.getRoute(
      from: LatLng(45.0, -73.0),
      to: LatLng(46.0, -74.0),
    );

    expect(result, isNotNull);
    expect(result!.distance, equals(1000.0));
    expect(result.duration, equals(600.0));
    expect(result.routePoints.length, equals(2));

    // Verify the mock was called with any parameters
    verify(mockRouteService.getRoute(
      from: anyNamed('from'),
      to: anyNamed('to'),
    )).called(1);
  });
}

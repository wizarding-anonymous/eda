import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant_booking_app/domain/entities/venue.dart';
import 'package:restaurant_booking_app/presentation/widgets/venue_card.dart';

void main() {
  group('VenueCard', () {
    late Venue testVenue;

    setUp(() {
      testVenue = const Venue(
        id: '1',
        name: 'Test Restaurant',
        description: 'A great test restaurant',
        address: Address(
          street: 'Test Street',
          city: 'Test City',
        ),
        coordinates: LatLng(latitude: 55.7558, longitude: 37.6176),
        photos: ['https://example.com/photo1.jpg'],
        rating: 4.5,
        reviewCount: 100,
        categories: ['Italian', 'Pizza'],
        cuisine: 'Italian',
        priceLevel: PriceLevel.moderate,
        openingHours: OpeningHours(hours: {}),
        amenities: [],
        isOpen: true,
        distance: 1.2,
      );
    });

    Widget createTestWidget(Venue venue) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: VenueCard(venue: venue),
          ),
        ),
      );
    }

    testWidgets('should display venue name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testVenue));

      expect(find.text('Test Restaurant'), findsOneWidget);
    });

    testWidgets('should display venue rating', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testVenue));

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(100)'), findsOneWidget);
    });

    testWidgets('should display venue cuisine and price level',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testVenue));

      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('₽₽'), findsOneWidget);
    });

    testWidgets('should display venue address', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testVenue));

      expect(find.text('Test Street, Test City'), findsOneWidget);
    });

    testWidgets('should display distance when available',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testVenue));

      expect(find.text('1.2 км'), findsOneWidget);
    });

    testWidgets('should display open status', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testVenue));

      expect(find.text('Открыто'), findsOneWidget);
    });

    testWidgets('should display closed status', (WidgetTester tester) async {
      final closedVenue = testVenue.copyWith(isOpen: false);
      await tester.pumpWidget(createTestWidget(closedVenue));

      expect(find.text('Закрыто'), findsOneWidget);
    });

    testWidgets('should display categories', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testVenue));

      expect(find.text('Italian, Pizza'), findsOneWidget);
    });

    testWidgets('should show placeholder image when no photos',
        (WidgetTester tester) async {
      final venueWithoutPhotos = testVenue.copyWith(photos: []);
      await tester.pumpWidget(createTestWidget(venueWithoutPhotos));

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('should handle tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testVenue));

      await tester.tap(find.byType(VenueCard));
      await tester.pump();

      // Should show snackbar with venue name
      expect(find.text('Открыть Test Restaurant'), findsOneWidget);
    });

    testWidgets('should display correct price level symbols',
        (WidgetTester tester) async {
      // Test budget price level
      final budgetVenue = testVenue.copyWith(priceLevel: PriceLevel.budget);
      await tester.pumpWidget(createTestWidget(budgetVenue));
      expect(find.text('₽'), findsOneWidget);

      // Test expensive price level
      final expensiveVenue =
          testVenue.copyWith(priceLevel: PriceLevel.expensive);
      await tester.pumpWidget(createTestWidget(expensiveVenue));
      await tester.pump();
      expect(find.text('₽₽₽'), findsOneWidget);

      // Test luxury price level
      final luxuryVenue = testVenue.copyWith(priceLevel: PriceLevel.luxury);
      await tester.pumpWidget(createTestWidget(luxuryVenue));
      await tester.pump();
      expect(find.text('₽₽₽₽'), findsOneWidget);
    });
  });
}

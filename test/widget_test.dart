import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('Startup screen opens the course finder', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SCHOOL MAP'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();

    expect(find.text('COURSE FINDER'), findsOneWidget);
  });

  testWidgets('Tapping Starks Hall opens its location page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CourseFinderScreen()));

    final starks = find.text('Starks Hall');
    await tester.scrollUntilVisible(
      starks,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(starks);
    // SVG loading shows a spinner, so pump a fixed time instead of settling.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(BuildingLocationScreen), findsOneWidget);
    expect(find.text('STARKS HALL'), findsOneWidget);
    // Location image plus the campus names image.
    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(
      find.text('The Library (3), is the starting Destination to Starks Hall.'),
      findsOneWidget,
    );
    expect(find.text('Red Dot → Destination Start'), findsOneWidget);
    expect(find.text('Purple Dot → Destination Finish'), findsOneWidget);
  });

  test('every building has a location image file that exists', () {
    for (final id in buildings.keys) {
      final location = buildingLocations[id];
      expect(location, isNotNull, reason: 'No location for building $id');
      expect(
        File(location!.image).existsSync(),
        isTrue,
        reason: 'Missing file ${location.image} for ${buildings[id]}',
      );
    }
    expect(File(campusLocationsImage).existsSync(), isTrue);
  });

  test('searchCourses matches course codes and subject names', () {
    final byCode = searchCourses('csc 101');
    expect(byCode.single.code, 'CSC');
    expect(byCode.single.number, '101');

    final byName = searchCourses('Accounting');
    expect(byName.map((r) => r.code), contains('ACC'));
  });
}

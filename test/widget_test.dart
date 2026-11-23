import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';
import 'package:my_app/parking.dart';

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

  testWidgets('PARKING button on the start screen opens TigerSpot',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('START'), findsOneWidget);

    await tester.tap(find.text('PARKING'));
    await tester.pumpAndSettle();

    expect(find.text('TIGERSPOT'), findsOneWidget);
    expect(find.text('Know Before You Park.'), findsOneWidget);
  });

  testWidgets('TigerSpot parking flow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ParkingScreen()));

    Future<void> tapText(String text) async {
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    await tapText('LOG IN');
    expect(find.text('Dashboard'), findsOneWidget);

    // Can't park before registering a vehicle.
    await tapText('Find a Parking Spot');
    await tester.tap(find.byKey(const Key('spot-A-104')));
    await tester.pumpAndSettle();
    expect(find.text('ACTION REQUIRED: Register vehicle first!'),
        findsOneWidget);

    // Registration needs a plate.
    await tapText('My Vehicle');
    await tapText('Submit Registration');
    expect(find.text('Enter your license plate first.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'ABC-123');
    await tapText('Submit Registration');
    expect(find.text('Status: VERIFIED'), findsOneWidget);
    await tapText('Back to Home');
    expect(find.text('Vehicle registered! You can now park.'), findsOneWidget);

    // Occupied space is refused.
    await tapText('Find a Parking Spot');
    await tester.tap(find.byKey(const Key('spot-A-105')));
    await tester.pumpAndSettle();
    expect(find.text('Sorry, space A-105 is occupied or invalid.'),
        findsOneWidget);

    // Park in A-104, which then shows as occupied.
    await tapText('Find a Parking Spot');
    await tapText('A-104 (AVAILABLE)');
    expect(find.text('ACTIVE SESSION'), findsOneWidget);
    expect(find.textContaining('Spot: A-104'), findsOneWidget);

    await tapText('[DEMO] Trigger Geofence Exit');
    expect(find.textContaining('Did you leave spot A-104?'), findsOneWidget);

    // Signing out frees the space again.
    await tapText('SIGN OUT OF PARKING');
    expect(find.text('You are signed out. Space is available.'),
        findsOneWidget);
    await tapText('Find a Parking Spot');
    expect(find.text('A-104 (AVAILABLE)'), findsOneWidget);

    // Scanning accepts lowercase IDs.
    await tapText('Back to Home');
    await tapText('Scan QR Code');
    await tester.enterText(find.byType(TextField), 'a-106');
    await tapText('Simulate Scan');
    expect(find.textContaining('Spot: A-106'), findsOneWidget);
  });

  test('CSC program of study matches the program sheet', () {
    // Course counts per semester, as on the sheet.
    int count(int year, int semester) => cscCourses
        .where((c) => c.year == year && c.semester == semester)
        .length;
    expect([count(1, 1), count(1, 2)], [2, 2]);
    expect([count(2, 1), count(2, 2)], [3, 3]);
    expect([count(3, 1), count(3, 2)], [4, 3]);
    expect([count(4, 1), count(4, 2)], [4, 4]);

    // No course number listed twice.
    final numbers = cscCourses.map((c) => c.number).whereType<String>();
    expect(numbers.toSet().length, numbers.length);

    expect(cscCourses.every((c) => c.credits == 3), isTrue);
  });

  test('searchCourses uses real CSC course titles', () {
    final java = searchCourses('CSC 237').single;
    expect(java.course!.title, 'Java Programming');
    expect(java.course!.yearName, 'Junior Year');
    expect(java.course!.semesterName, 'First Semester');

    // 138 is a Sophomore course even though the number starts with 1.
    expect(searchCourses('csc138').single.course!.yearName, 'Sophomore Year');

    // Search by title.
    expect(searchCourses('java').first.number, '237');
    expect(
      searchCourses('data').map((r) => r.number),
      containsAll(['333', '339', '434']),
    );

    // A CSC number not on the sheet still finds the department.
    final unknown = searchCourses('CSC 101').single;
    expect(unknown.course, isNull);
    expect(unknown.dept.name, 'Computer Science');
  });

  testWidgets('Searching CSC shows the full program of study',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CourseFinderScreen()));
    await tester.enterText(find.byType(TextField), 'CSC');
    await tester.pump();

    expect(find.text('Program of Study in Computer Science'), findsOneWidget);
    expect(find.text('Intro to Computing and Prog. Concept'), findsOneWidget);
    expect(find.text('CSC Elective'), findsOneWidget);

    // Tapping a course searches for it.
    await tester.tap(find.text('Digital Logic'));
    await tester.pump();
    expect(find.text('CSC 133 - Digital Logic'), findsOneWidget);
    expect(find.text('Freshman Year · First Semester · 3 credits'),
        findsOneWidget);
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

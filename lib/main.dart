import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'csc_courses.dart';
import 'parking.dart';

export 'csc_courses.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Map',
      theme: ThemeData(brightness: Brightness.light, fontFamily: 'Arial'),
      darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: 'Arial'),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: StartupScreen(
        isDarkMode: isDarkMode,
        onThemeToggle: toggleTheme,
      ),
    );
  }
}

class StartupScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const StartupScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    const lightBackground = Color(0xFFFFD84D);
    const lightDots = Color(0xFFE8BE32);
    const darkBackground = Color(0xFF211832);
    const darkDots = Color(0xFF332447);

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // DOT PATTERN
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 230,
              child: CustomPaint(
                painter: DotPatternPainter(
                  dotColor: isDarkMode ? darkDots : lightDots,
                ),
              ),
            ),

            // THEME BUTTON
            Positioned(
              top: 15,
              right: 15,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onThemeToggle,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF332447)
                          : const Color(0xFFFFE57A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDarkMode
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      size: 30,
                      color: isDarkMode
                          ? const Color(0xFFFFD84D)
                          : const Color(0xFF5B4312),
                    ),
                  ),
                ),
              ),
            ),

            // SCHOOL LOGO
            Align(
              alignment: const Alignment(0, -0.48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/school_logo.png',
                    width: 190,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SCHOOL MAP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF382900),
                    ),
                  ),
                ],
              ),
            ),

            // START -> Course Finder,  PARKING -> TigerSpot
            Positioned(
              left: 0,
              right: 0,
              bottom: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuButton(
                    context,
                    'START',
                    (_) => const CourseFinderScreen(),
                  ),
                  const SizedBox(width: 14),
                  _menuButton(
                    context,
                    'PARKING',
                    (_) => const ParkingScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context,
    String label,
    WidgetBuilder page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: page));
      },
      child: Container(
        width: 150,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDarkMode
                  ? const Color(0xFF211832)
                  : const Color(0xFF292000),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// COURSE DATA  (edit these to correct buildings)
// =====================================================

// Building numbers match the official Benedict campus map.
const Map<int, String> buildings = {
  1: 'Roslyn Clark Artis Administration Building',
  2: 'Antisdel Chapel',
  3: 'Library (LRC/BC Cares)',
  4: 'Duckett Hall',
  5: 'Starks Hall',
  6: 'Alumni Hall',
  7: 'Bacoats Hall',
  8: 'Fine Arts Building',
  9: 'HRC Arena - Gymnasium',
  10: 'Antisdel House',
  11: 'Morgan Hall',
  12: 'Pratt Hall',
  13: 'Admissions - Gressette Welcome Center',
  14: 'David H. Swinton Campus Center',
  15: 'Bookstore/Broadcast Center Building',
  16: 'Parking Garage',
  17: 'Physical Plant',
  18: 'Benedict College Police Department',
  19: 'Health Center',
  20: 'Business Development Center (BDC)',
  21: 'Lamar Building',
  22: 'Fitness Center',
  23: 'Charlie W. Johnson Stadium',
  24: 'Softball Field',
  25: 'Baseball Field',
  26: 'Athletic Ticket Office',
  27: 'Music Industry Building',
};

class BuildingLocation {
  final String image;
  // Most routes start at the Library (red dot). When true, the location page
  // shows "The Library (3), is the starting Destination to <building>."
  final bool startsAtLibrary;
  const BuildingLocation(this.image, {this.startsAtLibrary = true});

  String? startNoteFor(String buildingName) => startsAtLibrary
      ? 'The Library (3), is the starting Destination to $buildingName.'
      : null;
}

// Location images for buildings. Tapping a building that has one opens it.
// Keys match the building numbers in `buildings` above.
const Map<int, BuildingLocation> buildingLocations = {
  1: BuildingLocation('assets/RoslynBuilding.svg'),
  2: BuildingLocation('assets/AntisdelChapel.svg'),
  // The Library's route starts somewhere else, so no Library note here.
  3: BuildingLocation('assets/Library.svg', startsAtLibrary: false),
  4: BuildingLocation('assets/Duckett.svg'),
  5: BuildingLocation('assets/StarksLocationNew.svg'),
  6: BuildingLocation('assets/Alumni.svg'),
  7: BuildingLocation('assets/Bacoats.svg'),
  8: BuildingLocation('assets/FineArts.svg'),
  9: BuildingLocation('assets/Gym.svg'),
  10: BuildingLocation('assets/AntisdelHosue.svg'),
  11: BuildingLocation('assets/Morgan.svg'),
  12: BuildingLocation('assets/Pratt.svg'),
  13: BuildingLocation('assets/Admissions.svg'),
  14: BuildingLocation('assets/Swinton.svg'),
  15: BuildingLocation('assets/Bookstore.svg'),
  16: BuildingLocation('assets/Parking.svg'),
  17: BuildingLocation('assets/Plannt.svg'),
  18: BuildingLocation('assets/PoliceDepartment.svg'),
  19: BuildingLocation('assets/HealthCenter.svg'),
  20: BuildingLocation('assets/BusinessDevelopment.svg'),
  21: BuildingLocation('assets/Lamar.svg'),
  22: BuildingLocation('assets/Fitness.svg'),
  23: BuildingLocation('assets/Charlie.svg'),
  24: BuildingLocation('assets/Softball.svg'),
  25: BuildingLocation('assets/BaseBall.svg'),
  26: BuildingLocation('assets/AthleticTicket.svg'),
  27: BuildingLocation('assets/MusicIndustry.svg'),
};

// Dot colors used in the location images (matched to the SVGs).
const Color startDotColor = Color(0xFFFF0000);
const Color finishDotColor = Color(0xFF672BA7);

// Shown next to every building's location image: the campus map with names.
const String campusLocationsImage = 'assets/NewCampusKey.svg';

class Dept {
  final String name;
  final List<int> buildingIds;
  final String area;
  const Dept(this.name, this.buildingIds, this.area);
}

// Department matches are best guesses. Confirm with your schedule/advisor.
const Map<String, Dept> departments = {
  'ACC': Dept('Accounting', [11], 'School of Business'),
  'BUS': Dept('Business Administration', [11], 'School of Business'),
  'BAD': Dept('Business Administration', [11], 'School of Business'),
  'ECO': Dept('Economics', [11], 'School of Business'),
  'MGT': Dept('Management', [11], 'School of Business'),
  'MKT': Dept('Marketing', [11], 'School of Business'),
  'FIN': Dept('Finance', [11], 'School of Business'),
  'CSC': Dept('Computer Science', [5], 'Science & Technology'),
  'CIS': Dept('Computer Information Systems', [5], 'Science & Technology'),
  'MAT': Dept('Mathematics', [5], 'Science & Technology'),
  'BIO': Dept('Biology', [5], 'Science & Technology'),
  'CHM': Dept('Chemistry', [5], 'Science & Technology'),
  'PHY': Dept('Physics', [5], 'Science & Technology'),
  'ENV': Dept('Environmental Science', [5], 'Science & Technology'),
  'ENG': Dept('English', [4], 'Humanities'),
  'HIS': Dept('History', [4], 'Humanities'),
  'PHI': Dept('Philosophy', [4], 'Humanities'),
  'REL': Dept('Religion', [2, 4], 'Humanities'),
  'SPA': Dept('Spanish', [4], 'Humanities'),
  'FRE': Dept('French', [4], 'Humanities'),
  'HUM': Dept('Humanities', [4], 'Humanities'),
  'PSY': Dept('Psychology', [12], 'Social Sciences'),
  'SOC': Dept('Sociology', [12], 'Social Sciences'),
  'POS': Dept('Political Science', [12], 'Social Sciences'),
  'CRJ': Dept('Criminal Justice', [12], 'Social Sciences'),
  'SWK': Dept('Social Work', [12], 'Social Sciences'),
  'EDU': Dept('Education', [7], 'Education'),
  'ECE': Dept('Early Childhood Education', [7], 'Education'),
  'PED': Dept('Physical Education', [9, 22], 'Education / Athletics'),
  'HPE': Dept('Health & Physical Education', [9, 22], 'Education / Athletics'),
  'MUS': Dept('Music', [27, 8], 'Fine Arts'),
  'ART': Dept('Art', [8], 'Fine Arts'),
  'THE': Dept('Theatre', [8], 'Fine Arts'),
  'MCM': Dept('Mass Communications', [15], 'Broadcast Center'),
  'COM': Dept('Communications', [15], 'Broadcast Center'),
  'UNV': Dept('University / Freshman Seminar', [3], 'Student Success'),
  'HON': Dept('Honors', [3], 'Honors'),
  'ROT': Dept('ROTC', [1], 'Military Science'),
};

class CourseResult {
  final String code;
  final String? number;
  final Dept dept;
  // Set when the course is in the program of study (title, year, credits).
  final Course? course;
  const CourseResult(this.code, this.number, this.dept, [this.course]);
}

String levelOf(String number) {
  final n = int.tryParse(number.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  if (n < 200) return 'Freshman-level (100)';
  if (n < 300) return 'Sophomore-level (200)';
  if (n < 400) return 'Junior-level (300)';
  if (n < 500) return 'Senior-level (400)';
  return 'Advanced';
}

List<CourseResult> searchCourses(String input) {
  final t = input.trim().toUpperCase();
  if (t.isEmpty) return [];

  final m = RegExp(r'^([A-Z]{2,4})\s*-?\s*(\d{2,3}[A-Z]?)?').firstMatch(t);
  if (m != null && departments.containsKey(m.group(1))) {
    final code = m.group(1)!;
    final number = m.group(2);
    return [
      CourseResult(code, number, departments[code]!, findCourse(code, number)),
    ];
  }

  // Search course titles, e.g. "Java" -> CSC 237 Java Programming.
  // Needs 3+ letters so one letter doesn't match every course.
  final byTitle = t.length < 3
      ? <CourseResult>[]
      : cscCourses
          .where((c) => c.number != null && c.title.toUpperCase().contains(t))
          .map((c) => CourseResult(c.code, c.number, departments[c.code]!, c));

  // Fall back to searching by subject name, e.g. "Accounting"
  final byDept = departments.entries
      .where((e) {
        final n = e.value.name.toUpperCase();
        return n.contains(t) || t.contains(n);
      })
      .map((e) => CourseResult(e.key, null, e.value));

  return [...byTitle, ...byDept];
}

// =====================================================
// COURSE FINDER SCREEN
// =====================================================

class CourseFinderScreen extends StatefulWidget {
  const CourseFinderScreen({super.key});

  @override
  State<CourseFinderScreen> createState() => _CourseFinderScreenState();
}

class _CourseFinderScreenState extends State<CourseFinderScreen> {
  final TextEditingController controller = TextEditingController();
  List<CourseResult> results = [];
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    setState(() {
      query = value;
      results = searchCourses(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final background =
        dark ? const Color(0xFF211832) : const Color(0xFFFFD84D);
    final cardColor = dark ? const Color(0xFF332447) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF382900);
    final accent = dark ? const Color(0xFFFFD84D) : const Color(0xFF4B2E83);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'COURSE FINDER',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SEARCH BAR
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(color: textColor, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Paste a course (e.g. CSC 237)',
                  hintStyle: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(Icons.search, color: accent),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close, color: accent),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // RESULTS
            if (query.isNotEmpty && results.isEmpty)
              _card(
                cardColor,
                Text(
                  'No match. Try a code like CSC 237 or a subject name.\n\n'
                  'Known prefixes: ${departments.keys.join(", ")}',
                  style: TextStyle(color: textColor),
                ),
              ),

            ...results.map(
              (r) => _card(
                cardColor,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.course != null
                          ? '${r.course!.fullCode} - ${r.course!.title}'
                          : [r.code, r.number, '-', r.dept.name]
                              .whereType<String>()
                              .join(' '),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.course != null
                          ? '${r.dept.name} · ${r.dept.area}'
                          : r.dept.area,
                      style: TextStyle(color: textColor),
                    ),
                    if (r.course != null)
                      Text(
                        '${r.course!.yearName} · ${r.course!.semesterName} · '
                        '${r.course!.credits} credits',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      )
                    else if (r.number != null)
                      Text(
                        levelOf(r.number!),
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),

                    // Searching "CSC" on its own shows the full program.
                    if (r.code == 'CSC' && r.number == null) ...[
                      const SizedBox(height: 14),
                      _programOfStudy(textColor, accent),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'Find it here:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...r.dept.buildingIds.map(
                      (id) => _buildingRow(id, textColor),
                    ),
                  ],
                ),
              ),
            ),

            // BUILDING LIST
            const SizedBox(height: 8),
            _card(
              cardColor,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus buildings',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: accent,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...buildings.keys.map((id) => _buildingRow(id, textColor)),
                  const SizedBox(height: 4),
                  Text(
                    'Numbers match the official campus map.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Building matches are best guesses. Confirm your room in '
              'your schedule or with your advisor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The CSC courses laid out like the program sheet: year -> semester -> list.
  // Tapping a course searches for it.
  Widget _programOfStudy(Color textColor, Color accent) {
    final children = <Widget>[
      Text(
        'Program of Study in Computer Science',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: textColor,
          fontSize: 15,
        ),
      ),
    ];

    for (var year = 1; year <= 4; year++) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 2),
        child: Text(
          yearNames[year - 1].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: accent,
            letterSpacing: 1,
          ),
        ),
      ));

      for (var semester = 1; semester <= 2; semester++) {
        final courses = cscCourses
            .where((c) => c.year == year && c.semester == semester)
            .toList();
        children.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Text(
            semester == 1 ? 'First Semester' : 'Second Semester',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ));

        for (final c in courses) {
          final row = Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    c.fullCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(c.title, style: TextStyle(color: textColor)),
                ),
                Text(
                  '${c.credits}',
                  style: TextStyle(color: textColor.withValues(alpha: 0.7)),
                ),
              ],
            ),
          );

          children.add(c.number == null
              ? row
              : InkWell(
                  onTap: () {
                    controller.text = c.fullCode;
                    onChanged(c.fullCode);
                  },
                  child: row,
                ));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _card(Color color, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildingRow(int id, Color textColor) {
    final location = buildingLocations[id];
    final imagePath = location?.image;
    final name = buildings[id] ?? 'Building $id';

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF0C24B),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$id',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF292000),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: textColor,
                fontWeight:
                    imagePath != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (imagePath != null)
            Icon(Icons.chevron_right, color: textColor.withValues(alpha: 0.6)),
        ],
      ),
    );

    if (imagePath == null) return row;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BuildingLocationScreen(
              buildingId: id,
              buildingName: name,
              imagePath: imagePath,
              startNote: location?.startNoteFor(name),
            ),
          ),
        );
      },
      child: row,
    );
  }
}

// =====================================================
// BUILDING LOCATION SCREEN
// =====================================================

class BuildingLocationScreen extends StatelessWidget {
  final int buildingId;
  final String buildingName;
  final String imagePath;
  final String? startNote;

  const BuildingLocationScreen({
    super.key,
    required this.buildingId,
    required this.buildingName,
    required this.imagePath,
    this.startNote,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? const Color(0xFF211832) : const Color(0xFFFFD84D);
    final textColor = dark ? Colors.white : const Color(0xFF382900);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          buildingName.toUpperCase(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // START NOTE
            if (startNote != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: finishDotColor, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  startNote!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF292000),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final location = _zoomableSvg(imagePath);
                  final names = _zoomableSvg(campusLocationsImage);

                  // Wide screens: location on the left, names on the right.
                  // Narrow phones: not enough width, so stack them.
                  if (constraints.maxWidth >= 600) {
                    return Row(
                      children: [
                        Expanded(child: location),
                        const SizedBox(width: 12),
                        Expanded(child: names),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Expanded(child: location),
                      const SizedBox(height: 12),
                      Expanded(child: names),
                    ],
                  );
                },
              ),
            ),

            // KEY
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF332447) : Colors.white,
                border: Border.all(color: finishDotColor, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _keyRow(startDotColor, 'Red Dot → Destination Start',
                      textColor),
                  const SizedBox(height: 4),
                  _keyRow(finishDotColor, 'Purple Dot → Destination Finish',
                      textColor),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Building $buildingId on the campus map. Pinch to zoom.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyRow(Color dotColor, String label, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            // Thin outline keeps the purple dot visible on the dark theme.
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: textColor)),
      ],
    );
  }

  // Pinch or scroll to zoom, drag to pan.
  Widget _zoomableSvg(String path) {
    return InteractiveViewer(
      maxScale: 5,
      child: Center(
        child: SvgPicture.asset(
          path,
          fit: BoxFit.contain,
          placeholderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

// --------------------------------
// DOT PATTERN PAINTER
// --------------------------------

class DotPatternPainter extends CustomPainter {
  final Color dotColor;

  DotPatternPainter({
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const double spacing = 22;
    const double radius = 2;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotPatternPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor;
  }
}
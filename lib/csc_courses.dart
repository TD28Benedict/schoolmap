// =====================================================
// PROGRAM OF STUDY IN COMPUTER SCIENCE  (CSC courses only)
// Copied from the official program sheet: code, title, credit hours (SCH),
// and the year/semester each course is taken.
// =====================================================

class Course {
  final String code;
  // null for open slots like "CSC Elective" that have no fixed number.
  final String? number;
  final String title;
  final int credits;
  final int year; // 1 = Freshman ... 4 = Senior
  final int semester; // 1 = First, 2 = Second

  const Course(
    this.code,
    this.number,
    this.title,
    this.credits,
    this.year,
    this.semester,
  );

  String get fullCode => number == null ? code : '$code $number';
  String get yearName => yearNames[year - 1];
  String get semesterName => semester == 1 ? 'First Semester' : 'Second Semester';
}

const List<String> yearNames = [
  'Freshman Year',
  'Sophomore Year',
  'Junior Year',
  'Senior Year',
];

const List<Course> cscCourses = [
  // FRESHMAN YEAR
  Course('CSC', '132', 'Intro to Computing and Prog. Concept', 3, 1, 1),
  Course('CSC', '133', 'Digital Logic', 3, 1, 1),
  Course('CSC', '135', 'Introduction to Programming', 3, 1, 2),
  Course('CSC', '139', 'Web Development', 3, 1, 2),

  // SOPHOMORE YEAR
  Course('CSC', '136', 'Algorithm Design I', 3, 2, 1),
  Course('CSC', '231', 'Assembly Language', 3, 2, 1),
  Course('CSC', '232', 'Foundations of App Development', 3, 2, 1),
  Course('CSC', '138', 'Algorithm Design II', 3, 2, 2),
  Course('CSC', '234', 'Theory of Computations', 3, 2, 2),
  Course('CSC', '235', 'Fundamentals of App Development', 3, 2, 2),

  // JUNIOR YEAR
  Course('CSC', '237', 'Java Programming', 3, 3, 1),
  Course('CSC', '333', 'Data Structures', 3, 3, 1),
  Course('CSC', '336', 'Advanced Concepts in App Development', 3, 3, 1),
  Course('CSC', '337', 'Computer Org and Architecture', 3, 3, 1),
  Course('CSC', '238', 'Intro to Computer Security', 3, 3, 2),
  Course('CSC', '334', 'Adv. Algorithms Design', 3, 3, 2),
  Course('CSC', '338', 'Intro to Artificial Intelligence', 3, 3, 2),

  // SENIOR YEAR
  Course('CSC', '435', 'Software Engineering Principles', 3, 4, 1),
  Course('CSC', '431', 'Programming Languages', 3, 4, 1),
  Course('CSC', '339', 'Data Comm & Networking', 3, 4, 1),
  Course('CSC', '430', 'Senior Research and Prof. Experience', 3, 4, 1),
  Course('CSC', '436', 'Operating Systems', 3, 4, 2),
  Course('CSC', '434', 'Database Management', 3, 4, 2),
  Course('CSC', '437', 'Senior Capstone', 3, 4, 2),
  Course('CSC', null, 'CSC Elective', 3, 4, 2),
];

// Finds a course by code and number, e.g. findCourse('CSC', '237').
Course? findCourse(String code, String? number) {
  if (number == null) return null;
  for (final c in cscCourses) {
    if (c.code == code && c.number == number) return c;
  }
  return null;
}

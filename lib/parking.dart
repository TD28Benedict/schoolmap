import 'package:flutter/material.dart';

// =====================================================
// TIGERSPOT  -  "Know Before You Park."
// Helps students find open spaces in the Benedict College
// Parking Garage (building 16). Ported from the App Lab version.
// =====================================================

const _purple = Color(0xFF4C1D95);
const _amber = Color(0xFFD97706);
const _red = Color(0xFF991B1B);
const _green = Color(0xFF15803D);
const _gray = Color(0xFF4B5563);

// The screens of the parking app (App Lab's "views").
enum ParkingView { auth, dashboard, vehicle, map, scan, session }

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  ParkingView view = ParkingView.auth;

  bool isVehRegistered = false;
  String? activeSpot;

  // Garage spaces: true = AVAILABLE, false = OCCUPIED.
  // Add more spaces here and they show up on the map automatically.
  final Map<String, bool> spaces = {
    'A-104': true,
    'A-105': false,
    'A-106': true,
  };

  String stats = 'Welcome! Please register your vehicle.';
  Color statsColor = _red;
  String vehStatus = 'Status: Not Registered';
  Color vehStatusColor = _red;
  String sessInfo = 'Spot: --';

  final emailController = TextEditingController();
  final plateController = TextEditingController();
  final makeController = TextEditingController();
  final scanController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    plateController.dispose();
    makeController.dispose();
    scanController.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // PARKING LOGIC
  // ------------------------------------------------

  void setView(ParkingView next) => setState(() => view = next);

  void _showStats(String message, Color color) {
    stats = message;
    statsColor = color;
  }

  void registerVehicle() {
    setState(() {
      if (plateController.text.trim().isEmpty) {
        vehStatus = 'Enter your license plate first.';
        vehStatusColor = _red;
        return;
      }
      isVehRegistered = true;
      vehStatus = 'Status: VERIFIED';
      vehStatusColor = _green;
      _showStats('Vehicle registered! You can now park.', _green);
    });
  }

  void startSession(String input) {
    // Accept "a-104" or " A-104 " from the scan box too.
    final spotId = input.trim().toUpperCase();

    setState(() {
      if (!isVehRegistered) {
        _showStats('ACTION REQUIRED: Register vehicle first!', _red);
        view = ParkingView.dashboard;
        return;
      }

      if (spaces[spotId] == true) {
        spaces[spotId] = false;
        activeSpot = spotId;
        sessInfo = 'Spot: $spotId\nStatus: ACTIVE\nVehicle Verified';
        view = ParkingView.session;
      } else {
        _showStats(
          spotId.isEmpty
              ? 'Enter a space ID to scan.'
              : 'Sorry, space $spotId is occupied or invalid.',
          _red,
        );
        view = ParkingView.dashboard;
      }
    });
  }

  void endSession() {
    setState(() {
      if (activeSpot != null) spaces[activeSpot!] = true;
      activeSpot = null;
      _showStats('You are signed out. Space is available.', _green);
      view = ParkingView.dashboard;
    });
  }

  void geofenceExit() {
    setState(() {
      sessInfo = '⚠️ LOCATION ALERT:\n'
          'Looks like you left the parking area.\n'
          'Did you leave spot $activeSpot?';
    });
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------

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
          'PARKING',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: _viewChildren(dark, textColor),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _viewChildren(bool dark, Color textColor) {
    final backHome = _button(
      'Back to Home',
      color: Colors.white,
      labelColor: const Color(0xFF292000),
      onPressed: () => setView(ParkingView.dashboard),
    );

    switch (view) {
      case ParkingView.auth:
        return [
          const SizedBox(height: 30),
          Text(
            'TIGERSPOT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: dark ? Colors.white : _purple,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Know Before You Park.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Benedict College Parking Garage (16)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 36),
          _input(emailController, 'student@school.edu', dark, textColor,
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _button(
            'LOG IN',
            color: _amber,
            onPressed: () => setView(ParkingView.dashboard),
          ),
        ];

      case ParkingView.dashboard:
        return [
          _heading('Dashboard', textColor),
          _message(stats, statsColor),
          const SizedBox(height: 16),
          _button('Find a Parking Spot',
              color: _purple, onPressed: () => setView(ParkingView.map)),
          _button('Scan QR Code',
              color: _purple, onPressed: () => setView(ParkingView.scan)),
          _button('My Vehicle',
              color: _purple, onPressed: () => setView(ParkingView.vehicle)),
          const SizedBox(height: 40),
          _button('Log Out',
              color: _red, onPressed: () => setView(ParkingView.auth)),
        ];

      case ParkingView.vehicle:
        return [
          _heading('Register Vehicle', textColor),
          _message(vehStatus, vehStatusColor),
          const SizedBox(height: 16),
          _input(plateController, 'License Plate (e.g. ABC-123)', dark,
              textColor),
          const SizedBox(height: 12),
          _input(
              makeController, 'Make & Model (e.g. Toyota)', dark, textColor),
          const SizedBox(height: 16),
          _button('Submit Registration',
              color: _purple, onPressed: registerVehicle),
          const SizedBox(height: 40),
          backHome,
        ];

      case ParkingView.map:
        return [
          _heading('Select a Space', textColor),
          const SizedBox(height: 8),
          for (final entry in spaces.entries)
            _button(
              '${entry.key} (${entry.value ? 'AVAILABLE' : 'OCCUPIED'})',
              key: Key('spot-${entry.key}'),
              color: entry.value ? _green : _red,
              onPressed: () => startSession(entry.key),
            ),
          const SizedBox(height: 40),
          backHome,
        ];

      case ParkingView.scan:
        return [
          _heading('Simulate QR Scan', textColor),
          const SizedBox(height: 16),
          _input(scanController, 'Enter Space ID (e.g. A-104)', dark,
              textColor),
          const SizedBox(height: 16),
          _button(
            'Simulate Scan',
            color: _amber,
            onPressed: () => startSession(scanController.text),
          ),
          const SizedBox(height: 40),
          backHome,
        ];

      case ParkingView.session:
        return [
          Text(
            'ACTIVE SESSION',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: dark ? const Color(0xFF4ADE80) : _green,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF332447) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              sessInfo,
              style: TextStyle(fontSize: 16, color: textColor, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          _button('SIGN OUT OF PARKING', color: _red, onPressed: endSession),
          const SizedBox(height: 40),
          _button('[DEMO] Trigger Geofence Exit',
              color: _gray, onPressed: geofenceExit),
        ];
    }
  }

  Widget _heading(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  // Status line on a white pill so red/green stay readable on any background.
  Widget _message(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint,
    bool dark,
    Color textColor, {
    TextInputType? keyboard,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF332447) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(color: textColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _button(
    String label, {
    Key? key,
    required Color color,
    Color labelColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          key: key,
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: labelColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

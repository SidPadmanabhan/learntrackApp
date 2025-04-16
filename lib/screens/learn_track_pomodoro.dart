import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class LearnTrackPomodoro extends StatefulWidget {
  const LearnTrackPomodoro({Key? key}) : super(key: key);

  @override
  State<LearnTrackPomodoro> createState() => _LearnTrackPomodoroState();
}

class _LearnTrackPomodoroState extends State<LearnTrackPomodoro> {
  // Timer states
  bool _isRunning = false;
  int _minutes = 25;
  int _seconds = 0;
  Timer? _timer;
  String _currentMode = "Work";
  Color timerColor = const Color(0xFF4F6EF5);

  // Pomodoro session durations (in minutes)
  final Map<String, int> _durations = {
    "Work": 25,
    "Short Break": 5,
    "Long Break": 10,
  };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _minutes--;
            _seconds = 59;
          } else {
            _timer?.cancel();
            _isRunning = false;
            // Here you would add code to play a sound or notification
          }
        }
        updateColor();
      });
    });

    setState(() {
      _isRunning = true;
      updateColor();
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      timerColor = const Color(0xFF4F6EF5);
      _minutes = _durations[_currentMode]!;
      _seconds = 0;
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _minutes = _minutes;
      _seconds = _seconds;
      _isRunning = false;
    });
  }

  void updateColor() {
    double percent = _getProgressValue();

    if (percent > 0.75) {
      timerColor = const Color(0xFF4F6EF5);
    } else if (percent > 0.5) {
      timerColor = const Color(0xFF5E9EF3);
    } else if (percent > 0.25) {
      timerColor = const Color(0xFFF5A623);
    } else {
      timerColor = const Color(0xFFEB5757);
    }
  }

  void _changeMode(String mode) {
    _timer?.cancel();
    setState(() {
      _currentMode = mode;
      _minutes = _durations[mode]!;
      _seconds = 0;
      _isRunning = false;
    });
  }

  double _getProgressValue() {
    int totalSeconds = 0;
    int remainingSeconds = (_minutes * 60) + _seconds;

    if (_currentMode == "Work") {
      totalSeconds = _durations["Work"]! * 60;
    } else if (_currentMode == "Short Break") {
      totalSeconds = _durations["Short Break"]! * 60;
    } else {
      totalSeconds = _durations["Long Break"]! * 60;
    }

    return remainingSeconds / totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Focus Timer',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode selection buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton("Work", _currentMode == "Work"),
                _buildModeButton("Short Break", _currentMode == "Short Break"),
                _buildModeButton("Long Break", _currentMode == "Long Break"),
              ],
            ),
          ),

          // Timer Display
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: _getProgressValue(),
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                      strokeWidth: 12,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentMode,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Timer Controls
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: const Color(0xFF4F6EF5),
                    disabledBackgroundColor: const Color(0xFF4F6EF5),
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: const Color(0xFF4F6EF5),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Help text
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Text(
                "Focus on your work for a set time, then take a short break. Repeat as needed.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String mode, bool isActive) {
    return ElevatedButton(
      onPressed: () => _changeMode(mode),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActive ? const Color(0xFF4F6EF5) : Colors.grey.withOpacity(0.2),
        foregroundColor: isActive ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        mode,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

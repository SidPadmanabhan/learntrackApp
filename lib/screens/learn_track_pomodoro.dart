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

  // Learning timeline data
  final List<Map<String, dynamic>> _milestones = [
    {
      "title": "Milestone 1",
      "subtitle": "Productivity Basics",
      "description": "Complete introduction to time management",
      "completed": true,
      "badge": true,
      "progress": 1.0,
    },
    {
      "title": "Milestone 2",
      "subtitle": "Advanced Techniques",
      "description": "Master advanced productivity methods",
      "completed": false,
      "badge": false,
      "progress": 0.4,
    },
  ];

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
    setState((){
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
          icon: const Icon(Icons.menu, color: Color(0xFF333333)),
          onPressed: () {},
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
      body: SingleChildScrollView(
        child: Column(
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
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: _getProgressValue(),
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          timerColor,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_currentMode Session',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Control buttons
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
            
            // Learning Timeline
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFFF9FAFB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Learning Timeline',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Milestone 1
                  _buildMilestone(_milestones[0]),
                  
                  // Milestone 2
                  _buildMilestone(_milestones[1]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F6EF5),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String mode, bool isActive) {
    return ElevatedButton(
      onPressed: () => _changeMode(mode),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF4F6EF5) : Colors.grey.withOpacity(0.2),
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

  Widget _buildMilestone(Map<String, dynamic> milestone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  milestone["title"],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                milestone["completed"] 
                  ? const Icon(Icons.check_circle, color: Color(0xFF4CD964), size: 24)
                  : const Icon(Icons.circle_outlined, color: Colors.grey, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              milestone["subtitle"],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              milestone["description"],
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (milestone["badge"]) 
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFFFFAA00), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Badge Earned",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFFFFAA00),
                      ),
                    ),
                  ],
                ),
              ),
            if (!milestone["completed"] && milestone["progress"] < 1.0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(
                  value: milestone["progress"],
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F6EF5)),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
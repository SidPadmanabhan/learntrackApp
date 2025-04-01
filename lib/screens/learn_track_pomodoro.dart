import 'package:flutter/material.dart';
import 'dart:async';

class LearnTrackPomodoro extends StatefulWidget {
  @override
  _LearnTrackPomodoroState createState() => _LearnTrackPomodoroState();
}

class _LearnTrackPomodoroState extends State<LearnTrackPomodoro> {
  int totalSeconds = 1500;
  int currentSeconds = 1500;
  Timer? timer;
  Color timerColor = Colors.blue;

  void startTimer() {
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (currentSeconds > 0) {
          setState(() {
            currentSeconds--;
            updateColor();
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  void resetTimer() {
    setState(() {
      currentSeconds = totalSeconds;
      updateColor();
      timer?.cancel();
    });
  }

  void setTimer(int seconds) {
    setState(() {
      totalSeconds = seconds;
      currentSeconds = seconds;
      updateColor();
      timer?.cancel();
    });
  }

  void updateColor() {
    double percent = currentSeconds / totalSeconds;
    if (percent > 0.75) {
      timerColor = Colors.blue;
    } else if (percent > 0.5) {
      timerColor = Colors.yellow;
    } else if (percent > 0.25) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return "$minutes:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Focus Timer")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeButton("Work", 1500),
              _buildTimeButton("Short Break", 300),
              _buildTimeButton("Long Break", 600),
            ],
          ),
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: currentSeconds / totalSeconds,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(timerColor),
                strokeWidth: 10,
              ),
              Text(
                formatTime(currentSeconds),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.play_arrow, size: 40, color: Colors.blue),
                onPressed: startTimer,
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: 40, color: Colors.grey),
                onPressed: resetTimer,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildLearningTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String label, int seconds) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () => setTimer(seconds),
        style: ElevatedButton.styleFrom(
          backgroundColor: totalSeconds == seconds ? Colors.blue : Colors.grey[300],
        ),
        child: Text(label, style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildLearningTimeline() {
    return Expanded(
      child: ListView(
        children: [
          _buildMilestone("Milestone 1", "Productivity Basics", "Complete introduction to time management", true),
          _buildMilestone("Milestone 2", "Advanced Techniques", "Master advanced productivity methods", false),
        ],
      ),
    );
  }

  Widget _buildMilestone(String title, String subtitle, String description, bool completed) {
    return Card(
      child: ListTile(
        title: Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: completed ? Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.radio_button_unchecked, color: Colors.grey),
      ),
    );
  }
}

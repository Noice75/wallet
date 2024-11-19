import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomTimePicker extends StatefulWidget {
  final DateTime initialTime;
  final Function(DateTime) onTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int _hour;
  late int _minute;
  bool _isAM = true;
  bool _isSelectingHour = true; // Track whether we're selecting hour or minute

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _isAM = _hour < 12;
    if (!_isAM) {
      _hour -= 12;
    }
    if (_hour == 0) {
      _hour = 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                padding: const EdgeInsets.all(16),
              ),
            ),

            // Time display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isSelectingHour = true),
                    child: _buildTimeBox(
                      _hour.toString().padLeft(2, '0'),
                      _isSelectingHour,
                    ),
                  ),
                  const Text(
                    ' • ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isSelectingHour = false),
                    child: _buildTimeBox(
                      _minute.toString().padLeft(2, '0'),
                      !_isSelectingHour,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildAMPMToggle(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Clock face
            GestureDetector(
              onTapDown: (details) => _handleClockTap(details, context),
              child: Container(
                width: 280,
                height: 280,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    // Numbers
                    ..._isSelectingHour
                        ? _buildHourNumbers()
                        : _buildMinuteNumbers(),
                    // Clock hand
                    CustomPaint(
                      size: const Size(280, 280),
                      painter: ClockHandPainter(
                        value: _isSelectingHour ? _hour : _minute,
                        totalValues: _isSelectingHour ? 12 : 60,
                        color: const Color(0xFF7F5AFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final selectedHour = _isAM ? _hour : _hour + 12;
                    final time = DateTime(
                      widget.initialTime.year,
                      widget.initialTime.month,
                      widget.initialTime.day,
                      selectedHour == 12 ? (_isAM ? 0 : 12) : selectedHour,
                      _minute,
                    );
                    widget.onTimeSelected(time);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F5AFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Select',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHourNumbers() {
    return List.generate(12, (index) {
      final hour = index + 1;
      final angle = (hour * 30 - 90) * math.pi / 180;
      final radius = 110.0;
      return Positioned(
        left: 140 + radius * math.cos(angle) - 20,
        top: 140 + radius * math.sin(angle) - 20,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _hour = hour;
              _isSelectingHour = false; // Switch to minute selection after hour
            });
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  _hour == hour ? const Color(0xFF7F5AFF) : Colors.transparent,
            ),
            child: Text(
              hour.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: _hour == hour ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildMinuteNumbers() {
    return List.generate(60, (index) {
      if (index % 5 != 0)
        return Container(); // Only show numbers at 5-minute intervals

      final minute = index;
      final angle = (minute * 6 - 90) * math.pi / 180;
      final radius = 110.0;
      return Positioned(
        left: 140 + radius * math.cos(angle) - 20,
        top: 140 + radius * math.sin(angle) - 20,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _minute = minute;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _minute == minute
                  ? const Color(0xFF7F5AFF)
                  : Colors.transparent,
            ),
            child: Text(
              minute.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: _minute == minute ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTimeBox(String value, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF7F5AFF) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAMPMToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAMPMButton('AM', _isAM),
          _buildAMPMButton('PM', !_isAM),
        ],
      ),
    );
  }

  Widget _buildAMPMButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAM = text == 'AM';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D8A5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleClockTap(TapDownDetails details, BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    final touchPoint = renderBox.globalToLocal(details.globalPosition);

    // Calculate angle from center to touch point
    final angle =
        (math.atan2(touchPoint.dy - center.dy, touchPoint.dx - center.dx) *
                    180 /
                    math.pi +
                90) %
            360;

    if (_isSelectingHour) {
      final hour = ((angle / 30).round() % 12) + 1;
      setState(() {
        _hour = hour;
        _isSelectingHour = false; // Switch to minute selection after hour
      });
    } else {
      final minute = ((angle / 6).round() % 60);
      setState(() {
        _minute = minute;
      });
    }
  }
}

class ClockHandPainter extends CustomPainter {
  final int value;
  final int totalValues;
  final Color color;

  ClockHandPainter({
    required this.value,
    required this.totalValues,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final angle = ((value * (360 / totalValues)) - 90) * math.pi / 180;
    final handLength = size.width * 0.3;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw line
    canvas.drawLine(
      center,
      Offset(
        center.dx + handLength * math.cos(angle),
        center.dy + handLength * math.sin(angle),
      ),
      paint,
    );

    // Draw circle at the end of the line
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        center.dx + handLength * math.cos(angle),
        center.dy + handLength * math.sin(angle),
      ),
      15,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

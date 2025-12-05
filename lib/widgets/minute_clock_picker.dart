import 'dart:math';
import 'package:flutter/material.dart';

typedef MinuteChanged = void Function(int minutes);

class MinuteClockPicker extends StatefulWidget {
  final int initialMinutes;
  final int maxMinutes;
  final MinuteChanged? onChanged;
  const MinuteClockPicker({Key? key, this.initialMinutes = 30, this.maxMinutes = 180, this.onChanged}) : super(key: key);

  @override
  State<MinuteClockPicker> createState() => _MinuteClockPickerState();
}

class _MinuteClockPickerState extends State<MinuteClockPicker> {
  late int _minutes; // total minutes
  late int _cycles; // how many 60-min cycles
  late int _dial; // 0..59

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes.clamp(1, widget.maxMinutes);
    _cycles = _minutes ~/ 60;
    _dial = _minutes % 60;
    if (_dial == 0 && _minutes > 0) _dial = 60;
  }

  void _updateFromDial(int dial) {
    // dial in 1..60 (we treat 60 as 0)
    int d = dial % 60;
    final total = (_cycles * 60) + d;
    setState(() {
      _dial = d == 0 ? 60 : d;
      _minutes = total == 0 ? 60 : total;
      if (_minutes > widget.maxMinutes) {
        _minutes = widget.maxMinutes;
        _cycles = _minutes ~/ 60;
        _dial = _minutes % 60;
      }
    });
    widget.onChanged?.call(_minutes);
  }

  void _increment(int delta) {
    setState(() {
      _minutes = (_minutes + delta).clamp(1, widget.maxMinutes);
      _cycles = _minutes ~/ 60;
      _dial = _minutes % 60;
      if (_dial == 0 && _minutes > 0) _dial = 60;
    });
    widget.onChanged?.call(_minutes);
  }

  int _angleToMinute(Offset center, Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    double angle = atan2(dy, dx); // -pi..pi
    // convert so that top (12 o'clock) is 0
    angle = angle + pi / 2;
    if (angle < 0) angle += 2 * pi;
    final minute = ((angle / (2 * pi)) * 60).round() % 60;
    return minute == 0 ? 60 : minute;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // large display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).colorScheme.primary.withOpacity(0.06)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$_minutes', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('dk', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // dial
        LayoutBuilder(builder: (context, constraints) {
          final mq = MediaQuery.of(context).size;
          // make the dial responsive: never larger than available width,
          // and also limit by a fraction of the screen height to avoid overflow in dialogs
          final maxByWidth = min(constraints.maxWidth, 320.0);
          final maxByHeight = mq.height * 0.45;
          final size = min(maxByWidth, min(260.0, maxByHeight));
          return GestureDetector(
            onPanDown: (e) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(e.globalPosition);
              final center = Offset(size / 2, size / 2 + 0);
              final minute = _angleToMinute(center, local);
              _updateFromDial(minute);
            },
            onPanUpdate: (e) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(e.globalPosition);
              final center = Offset(size / 2, size / 2 + 0);
              final minute = _angleToMinute(center, local);
              _updateFromDial(minute);
            },
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[100]),
                  ),
                  // numbers at every 5 minutes
                  for (int i = 0; i < 60; i += 5)
                    Positioned(
                      left: size / 2 + (size / 2 - 28) * cos((i / 60) * 2 * pi - pi / 2) - 12,
                      top: size / 2 + (size / 2 - 28) * sin((i / 60) * 2 * pi - pi / 2) - 10,
                      child: Text(i.toString().padLeft(2, '0'), style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ),
                  // pointer
                  Transform.rotate(
                    angle: ((_dial % 60) / 60) * 2 * pi,
                    child: Container(
                      width: size * 0.02,
                      height: size * 0.45,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  // knob
                  Positioned(
                    top: size / 2 - (size * 0.45) - 10,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                      child: Center(child: Text('${_dial % 60}', style: const TextStyle(color: Colors.white, fontSize: 11))),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),
        // quick buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => _increment(-1), child: const Text('-1')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => _increment(1), child: const Text('+1')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => _increment(5), child: const Text('+5')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => _increment(10), child: const Text('+10')),
          ],
        ),
      ],
    );
  }
}

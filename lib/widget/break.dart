import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedWaveScreen extends StatefulWidget {
  @override
  _AnimatedWaveScreenState createState() => _AnimatedWaveScreenState();
}

class _AnimatedWaveScreenState extends State<AnimatedWaveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double waveOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )
      ..addListener(() {
        setState(() {
          waveOffset += 0.1;
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            painter: WavePainter(waveOffset),
          ),
          Positioned(
            top: 50, // المسافة من الأعلى
            left: 0,
            right: 0,
            child: Text(
              "Break",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff2C73D9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveOffset;

  WavePainter(this.waveOffset);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xff2C73D9).withOpacity(0.8);

    Path path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      double y = size.height -
          (sin((x * 0.02) + waveOffset) * 50 +
              (size.height * (waveOffset / 100)));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

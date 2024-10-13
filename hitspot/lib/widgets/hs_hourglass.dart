import 'package:flutter/material.dart';

class HSHourglassShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Widget? child;

  const HSHourglassShape({
    super.key,
    required this.width,
    required this.height,
    this.color = Colors.blue,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null)
          ClipPath(
            clipper: _HourglassClipper(),
            child: SizedBox(
              width: width,
              height: height,
              child: child,
            ),
          ),
        CustomPaint(
          size: Size(width, height),
          painter: _HourglassPainter(color: color),
        ),
      ],
    );
  }
}

class _HourglassClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Top curve
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 0);

    // Right top curve
    path.quadraticBezierTo(size.width - (size.width / 6), size.height / 4,
        size.width / 1.5, size.height / 2);

    // Right bottom curve
    path.quadraticBezierTo(size.width - (size.width / 6), size.height * 3 / 4,
        size.width, size.height);

    // Bottom curve
    path.quadraticBezierTo(size.width / 2, size.height, 0, size.height);

    // Left bottom curve
    path.quadraticBezierTo(
        size.width / 6, size.height * 3 / 4, size.width / 3, size.height / 2);

    // Left top curve
    path.quadraticBezierTo(size.width / 6, size.height / 4, 0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HourglassPainter extends CustomPainter {
  final Color color;

  _HourglassPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    // (Same path creation as in _HourglassClipper)
    // ...

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Create a path
    Path path = Path();

    // Start at the top left
    path.lineTo(0, size.height - 50);

    // Create a curved line to the bottom right
    path.quadraticBezierTo(
      size.width / 2, // control point x
      size.height, // control point y
      size.width, // end point x
      size.height - 50, // end point y
    );

    // Line to the top right
    path.lineTo(size.width, 0);

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


import 'dart:math';

import 'package:flutter/material.dart';

class AppColors {

  static Color background = const Color.fromRGBO(89, 89, 89, 1);
  static Color button = Colors.deepOrange;
  static Color text = Colors.white;
  static Color textSecondary = background;


  static Color generateRandomContrastColor(Color textColor) {
    Random random = Random();

    // Ensure a minimum luminance difference from text color
    double minLuminanceDifference = 0.5;

    Color generateColor() {
      return Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1.0,
      );
    }

    // Check luminance difference and avoid neon colors
    Color color;
    do {
      color = generateColor();
    } while (
    (color.computeLuminance() - textColor.computeLuminance()).abs() <
        minLuminanceDifference ||
        isNeonColor(color) || isMuddyColor(color));

    return color;
  }

  // Function to check if a color is neon
  static bool isNeonColor(Color color) {
    const double luminanceThreshold = 0.6; // Adjust as needed
    return color.computeLuminance() > luminanceThreshold;
  }

  // Function to check if a color is muddy/darker
  static bool isMuddyColor(Color color) {
    const double brightnessThreshold = 0.25; // Adjust this value to control the minimum brightness
    return color.computeLuminance() < brightnessThreshold;
  }


  static List<Color> createGradient(int stops, Color startColor, Color endColor) {
    // Ensure that stops is at least 2 to have a meaningful gradient
    stops = stops < 2 ? 2 : stops;

    // Calculate the step size between stops
    double stepSize = 1.0 / (stops - 1);

    // Create a list of colors for the gradient
    List<Color> gradientColors = [];
    for (int i = 0; i < stops; i++) {
      double t = stepSize * i;
      gradientColors.add(Color.lerp(startColor, endColor, t)!);
    }

    return gradientColors;
  }



}
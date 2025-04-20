import 'package:flutter/material.dart';

class WeatherInfoCard extends StatelessWidget {
  final double temperature;
  final String description;

  const WeatherInfoCard({
    super.key,
    required this.temperature,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.wb_sunny, color: Colors.orange),
        const SizedBox(width: 6),
        Text('$temperature°C - $description'),
      ],
    );
  }
}
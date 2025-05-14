import 'package:flutter/material.dart';

class WeatherInfoCard extends StatelessWidget {
  final double temperature;
  final String description;
  final String icon;

  const WeatherInfoCard({
    super.key,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final iconUrl = 'https://openweathermap.org/img/wn/$icon@2x.png';

    return Row(
      children: [
        const SizedBox(width: 8),
        Text('$temperature°C - ${description[0].toUpperCase()}${description.substring(1)}'),
        Image.network(
          iconUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
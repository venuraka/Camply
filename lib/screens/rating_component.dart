import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';

class RatingComponent extends StatelessWidget {
  final double rating; // rating value passed as prop
  final double size; // optional prop for star size (default is 25)

  const RatingComponent({Key? key, required this.rating, this.size = 20})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double roundedRating = (rating * 2).round() / 2;
    return StarRating(
      rating: roundedRating,
      starCount: 5,
      size: size,
      color: Colors.greenAccent,
      borderColor: Colors.grey,
      allowHalfRating: true,
    );
  }
}

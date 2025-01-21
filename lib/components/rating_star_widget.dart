import 'package:flutter/material.dart';

class RatingStarWidget extends StatelessWidget {
  final int rating; // Rating out of 5

  RatingStarWidget({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }
}

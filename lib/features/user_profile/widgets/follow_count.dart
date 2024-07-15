import 'package:flutter/widgets.dart';
import 'package:twitte_clone/theme/pallete.dart';

class FollowCount extends StatelessWidget {
  final int count;
  final String text;
  const FollowCount({super.key, required this.count, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Pallete.whiteColor,
          ),
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Pallete.greyColor,
          ),
        ),
      ],
    );
  }
}

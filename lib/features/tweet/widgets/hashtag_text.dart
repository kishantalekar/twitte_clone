import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:twitte_clone/features/tweet/view/hashtag_tweet_view.dart';
import 'package:twitte_clone/theme/pallete.dart';

class HashTagText extends StatelessWidget {
  final String text;

  const HashTagText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpans = [];

    text.split(' ').forEach((element) {
      if (element.startsWith('#')) {
        textSpans.add(TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap =
                  () => Navigator.of(context).push(HashtagView.route(element)),
            text: '$element ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Pallete.blueColor,
              fontSize: 16,
            )));
      } else if (element.startsWith('www.') || element.startsWith('https://')) {
        textSpans.add(TextSpan(
            text: '$element ',
            style: const TextStyle(
              color: Pallete.blueColor,
              fontSize: 16,
            )));
      } else {
        textSpans.add(
          TextSpan(
            text: "$element ",
            style: const TextStyle(fontSize: 16),
          ),
        );
      }
    });
    return RichText(
      text: TextSpan(children: textSpans),
    );
  }
}

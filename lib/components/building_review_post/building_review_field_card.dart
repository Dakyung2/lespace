import 'package:flutter/material.dart';


class ReviewFieldCard extends StatelessWidget {
  final String text;
  const ReviewFieldCard({
    super.key,
    required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              indent: 0.0,
              endIndent: 0.0,
              thickness: 1.5,
                color: Color(0xe0d9e0e7)
            ),
            const SizedBox(height: 3),
            Text(text.toString(), style: const TextStyle(fontSize: 18,)),

          ],
        ),
      ),
    );
  }
}

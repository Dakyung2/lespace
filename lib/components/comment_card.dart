import "package:flutter/material.dart";

class CommentCard extends StatelessWidget {
  final String time;
  final String text;

  const CommentCard({super.key,
  required this.text,
  required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      padding: const EdgeInsets.only(top: 4, left: 14, right: 14, bottom: 2),
      constraints: const BoxConstraints(
      maxHeight: 45,  ),
    child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(text,
              style: TextStyle(fontSize: 12,
              color: Colors.grey[600]),),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(time,
                  style: const TextStyle(fontSize: 10,
                  color: Colors.grey),),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

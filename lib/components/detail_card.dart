import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final String? imageUrl;
  final String? detailText;
  const DetailCard({
    Key? key,
   this.imageUrl,
   this.detailText}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (imageUrl != null)
        Container(
          height: 400, width: 400,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        ),),
                  ),
        if (detailText != null)
        Text(detailText!),
        ],
    );
  }
}

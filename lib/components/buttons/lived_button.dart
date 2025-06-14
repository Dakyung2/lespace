import 'package:flutter/material.dart';
class BottomSheetContent extends StatefulWidget {
  final Function(bool) onLivedChanged;

  const BottomSheetContent({super.key, required this.onLivedChanged});

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  bool hasLived = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ... Your other widgets ...

        ElevatedButton(
          onPressed: () {
            setState(() {
              hasLived = !hasLived; // Toggle the user's choice
            });
            widget.onLivedChanged(hasLived); // Notify the parent widget
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: hasLived ? Colors.green : Colors.grey,
          ),
          child: Text(
            hasLived ? "거주함" : "거주 안함",
            style: TextStyle(
              color: hasLived ? Colors.white : Colors.black,
            ),
          ),
        ),

        // ... Your other widgets ...
      ],
    );
  }
}

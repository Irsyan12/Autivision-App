// bottomNav.dart
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 78,
      decoration: const ShapeDecoration(
        color: Color(0xFF02243D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home,
                color: currentIndex == 0 ? Colors.white : Colors.grey,
                size: 36),
            onPressed: currentIndex == 0 ? null : () => onTap(0),
          ),
          IconButton(
            icon: Icon(Icons.history,
                color: currentIndex == 1 ? Colors.white : Colors.grey,
                size: 36),
            onPressed: currentIndex == 1 ? null : () => onTap(1),
          ),
          IconButton(
            icon: Icon(Icons.person,
                color: currentIndex == 2 ? Colors.white : Colors.grey,
                size: 36),
            onPressed: currentIndex == 2 ? null : () => onTap(2),
          ),
        ],
      ),
    );
  }
}

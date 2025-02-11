import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeading;
  final List<Widget>? actions;

  const CustomAppBar({super.key, 
    required this.title,
    this.showLeading = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Container(),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF02243D),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

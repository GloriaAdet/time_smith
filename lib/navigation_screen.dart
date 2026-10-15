// navigation_screen.dart

import 'package:flutter/material.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('This is the Navigation Screen'),
      ),
    );
  }
}

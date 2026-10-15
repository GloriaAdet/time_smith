// productivity_report_screen.dart

import 'package:flutter/material.dart';

class ProductivityReportScreen extends StatelessWidget {
  const ProductivityReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Analyze Your Productivity Here'),
      ),
    );
  }
}

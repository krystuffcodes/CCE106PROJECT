import 'package:flutter/material.dart';

class MyReportedItemsPage extends StatelessWidget {
  const MyReportedItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reported Items"),
        backgroundColor: const Color(0xFFb71c1c),
      ),
      body: const Center(child: Text("List of your reported items will appear here.")),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(const MaterialApp(home: SingleChildScrollViewExample()));
}

class SingleChildScrollViewExample extends StatefulWidget {
  const SingleChildScrollViewExample({super.key});

  @override
  State<SingleChildScrollViewExample> createState() => _SingleChildScrollViewExampleState();
}

class _SingleChildScrollViewExampleState extends State<SingleChildScrollViewExample> {
  final List<String> _items = List.generate(5, (index) => 'Item $index');
  Future<void> _refreshItems() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _items.add('Item ${_items.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoreSingleChildScrollView Example'),
      ),
      body: CoreSingleChildScrollView(
        onRefresh: _refreshItems,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pull down to refresh!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(_items[index]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

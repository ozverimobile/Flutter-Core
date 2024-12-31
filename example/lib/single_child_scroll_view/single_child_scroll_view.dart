import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/single_child_scroll_view/single_child_scroll_view_keys.dart';

void main() {
  runApp(const SingleChildScrollViewExample());
}

class SingleChildScrollViewExample extends StatefulWidget {
  const SingleChildScrollViewExample({super.key});

  @override
  State<SingleChildScrollViewExample> createState() => _SingleChildScrollViewExampleState();
}

class _SingleChildScrollViewExampleState extends State<SingleChildScrollViewExample> {
  final List<String> _items = List.generate(20, (index) => 'Item $index');
  Future<void> _refreshItems() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _items.add('Item ${_items.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('CoreSingleChildScrollView Example')),
            body: CoreSingleChildScrollView(
              controller: ScrollController(),
              onRefresh: _refreshItems,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key: Key(SingleChildScrollViewKeys.pullDownToRefreshText.toString()),
                      'Pull down to refresh!',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            title: Text(
                              _items[index],
                            ),
                          ),
                        );
                      },
                    ),
                         const SizedBox(height: 16),
                    Text(
                      key: Key(SingleChildScrollViewKeys.pullUpToGoStart.toString()),
                      'Pull up to go start!',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

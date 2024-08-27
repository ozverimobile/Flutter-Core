import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ReorderableListViewExample(),
    ),
  );
}

class ReorderableListViewExample extends StatefulWidget {
  const ReorderableListViewExample({super.key});

  @override
  State<ReorderableListViewExample> createState() => _ReorderableListViewExampleState();
}

class _ReorderableListViewExampleState extends State<ReorderableListViewExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reorderable ListView Example')),
      body: CoreSingleChildScrollView(
        onRefresh: () async {
          await 2.seconds.delay<void>();
        },
        child: Row(
          children: [
            Expanded(
              child: CoreReorderableListView(
                onReorder: (int oldIndex, int newIndex) {},
                physics: const NeverScrollableScrollPhysics(),
                onReachedEnd: () async {
                  await 2.seconds.delay<void>();
                },
                children: [
                  ...List.generate(
                    100,
                    (index) => ListTile(
                      key: ValueKey(index),
                      title: Text('$index'),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CoreReorderableListView(
                onReorder: (int oldIndex, int newIndex) {},
                onReachedEnd: () async {
                  await 2.seconds.delay<void>();
                },
                onRefresh: () async {
                  await 2.seconds.delay<void>();
                },
                children: List.generate(
                  100,
                  (index) => ListTile(
                    key: ValueKey(index),
                    title: Text('$index'),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CoreReorderableListView.builder(
                onReorder: (int oldIndex, int newIndex) {},
                padding: const EdgeInsets.symmetric(vertical: 24),
                onReachedEnd: () => 5.seconds.delay<void>(),
                onRefresh: () => 2.seconds.delay<void>(),
                itemBuilder: (context, index) {
                  return ListTile(
                    key: ValueKey(index),
                    title: Text('$index'),
                    trailing: const Icon(Icons.drag_handle),
                  );
                },
                itemCount: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

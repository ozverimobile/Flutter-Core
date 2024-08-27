import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ListViewExample(),
    ),
  );
}

class ListViewExample extends StatefulWidget {
  const ListViewExample({super.key});

  @override
  State<ListViewExample> createState() => _ListViewExampleState();
}

class _ListViewExampleState extends State<ListViewExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView Example'),
      ),
      body: CoreSingleChildScrollView(
        onRefresh: () async {
          await 2.seconds.delay<void>();
        },
        child: Row(
          children: [
            Expanded(
              child: CoreListView(
                physics: const NeverScrollableScrollPhysics(),
                onReachedEnd: () async {
                  await 5.seconds.delay<void>();
                },
                children: [
                  ...List.generate(100, (index) => const ListTile(title: Text('Item'))),
                ],
              ),
            ),
            Expanded(
              child: CoreListView(
                onReachedEnd: () async {
                  await 5.seconds.delay<void>();
                },
                onRefresh: () async {
                  await 2.seconds.delay<void>();
                },
                children: List.generate(
                  100,
                  (index) => ListTile(
                    title: Text('Item $index'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CoreListView.separated(
                padding: const EdgeInsets.all(24),
                onReachedEnd: () => 5.seconds.delay<void>(),
                onRefresh: () => 2.seconds.delay<void>(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Item $index'),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

final class ListviewForIntegrationTest extends StatefulWidget {
  const ListviewForIntegrationTest({
    super.key,
  });

  @override
  State<ListviewForIntegrationTest> createState() => _ListviewForIntegrationTestState();
}

class _ListviewForIntegrationTestState extends State<ListviewForIntegrationTest> {
  List<String> items = List.generate(20, (index) => 'Item $index');
  final ScrollController scrollController = ScrollController();

  String reorderingDescription = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListView Integration Test'), actions: [CoreText(reorderingDescription)]),
      body: CoreListView.builder(
        controller: scrollController,
        key: const Key('listview'),
        padding: const EdgeInsets.all(8) + const EdgeInsets.only(bottom: 52),
        itemCount: items.length,
        itemBuilder: (context, index) => _ListTile(key: Key('listview_item_$index'), items: items, index: index),
        physics: const AlwaysScrollableScrollPhysics(),
        onReachedEnd: onReachedEnd,
        onRefresh: onRefresh,
      ),
    );
  }

  Future<void> onReachedEnd() async {
    await 1.seconds.delay<void>();
    setState(() {
      items.addAll(List.generate(5, (index) => 'Item ${items.length + index}'));
    });
  }

  Future<void> onRefresh() async {
    await 1.seconds.delay<void>();
    setState(() {
      items = List.generate(20, (index) => 'Item $index');
    });
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.items,
    required this.index,
    super.key,
  });

  final List<String> items;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(items[index]),
      title: Text(items[index]),
    );
  }
}

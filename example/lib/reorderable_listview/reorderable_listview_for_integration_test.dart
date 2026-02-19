import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

final class ReorderableListviewForIntegrationTest extends StatefulWidget {
  const ReorderableListviewForIntegrationTest({
    super.key,
  });

  @override
  State<ReorderableListviewForIntegrationTest> createState() => _ReorderableListviewForIntegrationTestState();
}

class _ReorderableListviewForIntegrationTestState extends State<ReorderableListviewForIntegrationTest> {
  List<String> items = List.generate(20, (index) => 'Item $index');
  final ScrollController scrollController = ScrollController();

  String reorderingDescription = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reorderable ListView Integration Test'), actions: [CoreText(reorderingDescription)]),
      body: CoreReorderableListView.builder(
        key: const Key('reorderable_listview'),
        padding: const EdgeInsets.all(8) + const EdgeInsets.only(bottom: 52),
        scrollController: scrollController,
        itemCount: items.length,
        itemBuilder: (context, index) => _ListTile(key: Key('reorderable_listview_item_$index'), items: items, index: index),
        onReorder: onReorder,
        physics: const AlwaysScrollableScrollPhysics(),
        proxyDecorator: (child, index, animation) => _ProxyDecorator(index: index, child: child),
        onReorderStart: onReorderStart,
        onReorderEnd: onReorderEnd,
        onReachedEnd: onReachedEnd,
        onRefresh: onRefresh,
      ),
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (kDebugMode) print('oldIndex: $oldIndex, newIndex: $newIndex');
      var newIndex0 = newIndex;
      if (newIndex > oldIndex) newIndex0 -= 1;
      final item = items.removeAt(oldIndex);
      items.insert(newIndex0, item);
    });
  }

  void onReorderStart(int index) {
    if (kDebugMode) print('onReorderStart: $index');
    reorderingDescription = 'Reordering Started';
    setState(() {});
  }

  void onReorderEnd(int index) {
    if (kDebugMode) print('onReorderEnd: $index');
    reorderingDescription = '';
    setState(() {});
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

class _ProxyDecorator extends StatelessWidget {
  const _ProxyDecorator({
    required this.child,
    required this.index,
  });

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red,
      child: Stack(
        children: [
          child,
          Positioned(right: 10, top: 0, bottom: 0, child: Center(child: CoreText('$index. Index Reordering'))),
        ],
      ),
    );
  }
}

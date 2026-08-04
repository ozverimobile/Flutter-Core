import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(const GridViewExample());
}

class GridViewExample extends StatefulWidget {
  const GridViewExample({super.key});

  @override
  State<GridViewExample> createState() => _GridViewExampleState();
}

class _GridViewExampleState extends State<GridViewExample> {
  List<int> _items = List.generate(30, (index) => index);
  List<int> _masonryItems = List.generate(30, (index) => index);

  Future<void> _loadMoreItems() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _items = [..._items, ...List.generate(10, (index) => _items.length + index)];
    });
  }

  Future<void> _loadMoreMasonryItems() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _masonryItems = [..._masonryItems, ...List.generate(10, (index) => _masonryItems.length + index)];
    });
  }

  Future<void> _refreshItems() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _items = List.generate(30, (index) => index);
    });
  }

  Future<void> _refreshMasonryItems() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _masonryItems = List.generate(30, (index) => index);
    });
  }

  double _tileHeight(int index) => 80.0 + (index % 5) * 40;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('GridView Example'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'CoreGridView'),
                Tab(text: 'CoreMasonryGridView'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildCoreGridView(),
              _buildCoreMasonryGridView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoreGridView() {
    return CoreGridView.builder(
      padding: const EdgeInsets.all(12),
      onReachedEnd: _loadMoreItems,
      onRefresh: _refreshItems,
      floatingChild: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Floating header', style: TextStyle(color: Colors.white)),
      ),
      floatingChildVisibilityCallback: (isVisible) => debugPrint('CoreGridView floating header visible: $isVisible'),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) => _GridTile(index: _items[index]),
    );
  }

  Widget _buildCoreMasonryGridView() {
    return CoreMasonryGridView.count(
      floatingChild: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Floating header', style: TextStyle(color: Colors.white)),
      ),
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      onReachedEnd: _loadMoreMasonryItems,
      onRefresh: _refreshMasonryItems,
      itemCount: _masonryItems.length,
      itemBuilder: (context, index) => _GridTile(index: _masonryItems[index], height: _tileHeight(index)),
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.index, this.height});

  final int index;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.primaries[index % Colors.primaries.length],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Item $index',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

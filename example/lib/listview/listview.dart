import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/listview/listview_for_integration_text.dart';

void main() {
  runApp(const ListViewExample());
}

class ListViewExample extends StatefulWidget {
  const ListViewExample({super.key});

  @override
  State<ListViewExample> createState() => _ListViewExampleState();
}

class _ListViewExampleState extends State<ListViewExample> {
  bool isEmpty = false;

  List<String> items = List.generate(40, (index) => 'Item $index');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('ListView Example'),
              actions: [
                CoreTextButton(
                  child: const CoreText('Integration Test'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const ListviewForIntegrationTest())),
                ),
              ],
            ),
            body: CoreSingleChildScrollView(
              onRefresh: () async {
                await 2.seconds.delay<void>();
              },
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: context.height - context.viewPadding.top - context.viewPadding.bottom,
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
                  ),
                  Expanded(
                    child: SizedBox(
                      height: context.height - context.viewPadding.top - context.viewPadding.bottom,
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
                  ),
                  Expanded(
                    child: SizedBox(
                      height: context.height - context.viewPadding.top - context.viewPadding.bottom,
                      child: Builder(
                        builder: (context) {
                          if (items.isEmpty) {
                            return const Center(child: Text('Empty'));
                          }
                          return CoreListView.separated(
                            refreshIndicatorStartPosition: CoreRefreshIndicatorStartPosition.below,
                            floatingChildVisibilityCallback: (isVisible) {
                              print('isVisible: $isVisible');
                            },
                            floatingChild: TextField(),
                            padding: const EdgeInsets.all(24),
                            onReachedEnd: () => 5.seconds.delay<void>(),
                            onRefresh: () => 2.seconds.delay<void>(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  setState(() {
                                    items
                                      ..clear()
                                      ..addAll(List.generate(40, (index) => 'Item $index'));
                                  });
                                },
                                title: Text('Item $index'),
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(),
                            itemCount: items.length,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

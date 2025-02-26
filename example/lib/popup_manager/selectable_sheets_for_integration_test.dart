import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/popup_manager/popup_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Core.initialize();
  runApp(const SelectableSheetsForIntegrationTest());
}

class SelectableSheetsForIntegrationTest extends StatefulWidget {
  const SelectableSheetsForIntegrationTest({super.key});

  @override
  State<SelectableSheetsForIntegrationTest> createState() => _SelectableSheetsForIntegrationTestState();
  static const showSingleSelectableSearchViewButtonFinder = Key('showSingleSelectableSearchViewButton');
  static List<TestData> items = List.generate(17, TestData.new);
}

final rootPopupManager = PopupManager(navigatorKey: navKey);
final navKey = GlobalKey<NavigatorState>();

class _SelectableSheetsForIntegrationTestState extends State<SelectableSheetsForIntegrationTest> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      home: const SelectableSheetsForIntegrationTestWidget(),
    );
  }
}

class SelectableSheetsForIntegrationTestWidget extends StatefulWidget {
  const SelectableSheetsForIntegrationTestWidget({super.key});

  @override
  State<SelectableSheetsForIntegrationTestWidget> createState() => _SelectableSheetsForIntegrationTestWidgetState();
}

class _SelectableSheetsForIntegrationTestWidgetState extends State<SelectableSheetsForIntegrationTestWidget> {
  final popupManager = PopupManager(navigatorKey: navKey);
  TestData? singleSelectableResult;
  List<TestData> multiSelectableResult = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Test Appbar Size'),
      ),
      body: Center(
        child: ListView(
          children: [
            Text(singleSelectableResult?.title ?? 'Single Selectable Result'),
            CoreTextButton(
              key: SelectableSheetsForIntegrationTest.showSingleSelectableSearchViewButtonFinder,
              child: const Text('Show single selectable search view'),
              onPressed: () async {
                final result = await popupManager.singleSelectableSearchSheet(
                  title: 'Show Single Selectable Search View',
                  showDragHandle: true,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                  items: SelectableSheetsForIntegrationTest.items,
                  selected: singleSelectableResult,
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData(
                        appBarTheme: AppBarTheme(
                          backgroundColor: Colors.grey[50],
                          elevation: 1,
                          scrolledUnderElevation: 0,
                        ),
                        scaffoldBackgroundColor: Colors.white,
                        radioTheme: RadioThemeData(
                          fillColor: WidgetStateProperty.all(Colors.red),
                        ),
                      ),
                      child: child,
                    );
                  },
                );
                if (singleSelectableResult != null) {
                  setState(() {
                    singleSelectableResult = result;
                  });
                }
              },
            ),
            CoreTextButton(
              child: const Text('Show multi selectable search view'),
              onPressed: () async {
                if (kDebugMode) {
                  final response = await popupManager.multiSelectableSearchSheet<SelectableSearchMixin>(
                    showDragHandle: true,
                    title: 'Show Multi Selectable Search View',
                    showItemCount: false,
                    showSelectAllButton: false,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData(
                          appBarTheme: AppBarTheme(
                            backgroundColor: Colors.grey[50],
                            elevation: 1,
                            scrolledUnderElevation: 0,
                          ),
                          scaffoldBackgroundColor: Colors.white,
                          checkboxTheme: const CheckboxThemeData(
                            fillColor: WidgetStatePropertyAll(Colors.black),
                            checkColor: WidgetStatePropertyAll(Colors.red),
                            overlayColor: WidgetStatePropertyAll(Colors.orange),
                          ),
                        ),
                        child: child,
                      );
                    },
                    items: SelectableSheetsForIntegrationTest.items,
                    selectedItems: multiSelectableResult,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                  );
                  multiSelectableResult = List.from(response ?? []);
                  debugPrint(response.toString());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

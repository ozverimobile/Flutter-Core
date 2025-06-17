import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_localization/flutter_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Core.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final rootPopupManager = PopupManager(navigatorKey: navKey);
final navKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  late final FlutterLocalization localization;

  @override
  void initState() {
    localization = FlutterLocalization.instance;
    localization.init(
      mapLocales: [
        const MapLocale(
          'tr',
          {},
        ),
      ],
      initLanguageCode: 'tr',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      localizationsDelegates: localization.localizationsDelegates,
      supportedLocales: localization.supportedLocales,
      locale: localization.currentLocale,
      home: const PopupManagerWidget(),
    );
  }
}

class PopupManagerWidget extends StatefulWidget {
  const PopupManagerWidget({super.key});

  @override
  State<PopupManagerWidget> createState() => _PopupManagerWidgetState();
}

class _PopupManagerWidgetState extends State<PopupManagerWidget> {
  final popupManager = PopupManager(navigatorKey: navKey);
  TestData? testSingle;
  List<TestData> testMulti = [];

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
            CoreTextButton(
              child: const Text('Show dialog'),
              onPressed: () {
                popupManager.showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Title'),
                    content: const Text('Content'),
                    actions: [
                      TextButton(
                        onPressed: popupManager.hidePopup<void>,
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            CoreTextButton(
              child: const Text('Show loader'),
              onPressed: () {
                popupManager.showLoader(context: context);
                1.seconds.delay(popupManager.hidePopup<void>);
              },
            ),
            CoreTextButton(
              child: const Text('Show bottom sheet'),
              onPressed: () {
                popupManager.showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => ColoredBox(
                    color: Colors.white,
                    child: Center(
                      child: TextButton(
                        onPressed: popupManager.hidePopup<void>,
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                );
              },
            ),
            CoreTextButton(
              child: const Text('Show cupertino dialog'),
              onPressed: () {
                popupManager.showCupertinoDialog<void>(
                  context: context,
                  builder: (context) => Center(
                    child: CupertinoButton.filled(
                      onPressed: popupManager.hidePopup<void>,
                      child: const Text('OK'),
                    ),
                  ),
                );
              },
            ),
            CoreTextButton(
              child: const Text('Show cupertino modal popup'),
              onPressed: () {
                popupManager.showCupertinoModalPopup<void>(
                  context: context,
                  builder: (context) => Container(
                    height: 300,
                    color: Colors.white,
                    child: Center(
                      child: CupertinoButton.filled(
                        onPressed: popupManager.hidePopup<void>,
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                );
              },
            ),
            CoreTextButton(
              child: const Text('Show adaptive info dialog'),
              onPressed: () {
                popupManager.showAdaptiveInfoDialog(
                  title: const Text('Başarılı'),
                  content: const Text('İşlem başarılı bir şekilde gerçekleşti.'),
                );
              },
            ),
            CoreTextButton(
              child: const Text('Show default adaptive alert dialog'),
              onPressed: () {
                popupManager.showDefaultAdaptiveAlertDialog<void>(
                  context: context,
                  content: const Text('Content'),
                  title: const Text('Title'),
                  onOkButtonPressed: popupManager.hidePopup<void>,
                );
              },
            ),
            CoreTextButton(
              child: const Text('Show adaptive date picker'),
              onPressed: () async {
                final datePickerId = UniqueKey().toString();
                CoreLogger.log(
                  await popupManager.showAdaptiveDatePicker(
                    context: context,
                    id: datePickerId,
                    minimumDate: DateTime.now().subtract(5.days),
                    maximumDate: DateTime.now().add(5.days),
                    initialDateTime: DateTime.now(),
                    mode: AdaptiveDatePickerMode.dateAndTime,
                  ),
                );
              },
            ),
            CoreTextButton(
              child: const Text('Show adaptive picker'),
              onPressed: () async {
                final index = await popupManager.showAdaptivePicker(
                  initialItemIndex: 3,
                  context: context,
                  androidHeight: double.infinity,
                  children: [
                    const Text('Item 1'),
                    const Text('Item 2'),
                    const Text('Item 3'),
                    const Text('Item 4'),
                    const Text('Item 5'),
                  ],
                  title: const Text('Seçim yapınız'),
                );
                if (kDebugMode) print(index);
              },
            ),
            CoreTextButton(
              child: const Text('Show Adaptive Input Dialog'),
              onPressed: () async {
                final result = await popupManager.showAdaptiveInputDialog(
                  context: context,
                  title: 'Title',
                  message: 'Message',
                  hintText: 'Hint Text',
                  keyboardType: TextInputType.text,
                );
                CoreLogger.log(result);
              },
            ),
            CoreTextButton(
              child: const Text('Show Update Available Dialog'),
              onPressed: () {
                popupManager.showUpdateAvailableDialog(
                  iosLaunchIntune: true,
                  context: context,
                );
              },
            ),
            CoreTextButton(
              child: const Text('Show Adaptive Action Sheet'),
              onPressed: () async {
                if (kDebugMode) {
                  print(
                    await popupManager.showAdaptiveActionSheet(
                      title: 'Test Title Uzun Başlık',
                      content: 'Test Content',
                      cancelButtonLabelOnIos: 'Test Cancel Label',
                      actions: [
                        AdaptiveAction(
                          iconOnAndroid: Icons.car_crash,
                          label: 'Action 1',
                          onPressed: () {
                            CoreLogger.log('Action 1');
                          },
                          isDefaultAction: true,
                        ),
                        AdaptiveAction(
                          iconOnAndroid: Icons.abc,
                          label: 'Action 2',
                          onPressed: () {
                            CoreLogger.log('Action 2');
                          },
                        ),
                        AdaptiveAction(
                          iconOnAndroid: Icons.local_activity,
                          label: 'Action 3',
                          onPressed: () {
                            CoreLogger.log('Action 3');
                          },
                          isDestructiveAction: true,
                        ),
                      ],
                      context: context,
                    ),
                  );
                }
              },
            ),
            CoreTextButton(
              child: const Text('Show single selectable search view'),
              onPressed: () async {
                final items = List.generate(17, TestData.new);
                if (kDebugMode) {
                  testSingle = await popupManager.singleSelectableSearchSheet(
                    title: 'Show Single Selectable Search View',
                    showDragHandle: true,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                    items: items,
                    selected: testSingle,
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
                  print(testSingle?.title);
                }
              },
            ),
            CoreTextButton(
              child: const Text('Show multi selectable search view'),
              onPressed: () async {
                final items = List.generate(17, TestData.new);
                if (kDebugMode) {
                  final response = await popupManager.multiSelectableSearchSheet(
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
                    items: items,
                    selectedItems: testMulti,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                  );
                  testMulti = List.from(response ?? []);
                }
              },
            ),
            CoreTextButton(
              child: const Text('Show image picker'),
              onPressed: () async {
                if (kDebugMode) {
                  print(await popupManager.showImageSourcePicker(context: context));
                }
              },
            ),
            CoreTextButton(
              child: const Text('Show Patch Installed BottomSheet'),
              onPressed: () async {
                await popupManager.showPatchInstalledBottomSheet(
                  context: context,
                  isForce: false,
                );
              },
            ),
            // cupertino bottom sheet
            CoreTextButton(
              child: const Text('Show Cupertino Bottom Sheet'),
              onPressed: () {
                final id = UniqueKey().toString();
                popupManager.showCupertinoBottomSheet<void>(
                  context: context,
                  id: id,
                  builder: (context) => Container(
                    height: 300,
                    color: Colors.white,
                    child: Center(
                      child: CupertinoButton.filled(
                        onPressed:()=> popupManager.hidePopup<void>(id: id),
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TestData implements SelectableSearchMixin {
  TestData(this.index);
  final int index;
  @override
  bool get active => true;

  @override
  String? get subtitle => null;

  @override
  String? get title => '$index Test Content ${"aaa" * index}';

  @override
  bool filter(String query) => title?.toLowerCase().contains(query.toLowerCase()) ?? false;

  @override
  bool operator ==(Object other) {
    return (other is TestData) && other.index == index;
  }

  @override
  int get hashCode => index.hashCode;
}

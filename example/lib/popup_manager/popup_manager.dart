import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_localization/flutter_localization.dart';

Future<void> main() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  reversedActions: true,
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
                  context: context,
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
              child: const Text('Show image picker'),
              onPressed: () async {
                print(await popupManager.showImageSourcePicker(context: context));
              },
            ),
          ],
        ),
      ),
    );
  }
}

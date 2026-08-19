import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

const MethodChannel _coreChannel = MethodChannel('flutter_core');

/// Cihazdan gelen ülke adlarını taklit eder.
void _mockSystemCountryNames(Map<String, Map<String, String>> namesByLanguage) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_coreChannel, (call) async {
    if (call.method != 'getLocalizedCountryNames') return null;
    final arguments = (call.arguments as Map).cast<String, Object?>();
    final languageCode = arguments['languageCode']! as String;
    return namesByLanguage[languageCode] ?? <String, String>{};
  });
}

/// Uygulama dilini çalışma anında değiştirebilen test kabuğu.
Widget _localeApp(ValueNotifier<Locale> locale, Widget child) {
  return ValueListenableBuilder<Locale>(
    valueListenable: locale,
    builder: (context, value, _) => MaterialApp(
      locale: value,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: Scaffold(body: child),
    ),
  );
}

void _clearMockSystemCountryNames() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_coreChannel, null);
  CoreCountryLocalizations.clearSystemNames();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Testler arasında ülke adı önbelleği paylaşılmasın.
  setUp(_clearMockSystemCountryNames);
  group('CoreCountry', () {
    test('Should build flag emoji from iso code', () {
      expect(CoreCountry.fromIsoCode('TR')!.flagEmoji, '🇹🇷');
      expect(CoreCountry.fromIsoCode('us')!.flagEmoji, '🇺🇸');
    });

    test('Should find country by iso and dial code', () {
      expect(CoreCountry.fromIsoCode('TR')?.dialCode, '90');
      expect(CoreCountry.fromIsoCode('XX'), isNull);
      expect(CoreCountry.fromDialCode('+90')?.isoCode, 'TR');
      expect(CoreCountry.fromDialCode('49')?.isoCode, 'DE');
    });

    test('Should match query by name, iso code and dial code', () {
      final turkiye = CoreCountry.fromIsoCode('TR')!;
      expect(turkiye.matches('türk'), isTrue);
      expect(turkiye.matches('turk'), isTrue);
      expect(turkiye.matches('TR'), isTrue);
      expect(turkiye.matches('+90'), isTrue);
      expect(turkiye.matches('almanya'), isFalse);
    });

    test('Should resolve display name by locale', () {
      final germany = CoreCountry.fromIsoCode('DE')!;
      expect(germany.displayName(const Locale('tr')), 'Almanya');
      expect(germany.displayName(const Locale('en')), 'Germany');
      expect(germany.displayName(), 'Germany');
    });

    test('Should expose mask length as max length', () {
      expect(CoreCountry.fromIsoCode('TR')!.maxLength, 10);
      expect(CoreCountry.fromIsoCode('DE')!.maxLength, 11);
    });

    test('Should not contain duplicated iso codes', () {
      final isoCodes = kCoreCountries.map((e) => e.isoCode).toSet();
      expect(isoCodes.length, kCoreCountries.length);
    });
  });

  group('CorePhoneNumber', () {
    test('Should build complete number and validity', () {
      final phone = CorePhoneNumber(
        country: CoreCountry.fromIsoCode('TR')!,
        number: '5551112233',
        formattedNumber: '555 111 22 33',
      );
      expect(phone.completeNumber, '+905551112233');
      expect(phone.formattedCompleteNumber, '+90 555 111 22 33');
      expect(phone.isValid, isTrue);
      expect(phone.isEmpty, isFalse);
      expect(phone.copyWith(number: '555').isValid, isFalse);
    });
  });

  group('CorePhoneNumberTextField.withCountryPicker', () {
    testWidgets('Should show default country and format by its mask', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(CorePhoneNumberTextField.withCountryPicker(controller: controller)),
      );

      expect(find.text('+90'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '5551112233');
      await tester.pump();
      expect(controller.text, '555 111 22 33');
    });

    testWidgets('Should use given initial country', (tester) async {
      await tester.pumpWidget(
        _app(const CorePhoneNumberTextField.withCountryPicker(initialCountryIsoCode: 'DE')),
      );

      expect(find.text('+49'), findsOneWidget);
    });

    testWidgets('Should open picker, search and select a country', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      CoreCountry? selectedCountry;
      CorePhoneNumber? phoneNumber;

      await tester.pumpWidget(
        _app(
          CorePhoneNumberTextField.withCountryPicker(
            controller: controller,
            onCountryChanged: (country) => selectedCountry = country,
            onPhoneNumberChanged: (phone) => phoneNumber = phone,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '5551112233');
      await tester.pump();
      expect(controller.text, '555 111 22 33');

      await tester.tap(find.text('+90'));
      await tester.pumpAndSettle();
      expect(find.text('Ülke Seçin'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Ülke arayın...'), 'almanya');
      await tester.pumpAndSettle();
      expect(find.text('Germany'), findsOneWidget);
      expect(find.text('France'), findsNothing);

      await tester.tap(find.text('Germany'));
      await tester.pumpAndSettle();

      expect(selectedCountry?.isoCode, 'DE');
      expect(find.text('+49'), findsOneWidget);
      // Almanya maskesi (#### #######) ile yeniden biçimlendirilir.
      expect(controller.text, '5551 112233');
      expect(phoneNumber?.completeNumber, '+495551112233');
    });

    testWidgets('Should show empty result text when nothing matches', (tester) async {
      await tester.pumpWidget(
        _app(const CorePhoneNumberTextField.withCountryPicker()),
      );

      await tester.tap(find.text('+90'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Ülke arayın...'), 'zzzzzz');
      await tester.pumpAndSettle();
      expect(find.text('Sonuç bulunamadı'), findsOneWidget);
    });

    testWidgets('Should keep favorite countries on top', (tester) async {
      await tester.pumpWidget(
        _app(
          const CorePhoneNumberTextField.withCountryPicker(
            countryPickerOptions: CoreCountryPickerOptions(favoriteIsoCodes: ['TR', 'US']),
          ),
        ),
      );

      await tester.tap(find.text('+90'));
      await tester.pumpAndSettle();

      // Her satır sırasıyla bayrak, ülke adı ve ülke kodu metinlerinden oluşur.
      final texts = tester.widgetList<Text>(find.descendant(of: find.byType(ListView), matching: find.byType(Text))).map((e) => e.data).toList();
      expect(texts.sublist(0, 6), ['🇹🇷', 'Turkiye', '+90', '🇺🇸', 'United States', '+1']);
    });

    testWidgets('Should not open picker when disabled', (tester) async {
      await tester.pumpWidget(
        _app(const CorePhoneNumberTextField.withCountryPicker(enabled: false)),
      );

      await tester.tap(find.text('+90'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Ülke Seçin'), findsNothing);
    });

    testWidgets('Should run phoneNumberValidator with country aware value', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _app(
          Form(
            key: formKey,
            child: CorePhoneNumberTextField.withCountryPicker(
              phoneNumberValidator: (phone) => phone.isValid ? null : 'Geçersiz numara',
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Geçersiz numara'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '5551112233');
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('Should keep working without country picker (backward compatibility)', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(
          CorePhoneNumberTextField(
            controller: controller,
            format: PhoneNumberFormat.prefixWithZeroParens,
          ),
        ),
      );

      expect(find.text('0 (5'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '551112233');
      await tester.pump();
      expect(controller.text, '55) 111 22 33');
    });
  });

  group('CoreCountryPickerSheet', () {
    testWidgets('Should be usable standalone and return selected country', (tester) async {
      CoreCountry? result;

      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async => result = await CoreCountryPickerSheet.show(context),
              child: const Text('Aç'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Ülke arayın...'), 'France');
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(ListView), matching: find.text('France')));
      await tester.pumpAndSettle();

      expect(result?.isoCode, 'FR');
    });
  });

  group('CoreCountryLocalizations', () {
    tearDown(() {
      CoreCountryLocalizations.unregister();
      _clearMockSystemCountryNames();
    });

    test('Should fall back to english when nothing is registered or loaded', () {
      expect(CoreCountry.fromIsoCode('TR')!.displayName(const Locale('ar')), 'Turkiye');
    });

    test('Should keep built-in turkish names', () {
      expect(CoreCountry.fromIsoCode('DE')!.displayName(const Locale('tr')), 'Almanya');
    });

    test('Should use names coming from the device', () async {
      _mockSystemCountryNames({
        'ar': {'TR': 'تركيا', 'DE': 'ألمانيا'},
      });

      await CoreCountryLocalizations.load(const Locale('ar'));

      expect(CoreCountry.fromIsoCode('TR')!.displayName(const Locale('ar')), 'تركيا');
      expect(CoreCountry.fromIsoCode('DE')!.displayName(const Locale('ar')), 'ألمانيا');
      // Cihazın döndürmediği ülke ingilizce adına düşer.
      expect(CoreCountry.fromIsoCode('FR')!.displayName(const Locale('ar')), 'France');
    });

    test('Should bump revision after loading', () async {
      _mockSystemCountryNames({
        'ar': {'TR': 'تركيا'},
      });
      final before = CoreCountryLocalizations.revision.value;

      await CoreCountryLocalizations.load(const Locale('ar'));

      expect(CoreCountryLocalizations.revision.value, greaterThan(before));
    });

    test('Should not call the platform twice for the same language', () async {
      var callCount = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_coreChannel, (call) async {
        callCount++;
        return <String, String>{'TR': 'تركيا'};
      });

      await CoreCountryLocalizations.load(const Locale('ar'));
      await CoreCountryLocalizations.load(const Locale('ar'));

      expect(callCount, 1);
    });

    test('Should fall back gracefully when the platform is not available', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_coreChannel, (call) async {
        throw MissingPluginException();
      });

      await CoreCountryLocalizations.load(const Locale('ar'));

      expect(CoreCountry.fromIsoCode('TR')!.displayName(const Locale('ar')), 'Turkiye');
    });

    test('Registered names should win over the device names', () async {
      _mockSystemCountryNames({
        'tr': {'MK': 'Makedonya'},
      });
      await CoreCountryLocalizations.load(const Locale('tr'));
      expect(CoreCountry.fromIsoCode('MK')!.displayName(const Locale('tr')), 'Makedonya');

      CoreCountryLocalizations.register('tr', {'MK': 'Kuzey Makedonya'});
      expect(CoreCountry.fromIsoCode('MK')!.displayName(const Locale('tr')), 'Kuzey Makedonya');
      expect(CoreCountryLocalizations.registeredLanguageCodes, contains('tr'));
    });

    test('Should search by the resolved name', () async {
      _mockSystemCountryNames({
        'ar': {'TR': 'تركيا'},
      });
      await CoreCountryLocalizations.load(const Locale('ar'));
      final turkiye = CoreCountry.fromIsoCode('TR')!;

      expect(turkiye.matches('تركيا', locale: const Locale('ar')), isTrue);
      expect(turkiye.matches('تركيا'), isFalse);
    });

    testWidgets('Should follow the app language changed at runtime', (tester) async {
      _mockSystemCountryNames({
        'en': {'TR': 'Turkiye (en)'},
        'ar': {'TR': 'تركيا'},
      });
      final locale = ValueNotifier(const Locale('en'));
      addTearDown(locale.dispose);

      await tester.pumpWidget(
        _localeApp(
          locale,
          const CorePhoneNumberTextField.withCountryPicker(
            countryPickerOptions: CoreCountryPickerOptions(favoriteIsoCodes: ['TR']),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('+90'));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byType(ListView), matching: find.text('Turkiye (en)')), findsOneWidget);

      // Kullanıcı uygulama içinden dili değiştirir.
      locale.value = const Locale('ar');
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(ListView), matching: find.text('تركيا')), findsOneWidget);
      expect(find.descendant(of: find.byType(ListView), matching: find.text('Turkiye (en)')), findsNothing);
    });

    testWidgets('Should show device names in the picker and sort by them', (tester) async {
      _mockSystemCountryNames({
        'en': {'TR': 'Aaa Turkiye', 'DE': 'Zzz Germany'},
      });

      await tester.pumpWidget(
        _app(const CorePhoneNumberTextField.withCountryPicker()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('+90'));
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(ListView), matching: find.text('Aaa Turkiye')), findsOneWidget);
      // Sıralama gösterilen ada göre yapılır; 'Aaa Turkiye' en başa geçer.
      final names = tester.widgetList<Text>(find.descendant(of: find.byType(ListView), matching: find.byType(Text))).map((e) => e.data).toList();
      expect(names[1], 'Aaa Turkiye');
    });
  });

  group('CorePhoneNumberController', () {
    test('Should expose country and number together', () {
      final controller = CorePhoneNumberController(isoCode: 'TR', number: '5551112233');
      addTearDown(controller.dispose);

      expect(controller.text, '555 111 22 33');
      expect(controller.number, '5551112233');
      expect(controller.country.isoCode, 'TR');
      expect(controller.completeNumber, '+905551112233');
      expect(controller.formattedCompleteNumber, '+90 555 111 22 33');
      expect(controller.isValid, isTrue);
      expect(controller.phoneNumber.completeNumber, '+905551112233');
    });

    test('Should default to TR and return empty complete number when empty', () {
      final controller = CorePhoneNumberController();
      addTearDown(controller.dispose);

      expect(controller.country.isoCode, 'TR');
      expect(controller.completeNumber, '');
      expect(controller.isValid, isFalse);
    });

    test('Should re-mask the number when country changes', () {
      final controller = CorePhoneNumberController(isoCode: 'TR', number: '5551112233');
      addTearDown(controller.dispose);

      controller.country = CoreCountry.fromIsoCode('DE')!;
      expect(controller.text, '5551 112233');
      expect(controller.number, '5551112233');
      expect(controller.completeNumber, '+495551112233');
    });

    test('Should notify listeners when only the country changes', () {
      final controller = CorePhoneNumberController(isoCode: 'TR');
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);

      controller.country = CoreCountry.fromIsoCode('DE')!;
      expect(notified, greaterThan(0));
    });

    test('Should apply custom mask resolver', () {
      final controller = CorePhoneNumberController(
        isoCode: 'TR',
        number: '5551112233',
        maskResolver: (country) => '(###) ### ## ##',
      );
      addTearDown(controller.dispose);

      expect(controller.text, '(555) 111 22 33');
      expect(controller.number, '5551112233');
    });

    test('Should clear only the number', () {
      final controller = CorePhoneNumberController(isoCode: 'DE', number: '5551112233');
      addTearDown(controller.dispose);

      controller.clearNumber();
      expect(controller.text, '');
      expect(controller.country.isoCode, 'DE');
    });

    testWidgets('Should stay in sync with the field', (tester) async {
      final controller = CorePhoneNumberController(isoCode: 'TR');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(CorePhoneNumberTextField.withCountryPicker(controller: controller)),
      );

      await tester.enterText(find.byType(TextFormField), '5551112233');
      await tester.pump();
      expect(controller.completeNumber, '+905551112233');

      await tester.tap(find.text('+90'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Ülke arayın...'), 'Germany');
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(ListView), matching: find.text('Germany')));
      await tester.pumpAndSettle();

      expect(controller.country.isoCode, 'DE');
      expect(controller.text, '5551 112233');
      expect(controller.completeNumber, '+495551112233');
      expect(find.text('+49'), findsOneWidget);
    });

    testWidgets('Should update the field when the country is set on the controller', (tester) async {
      final controller = CorePhoneNumberController(isoCode: 'TR');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(CorePhoneNumberTextField.withCountryPicker(controller: controller)),
      );
      expect(find.text('+90'), findsOneWidget);

      controller.country = CoreCountry.fromIsoCode('FR')!;
      await tester.pump();
      expect(find.text('+33'), findsOneWidget);
    });

    testWidgets('Should let the widget override the controller country', (tester) async {
      final controller = CorePhoneNumberController(isoCode: 'TR');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(CorePhoneNumberTextField.withCountryPicker(controller: controller, initialCountryIsoCode: 'DE')),
      );

      expect(controller.country.isoCode, 'DE');
      expect(find.text('+49'), findsOneWidget);
    });
  });

  group('CoreCountryFlag', () {
    testWidgets('Should default to circle shape and accept rounded', (tester) async {
      final turkiye = CoreCountry.fromIsoCode('TR')!;

      await tester.pumpWidget(
        _app(
          Column(
            children: [
              CoreCountryFlag(country: turkiye),
              CoreCountryFlag(country: turkiye, shape: CoreCountryFlagShape.rounded),
            ],
          ),
        ),
      );

      expect(find.text('🇹🇷'), findsNWidgets(2));
      expect(tester.widget<CoreCountryFlag>(find.byType(CoreCountryFlag).first).shape, CoreCountryFlagShape.circle);
    });
  });
}

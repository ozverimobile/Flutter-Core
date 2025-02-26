import 'package:flutter_core_example/popup_manager/selectable_sheets_for_integration_test.dart' show SelectableSheetsForIntegrationTest;
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Selectable Search Sheet Integration Test',
    ($) async {
      $.tester.binding.platformDispatcher.onSemanticsEnabledChanged = () {};

      // Uygulama çalıştırılır
      await $.pumpWidgetAndSettle(const SelectableSheetsForIntegrationTest());

      // Show single seletable sheet butonunu bul
      final showSingleSelectableSearchViewButtonFinder = $(SelectableSheetsForIntegrationTest.showSingleSelectableSearchViewButtonFinder);

      // Butonun varlığını kontrol et
      expect($(showSingleSelectableSearchViewButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(showSingleSelectableSearchViewButtonFinder);

      // Liste içindeki tüm öğeleri bul (Hem RadioListTile hem de CheckboxListTile)
      final radioItems = $('title');
      expect(radioItems, findsOneWidget);
      await $.tap(radioItems);
      expect(radioItems, findsNothing);
      await $.pumpAndSettle();
      final selectedItemText = $(SelectableSheetsForIntegrationTest.items.first.title);
      expect(selectedItemText, findsOneWidget);
    },
  );
}

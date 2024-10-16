import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class SelectableSearchSheetViewModel<T extends SelectableSearchMixin> {
  SelectableSearchSheetViewModel({
    required this.scrollController,
    required this.draggableScrollableController,
    required this.type,
    required this.titleMaxLine,
    required this.subtitleMaxLine,
    required this.titleOverflow,
    required this.subtitleOverflow,
    required this.controlAffinity,
    required this.showItemCount,
    required this.title,
    required this.showDragHandle,
    required this.borderRadius,
    required this.emptyResultText,
    required this.searchHintText,
    required this.maxDisplayLimit,
    required this.popupManager,
    required this.popupKey,
    required this.searchFieldPadding,
    required this.showSelectAllButton,
    this.items,
    this.selected,
    this.selectedItems,
  });

  final List<T>? items;
  final T? selected;
  final List<T>? selectedItems;
  final ScrollController? scrollController;
  final DraggableScrollableController draggableScrollableController;
  final SelectableSearchSheetType type;
  final String? title;
  final int titleMaxLine;
  final int subtitleMaxLine;
  final TextOverflow titleOverflow;
  final TextOverflow subtitleOverflow;
  final ListTileControlAffinity controlAffinity;
  final bool showItemCount;
  final bool showDragHandle;
  final BorderRadiusGeometry borderRadius;
  final String emptyResultText;
  final String searchHintText;
  final int maxDisplayLimit;
  final PopupManager popupManager;
  final String popupKey;
  final EdgeInsetsGeometry searchFieldPadding;
  final bool showSelectAllButton;

  ValueNotifier<bool> isPinned = ValueNotifier(false);
  ValueNotifier<List<T>> itemsNotifier = ValueNotifier([]);
  ValueNotifier<List<T>> selectedItemsNotifier = ValueNotifier([]);
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  void init() {
    draggableScrollableController.addListener(_onDrag);
    items?.removeWhere((e) => e.active == false);
    itemsNotifier.value = List.from(items ?? []);
    if (type == SelectableSearchSheetType.single && selected != null) {
      selectedItemsNotifier.value = [selected!];
    } else if (type == SelectableSearchSheetType.multi && selectedItems != null) {
      selectedItemsNotifier.value = List.from(selectedItems!);
    }
  }

  void dispose() {
    draggableScrollableController.removeListener(_onDrag);
    searchController.dispose();
    searchFocusNode.dispose();
  }

  /// Callback when the draggable sheet is dragged
  void _onDrag() {
    isPinned.value = draggableScrollableController.size > 0.98;
  }

  /// Callback when the field tapped
  void select(T item) {
    if (type == SelectableSearchSheetType.single) {
      _singleSelect(item);
    } else {
      _multiSelect(item);
    }
  }

  void _singleSelect(T item) {
    if (item == selected) {
      selectedItemsNotifier.value = [];
    } else {
      selectedItemsNotifier.value = [item];
    }
    popupManager.hidePopup<T>(id: popupKey, result: item);
  }

  void _multiSelect(T item) {
    if (selectedItemsNotifier.value.contains(item)) {
      selectedItemsNotifier.value.remove(item);
    } else {
      selectedItemsNotifier.value.add(item);
    }
    selectedItemsNotifier.value = List.from(selectedItemsNotifier.value);
  }

  /// Callback when the search field changed
  void onFieldChanged(String? value) {
    if (value == null || items.isNullOrEmpty) return;
    final result = List<SelectableSearchMixin>.from(items!).where((e) => e.filter(value)).toList();
    itemsNotifier.value = List.from(result);
  }

  /// Callback when the select all button tapped
  void onSelectAll() {
    if (selectedItemsNotifier.value.length == items?.length) {
      selectedItemsNotifier.value = [];
    } else {
      selectedItemsNotifier.value = List.from(items ?? []);
    }
  }

  /// Callback when the save button
  void save() {
    popupManager.hidePopup<List<T>>(id: popupKey, result: selectedItemsNotifier.value);
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

enum SelectableSearchSheetType {
  single,
  multi,
}

class SelectableSearchSheetView<T extends SelectableSearchMixin> extends StatefulWidget {
  const SelectableSearchSheetView.single({
    required this.items,
    required this.selected,
    required this.title,
    required this.emptyResultText,
    required this.initialSize,
    required this.titleMaxLine,
    required this.subtitleMaxLine,
    required this.titleOverflow,
    required this.subtitleOverflow,
    required this.controlAffinity,
    required this.showItemCount,
    required this.showDragHandle,
    required this.borderRadius,
    required this.searchHintText,
    required this.popupManager,
    required this.popupKey,
    required this.maxDisplayLimit,
    required this.searchFieldPadding,
    required this.showSelectAllButton,
    super.key,
  })  : type = SelectableSearchSheetType.single,
        selectedItems = null;

  const SelectableSearchSheetView.multi({
    required this.items,
    required this.selectedItems,
    required this.title,
    required this.emptyResultText,
    required this.initialSize,
    required this.titleMaxLine,
    required this.subtitleMaxLine,
    required this.titleOverflow,
    required this.subtitleOverflow,
    required this.controlAffinity,
    required this.showItemCount,
    required this.showDragHandle,
    required this.borderRadius,
    required this.searchHintText,
    required this.popupManager,
    required this.popupKey,
    required this.maxDisplayLimit,
    required this.searchFieldPadding,
    required this.showSelectAllButton,
    super.key,
  })  : type = SelectableSearchSheetType.multi,
        selected = null;

  final List<T> items;
  final T? selected;
  final List<T>? selectedItems;
  final SelectableSearchSheetType type;
  final String? title;
  final String emptyResultText;
  final double initialSize;
  final int titleMaxLine;
  final int subtitleMaxLine;
  final TextOverflow titleOverflow;
  final TextOverflow subtitleOverflow;
  final ListTileControlAffinity controlAffinity;
  final bool showItemCount;
  final bool showDragHandle;
  final BorderRadiusGeometry borderRadius;
  final String searchHintText;
  final PopupManager popupManager;
  final String popupKey;
  final int maxDisplayLimit;
  final EdgeInsetsGeometry searchFieldPadding;
  final bool showSelectAllButton;

  @override
  State<SelectableSearchSheetView<T>> createState() => _SelectableSearchSheetViewState();
}

class _SelectableSearchSheetViewState<T extends SelectableSearchMixin> extends State<SelectableSearchSheetView<T>> {
  final _draggableScrollableController = DraggableScrollableController();

  SelectableSearchSheetViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        controller: _draggableScrollableController,
        initialChildSize: widget.initialSize,
        expand: false,
        builder: (context, scrollController) {
          viewModel ??= SelectableSearchSheetViewModel(
            searchFieldPadding: widget.searchFieldPadding,
            draggableScrollableController: _draggableScrollableController,
            items: widget.items,
            scrollController: scrollController,
            selected: widget.selected,
            selectedItems: widget.selectedItems,
            type: widget.type,
            title: widget.title,
            titleMaxLine: widget.titleMaxLine,
            subtitleMaxLine: widget.subtitleMaxLine,
            titleOverflow: widget.titleOverflow,
            subtitleOverflow: widget.subtitleOverflow,
            controlAffinity: widget.controlAffinity,
            showItemCount: widget.showItemCount,
            showDragHandle: widget.showDragHandle,
            borderRadius: widget.borderRadius,
            emptyResultText: widget.emptyResultText,
            searchHintText: widget.searchHintText,
            maxDisplayLimit: widget.maxDisplayLimit,
            popupManager: widget.popupManager,
            popupKey: widget.popupKey,
            showSelectAllButton: widget.showSelectAllButton,
          )..init();
          return DataProvider(
            data: viewModel!,
            child: const _SelectableSearchSheetSettings(),
          );
        },
      ),
    );
  }
}

class _SelectableSearchSheetSettings extends StatelessWidget {
  const _SelectableSearchSheetSettings();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    return ValueListenableBuilder(
      valueListenable: viewModel.isPinned,
      builder: (context, isPinned, child) {
        return ClipRRect(
          borderRadius: isPinned ? BorderRadius.zero : viewModel.borderRadius,
          child: const Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: _SaveButton(),
            body: Column(
              children: [
                _DragHandleWidget(),
                Expanded(
                  child: _SelectableSearchBody(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectableSearchBody<T extends SelectableSearchMixin> extends StatefulWidget {
  const _SelectableSearchBody({
    super.key,
  });

  @override
  State<_SelectableSearchBody> createState() => _SelectableSearchBodyState();
}

class _SelectableSearchBodyState<T extends SelectableSearchMixin> extends State<_SelectableSearchBody<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      controller: viewModel.scrollController,
      slivers: const [
        _SafeAreaSpace(),
        _AppBar(),
        _ItemCountText(),
        _ListItems(),
        SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}

class _SafeAreaSpace extends StatelessWidget {
  const _SafeAreaSpace();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    return ValueListenableBuilder(
      valueListenable: viewModel.isPinned,
      builder: (context, isPinned, child) {
        return SliverAppBar(
          backgroundColor: context.theme.appBarTheme.backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          pinned: true,
          toolbarHeight: isPinned ? (context.topSafeAreaPadding + (Platform.isAndroid ? 15 : 0)) : 0,
        );
      },
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    return ValueListenableBuilder(
      valueListenable: viewModel.isPinned,
      builder: (context, isPinned, child) {
        return SliverAppBar(
          toolbarHeight: (isPinned == false && (viewModel.title.isNullOrEmpty) ? (2 + viewModel.searchFieldPadding.vertical) : kToolbarHeight),
          backgroundColor: context.theme.appBarTheme.backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          pinned: true,
          automaticallyImplyLeading: isPinned,
          leading: isPinned
              ? BackButton(
                  key: UniqueKey(),
                )
              : null,
          title: Text(viewModel.title ?? ''),
          bottom: const _SearchBar(),
        );
      },
    );
  }
}

class _ItemCountText extends StatelessWidget {
  const _ItemCountText();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    if (viewModel.showItemCount == false && viewModel.showSelectAllButton == false) {
      return const SliverToBoxAdapter(child: CoreSizedBox.shrink());
    }
    return ValueListenableBuilder(
      valueListenable: viewModel.selectedItemsNotifier,
      builder: (context, selectedItems, child) {
        return SliverAppBar(
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  if (viewModel.showItemCount == false) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${selectedItems.length}/${viewModel.items?.length ?? 0}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
              if (viewModel.type == SelectableSearchSheetType.multi)
                Builder(
                  builder: (context) {
                    if (viewModel.showSelectAllButton == false) {
                      return const CoreSizedBox.shrink();
                    }
                    return CoreTextButton(
                      onPressed: viewModel.onSelectAll,
                      child: const Text('Tümünü Seç/Bırak'),
                    );
                  },
                ),
            ],
          ),
          pinned: true,
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    return Padding(
      padding: viewModel.searchFieldPadding,
      child: Builder(
        builder: (context) {
          final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
          if (Platform.isAndroid) {
            return CoreSearchTextField(
              controller: viewModel.searchController,
              focusNode: viewModel.searchFocusNode,
              onChanged: viewModel.onFieldChanged,
              hintText: viewModel.searchHintText,
            );
          }
          return CupertinoSearchTextField(
            controller: viewModel.searchController,
            focusNode: viewModel.searchFocusNode,
            onChanged: viewModel.onFieldChanged,
            placeholder: viewModel.searchHintText,
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 50);
}

class _ListItems extends StatelessWidget {
  const _ListItems();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    return ValueListenableBuilder(
      valueListenable: viewModel.itemsNotifier,
      builder: (context, items, child) {
        if (items.length > viewModel.maxDisplayLimit) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('Arama yapmak için bir şeyler yazın...'),
            ),
          );
        }
        if (items.isEmpty && viewModel.searchController.text.isNotEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(viewModel.emptyResultText),
            ),
          );
        }
        return SliverList.separated(
          itemBuilder: (context, index) {
            final item = items[index];
            return _TileWidget(
              item: item,
            );
          },
          separatorBuilder: (context, index) => const Divider(
            height: 0,
          ),
          itemCount: items.length,
        );
      },
    );
  }
}

class _TileWidget<T extends SelectableSearchMixin> extends StatelessWidget {
  const _TileWidget({required this.item});
  final T item;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    return ValueListenableBuilder(
      valueListenable: viewModel.selectedItemsNotifier,
      builder: (context, selectedItems, child) {
        if (viewModel.type == SelectableSearchSheetType.single) {
          return RadioListTile.adaptive(
            activeColor: context.theme.radioTheme.fillColor?.resolve({...WidgetState.values}),
            fillColor: context.theme.radioTheme.fillColor,
            controlAffinity: viewModel.controlAffinity,
            value: item,
            groupValue: selectedItems.firstOrNull as T?,
            title: item.title == null ? null : Text(item.title!, maxLines: viewModel.titleMaxLine, overflow: viewModel.titleOverflow),
            subtitle: item.subtitle == null ? null : Text(item.subtitle!, maxLines: viewModel.subtitleMaxLine, overflow: viewModel.subtitleOverflow),
            onChanged: (_) {
              viewModel.select(item);
            },
          );
        }
        return CheckboxListTile.adaptive(
          overlayColor: context.theme.checkboxTheme.overlayColor,
          checkColor: context.theme.checkboxTheme.checkColor?.resolve({...WidgetState.values}),
          fillColor: WidgetStateProperty.resolveWith((state) => _getCheckboxFillColor(context, state)),
          activeColor: Platform.isIOS ? null : context.theme.checkboxTheme.fillColor?.resolve({...WidgetState.values}),
          controlAffinity: viewModel.controlAffinity,
          value: selectedItems.contains(item),
          title: item.title == null ? null : Text(item.title!, maxLines: viewModel.titleMaxLine, overflow: viewModel.titleOverflow),
          subtitle: item.subtitle == null ? null : Text(item.subtitle!, maxLines: viewModel.subtitleMaxLine, overflow: viewModel.subtitleOverflow),
          onChanged: (_) => viewModel.select(item),
        );
      },
    );
  }

  Color? _getCheckboxFillColor(BuildContext context, Set<WidgetState> states) {
    if (Platform.isIOS) {
      return context.theme.checkboxTheme.fillColor?.resolve({...WidgetState.values});
    }
    const interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
      WidgetState.selected,
    };
    if (states.any(interactiveStates.contains)) {
      return context.theme.checkboxTheme.fillColor?.resolve(states);
    }
    return Colors.transparent;
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    if (viewModel.type == SelectableSearchSheetType.single) {
      return const SizedBox.shrink();
    }
    if (context.mediaQuery.viewInsets.bottom > 0) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer,
            border: Border(
              top: BorderSide(
                color: context.colorScheme.onSurface,
                width: 0.1,
              ),
            ),
          ),
          padding: const EdgeInsets.all(12).add(EdgeInsets.only(bottom: context.bottomSafeAreaPadding)),
          child: ValueListenableBuilder(
            valueListenable: viewModel.selectedItemsNotifier,
            builder: (context, items, child) {
              return CoreFilledButton(
                padding: EdgeInsets.zero,
                onPressed: viewModel.save,
                child: Center(
                  child: Text('${MaterialLocalizations.of(context).saveButtonLabel} ${items.isNotEmpty ? " (${items.length})" : ""}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DragHandleWidget extends StatelessWidget {
  const _DragHandleWidget();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.getDataProvider<SelectableSearchSheetViewModel>();
    if (viewModel.showDragHandle) {
      final bottomSheetTheme = Theme.of(context).bottomSheetTheme;
      final handleSize = bottomSheetTheme.dragHandleSize ?? const Size(32, 4);
      return ValueListenableBuilder(
        valueListenable: viewModel.isPinned,
        builder: (context, isPinned, child) {
          if (isPinned) {
            return const CoreSizedBox.shrink();
          }
          return Container(
            color: context.theme.appBarTheme.backgroundColor,
            height: kMinInteractiveDimension,
            width: double.infinity,
            child: Center(
              child: Container(
                height: handleSize.height,
                width: handleSize.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(handleSize.height / 2),
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      );
    }
    return const CoreSizedBox.shrink();
  }
}

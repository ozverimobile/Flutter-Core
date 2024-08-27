import 'package:flutter/widgets.dart';

@immutable
final class DataProvider extends InheritedWidget {
  const DataProvider({
    required this.data,
    required super.child,
    super.key,
  });

  final Object data;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static DataProvider of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<DataProvider>();
    return widget ?? (throw FlutterError('DataProvider not found in the widget tree'));
  }
}

extension DataProviderExtension on BuildContext {
  T getDataProvider<T>() {
    final widget = DataProvider.of(this);
    final data = widget.data is T ? widget.data as T : null;
    return data ?? (throw FlutterError('No matching data of type $T found in DataProvider'));
  }
}

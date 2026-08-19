import 'package:flutter_core/flutter_core.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class CoreRelativeHeight extends StatelessWidget {
  const CoreRelativeHeight(this.percentage, {super.key}) : assert(percentage >= 0 && percentage <= 1, 'Percentage must be between 0 and 1');

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height * percentage,
    );
  }
}

@immutable
class CoreRelativeWidth extends StatelessWidget {
  const CoreRelativeWidth(this.percentage, {super.key}) : assert(percentage >= 0 && percentage <= 1, 'Percentage must be between 0 and 1');

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width * percentage,
    );
  }
}

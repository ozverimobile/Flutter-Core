import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

@immutable
class CoreSemantics extends StatelessWidget {
  const CoreSemantics({required this.child, required this.id, super.key});

  final Widget child;
  final String id;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${Core.packageName}:id/$id',
      identifier: '${Core.packageName}:id/$id',
      child: child,
    );
  }
}

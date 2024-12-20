import 'package:flutter/material.dart';

@immutable
class CoreSizedBox extends SizedBox {
  const CoreSizedBox({super.child, super.width, super.height, super.key});

  const CoreSizedBox.shrink({super.key, super.child}) : super.shrink();

  const CoreSizedBox.expand({super.key, super.child}) : super.expand();

  CoreSizedBox operator +(CoreSizedBox other) {
    return CoreSizedBox(
      width: (width ?? 0.0) + (other.width ?? 0.0),
      height: (height ?? 0.0) + (other.height ?? 0.0),
    );
  }

  CoreSizedBox operator -(CoreSizedBox other) {
    return CoreSizedBox(
      width: (width ?? 0.0) - (other.width ?? 0.0),
      height: (height ?? 0.0) - (other.height ?? 0.0),
    );
  }

  
}

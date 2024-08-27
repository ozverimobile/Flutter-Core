import 'package:flutter/material.dart';

/// [PositionedBuilder]
typedef PositionedBuilder = Positioned Function(BuildContext context);

/// Record holds [OverlayEntry] and [AnimationController]
typedef ToastOverlayInfo = ({OverlayEntry entry, AnimationController slideAnimationController});

/// Record holds [OverlayEntry] and it's id
typedef OverlayEntryInfo = ({OverlayEntry entry, String id});

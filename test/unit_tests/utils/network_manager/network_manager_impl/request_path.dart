import 'package:flutter_core/flutter_core.dart';

enum RequestPath implements BaseRequestPath {
  defaultRequestTest('/defaultRequestTest'),
  defaultPrimitiveRequestTest('/defaultPrimitiveRequestTest');

  const RequestPath(this.value);

  final String value;

  @override
  String get asString => value;
}

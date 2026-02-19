import 'package:flutter_core/flutter_core.dart';

enum RequestPath implements BaseRequestPath {
  defaultRequestTest('/defaultRequestTest'),
  defaultPrimitiveRequestTest('/defaultPrimitiveRequestTest'),
  hasBaseResponseControlTest('/hasBaseResponseControlTest'),
  dataControlTest('/dataControlTest'),
  dioFormDataControlTest('/dioFormDataControlTest'),
  queryParametersControlTest('/queryParametersControlTest'),
  headersControlTest('/headersControlTest'),
  pathSuffixControlTest('/pathSuffixControlTest'),
  onUnauthorizedRequestTest('/onUnauthorizedRequestTest'),
  onServiceUnavailableRequestTest('/onServiceUnavailableRequestTest'),
  generalErrorRequestTest('/generalErrorRequestTest'),
  listResponseControlTest('/listResponseControlTest'),
  objectResponseControlTest('/objectResponseControlTest'),
  primitiveResponseControlTest('/primitiveResponseControlTest'),

  /// For Primitive Request
  dataControlTestForPrimitiveRequest('/dataControlTestForPrimitiveRequest'),
  dioFormDataControlTestForPrimitiveRequest('/dioFormDataControlTestForPrimitiveRequest'),
  queryParametersControlTestForPrimitiveRequest('/queryParametersControlTestForPrimitiveRequest'),
  headersControlTestForPrimitiveRequest('/headersControlTestForPrimitiveRequest'),
  pathSuffixControlTestForPrimitiveRequest('/pathSuffixControlTestForPrimitiveRequest'),
  onUnauthorizedRequestTestForPrimitiveRequest('/onUnauthorizedRequestTestForPrimitiveRequest'),
  onServiceUnavailableRequestTestForPrimitiveRequest('/onServiceUnavailableRequestTestForPrimitiveRequest'),
  generalErrorRequestTestForPrimitiveRequest('/generalErrorRequestTestForPrimitiveRequest'),
  uint8ListControlTestForPrimitiveRequest('/uint8ListControlTestForPrimitiveRequest'),
  primitiveTypeControlTestForPrimitiveRequest('/primitiveTypeControlTestForPrimitiveRequest'),
  ;

  const RequestPath(this.value);

  final String value;

  @override
  String get asString => value;
}

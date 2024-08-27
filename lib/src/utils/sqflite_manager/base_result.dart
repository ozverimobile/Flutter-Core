final class BaseResult<T> {
  BaseResult.success({this.data}) : error = null;

  BaseResult.error({required this.error}) : data = null;
  T? data;
  Object? error;

  bool get isSuccess => error == null;
}

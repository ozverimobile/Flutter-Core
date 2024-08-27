abstract mixin class BaseModel<T> {
  const BaseModel();

  T fromJson(Map<String, Object?> json);

  Map<String, Object?> toJson();
}

import 'package:flutter/foundation.dart';
import 'package:flutter_core/flutter_core.dart';

@immutable
final class TodoModel extends BaseModel<TodoModel> {
  const TodoModel({
    this.id,
    this.title,
    this.description,
    this.isDone,
  });

  factory TodoModel.fromMap(Map<String, dynamic> map) => const TodoModel().fromJson(map);

  final int? id;
  final String? title;
  final String? description;
  final int? isDone;

  @override
  TodoModel fromJson(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      isDone: map['isDone'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
    };
  }
}

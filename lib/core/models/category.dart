import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Category types for transactions
enum CategoryType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
  @JsonValue('investment')
  investment,
}

/// Category model for organizing transactions
@freezed
class Category with _$Category {
  const factory Category({
    int? id,
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  /// Create a new category
  factory Category.create({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
  }) {
    final now = DateTime.now();
    return Category(
      name: name,
      type: type,
      icon: icon,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
  }



  /// Create from database map
  factory Category.fromDatabase(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: CategoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CategoryType.expense,
      ),
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

/// Extension for CategoryType
extension CategoryTypeExtension on CategoryType {
  String get displayName {
    switch (this) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.investment:
        return 'Investment';
    }
  }

  String get icon {
    switch (this) {
      case CategoryType.income:
        return 'trending_up';
      case CategoryType.expense:
        return 'trending_down';
      case CategoryType.investment:
        return 'show_chart';
    }
  }
}

extension CategoryDatabase on Category {
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type.name,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
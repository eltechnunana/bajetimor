// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FinancialSummary _$FinancialSummaryFromJson(Map<String, dynamic> json) {
  return _FinancialSummary.fromJson(json);
}

/// @nodoc
mixin _$FinancialSummary {
  double get totalIncome => throw _privateConstructorUsedError;
  double get totalExpenses => throw _privateConstructorUsedError;
  double get totalInvestments => throw _privateConstructorUsedError;
  double get currentInvestmentValue => throw _privateConstructorUsedError;
  double get netWorth => throw _privateConstructorUsedError;
  double get savingsRate => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  List<CategorySummary> get incomeByCategory =>
      throw _privateConstructorUsedError;
  List<CategorySummary> get expensesByCategory =>
      throw _privateConstructorUsedError;
  List<CategorySummary> get investmentsByCategory =>
      throw _privateConstructorUsedError;

  /// Serializes this FinancialSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialSummaryCopyWith<FinancialSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialSummaryCopyWith<$Res> {
  factory $FinancialSummaryCopyWith(
    FinancialSummary value,
    $Res Function(FinancialSummary) then,
  ) = _$FinancialSummaryCopyWithImpl<$Res, FinancialSummary>;
  @useResult
  $Res call({
    double totalIncome,
    double totalExpenses,
    double totalInvestments,
    double currentInvestmentValue,
    double netWorth,
    double savingsRate,
    DateTime periodStart,
    DateTime periodEnd,
    List<CategorySummary> incomeByCategory,
    List<CategorySummary> expensesByCategory,
    List<CategorySummary> investmentsByCategory,
  });
}

/// @nodoc
class _$FinancialSummaryCopyWithImpl<$Res, $Val extends FinancialSummary>
    implements $FinancialSummaryCopyWith<$Res> {
  _$FinancialSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalIncome = null,
    Object? totalExpenses = null,
    Object? totalInvestments = null,
    Object? currentInvestmentValue = null,
    Object? netWorth = null,
    Object? savingsRate = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? incomeByCategory = null,
    Object? expensesByCategory = null,
    Object? investmentsByCategory = null,
  }) {
    return _then(
      _value.copyWith(
            totalIncome: null == totalIncome
                ? _value.totalIncome
                : totalIncome // ignore: cast_nullable_to_non_nullable
                      as double,
            totalExpenses: null == totalExpenses
                ? _value.totalExpenses
                : totalExpenses // ignore: cast_nullable_to_non_nullable
                      as double,
            totalInvestments: null == totalInvestments
                ? _value.totalInvestments
                : totalInvestments // ignore: cast_nullable_to_non_nullable
                      as double,
            currentInvestmentValue: null == currentInvestmentValue
                ? _value.currentInvestmentValue
                : currentInvestmentValue // ignore: cast_nullable_to_non_nullable
                      as double,
            netWorth: null == netWorth
                ? _value.netWorth
                : netWorth // ignore: cast_nullable_to_non_nullable
                      as double,
            savingsRate: null == savingsRate
                ? _value.savingsRate
                : savingsRate // ignore: cast_nullable_to_non_nullable
                      as double,
            periodStart: null == periodStart
                ? _value.periodStart
                : periodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            periodEnd: null == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            incomeByCategory: null == incomeByCategory
                ? _value.incomeByCategory
                : incomeByCategory // ignore: cast_nullable_to_non_nullable
                      as List<CategorySummary>,
            expensesByCategory: null == expensesByCategory
                ? _value.expensesByCategory
                : expensesByCategory // ignore: cast_nullable_to_non_nullable
                      as List<CategorySummary>,
            investmentsByCategory: null == investmentsByCategory
                ? _value.investmentsByCategory
                : investmentsByCategory // ignore: cast_nullable_to_non_nullable
                      as List<CategorySummary>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FinancialSummaryImplCopyWith<$Res>
    implements $FinancialSummaryCopyWith<$Res> {
  factory _$$FinancialSummaryImplCopyWith(
    _$FinancialSummaryImpl value,
    $Res Function(_$FinancialSummaryImpl) then,
  ) = __$$FinancialSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double totalIncome,
    double totalExpenses,
    double totalInvestments,
    double currentInvestmentValue,
    double netWorth,
    double savingsRate,
    DateTime periodStart,
    DateTime periodEnd,
    List<CategorySummary> incomeByCategory,
    List<CategorySummary> expensesByCategory,
    List<CategorySummary> investmentsByCategory,
  });
}

/// @nodoc
class __$$FinancialSummaryImplCopyWithImpl<$Res>
    extends _$FinancialSummaryCopyWithImpl<$Res, _$FinancialSummaryImpl>
    implements _$$FinancialSummaryImplCopyWith<$Res> {
  __$$FinancialSummaryImplCopyWithImpl(
    _$FinancialSummaryImpl _value,
    $Res Function(_$FinancialSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalIncome = null,
    Object? totalExpenses = null,
    Object? totalInvestments = null,
    Object? currentInvestmentValue = null,
    Object? netWorth = null,
    Object? savingsRate = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? incomeByCategory = null,
    Object? expensesByCategory = null,
    Object? investmentsByCategory = null,
  }) {
    return _then(
      _$FinancialSummaryImpl(
        totalIncome: null == totalIncome
            ? _value.totalIncome
            : totalIncome // ignore: cast_nullable_to_non_nullable
                  as double,
        totalExpenses: null == totalExpenses
            ? _value.totalExpenses
            : totalExpenses // ignore: cast_nullable_to_non_nullable
                  as double,
        totalInvestments: null == totalInvestments
            ? _value.totalInvestments
            : totalInvestments // ignore: cast_nullable_to_non_nullable
                  as double,
        currentInvestmentValue: null == currentInvestmentValue
            ? _value.currentInvestmentValue
            : currentInvestmentValue // ignore: cast_nullable_to_non_nullable
                  as double,
        netWorth: null == netWorth
            ? _value.netWorth
            : netWorth // ignore: cast_nullable_to_non_nullable
                  as double,
        savingsRate: null == savingsRate
            ? _value.savingsRate
            : savingsRate // ignore: cast_nullable_to_non_nullable
                  as double,
        periodStart: null == periodStart
            ? _value.periodStart
            : periodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        periodEnd: null == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        incomeByCategory: null == incomeByCategory
            ? _value._incomeByCategory
            : incomeByCategory // ignore: cast_nullable_to_non_nullable
                  as List<CategorySummary>,
        expensesByCategory: null == expensesByCategory
            ? _value._expensesByCategory
            : expensesByCategory // ignore: cast_nullable_to_non_nullable
                  as List<CategorySummary>,
        investmentsByCategory: null == investmentsByCategory
            ? _value._investmentsByCategory
            : investmentsByCategory // ignore: cast_nullable_to_non_nullable
                  as List<CategorySummary>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialSummaryImpl implements _FinancialSummary {
  const _$FinancialSummaryImpl({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalInvestments,
    required this.currentInvestmentValue,
    required this.netWorth,
    required this.savingsRate,
    required this.periodStart,
    required this.periodEnd,
    final List<CategorySummary> incomeByCategory = const [],
    final List<CategorySummary> expensesByCategory = const [],
    final List<CategorySummary> investmentsByCategory = const [],
  }) : _incomeByCategory = incomeByCategory,
       _expensesByCategory = expensesByCategory,
       _investmentsByCategory = investmentsByCategory;

  factory _$FinancialSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialSummaryImplFromJson(json);

  @override
  final double totalIncome;
  @override
  final double totalExpenses;
  @override
  final double totalInvestments;
  @override
  final double currentInvestmentValue;
  @override
  final double netWorth;
  @override
  final double savingsRate;
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  final List<CategorySummary> _incomeByCategory;
  @override
  @JsonKey()
  List<CategorySummary> get incomeByCategory {
    if (_incomeByCategory is EqualUnmodifiableListView)
      return _incomeByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_incomeByCategory);
  }

  final List<CategorySummary> _expensesByCategory;
  @override
  @JsonKey()
  List<CategorySummary> get expensesByCategory {
    if (_expensesByCategory is EqualUnmodifiableListView)
      return _expensesByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expensesByCategory);
  }

  final List<CategorySummary> _investmentsByCategory;
  @override
  @JsonKey()
  List<CategorySummary> get investmentsByCategory {
    if (_investmentsByCategory is EqualUnmodifiableListView)
      return _investmentsByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_investmentsByCategory);
  }

  @override
  String toString() {
    return 'FinancialSummary(totalIncome: $totalIncome, totalExpenses: $totalExpenses, totalInvestments: $totalInvestments, currentInvestmentValue: $currentInvestmentValue, netWorth: $netWorth, savingsRate: $savingsRate, periodStart: $periodStart, periodEnd: $periodEnd, incomeByCategory: $incomeByCategory, expensesByCategory: $expensesByCategory, investmentsByCategory: $investmentsByCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialSummaryImpl &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.totalExpenses, totalExpenses) ||
                other.totalExpenses == totalExpenses) &&
            (identical(other.totalInvestments, totalInvestments) ||
                other.totalInvestments == totalInvestments) &&
            (identical(other.currentInvestmentValue, currentInvestmentValue) ||
                other.currentInvestmentValue == currentInvestmentValue) &&
            (identical(other.netWorth, netWorth) ||
                other.netWorth == netWorth) &&
            (identical(other.savingsRate, savingsRate) ||
                other.savingsRate == savingsRate) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            const DeepCollectionEquality().equals(
              other._incomeByCategory,
              _incomeByCategory,
            ) &&
            const DeepCollectionEquality().equals(
              other._expensesByCategory,
              _expensesByCategory,
            ) &&
            const DeepCollectionEquality().equals(
              other._investmentsByCategory,
              _investmentsByCategory,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalIncome,
    totalExpenses,
    totalInvestments,
    currentInvestmentValue,
    netWorth,
    savingsRate,
    periodStart,
    periodEnd,
    const DeepCollectionEquality().hash(_incomeByCategory),
    const DeepCollectionEquality().hash(_expensesByCategory),
    const DeepCollectionEquality().hash(_investmentsByCategory),
  );

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialSummaryImplCopyWith<_$FinancialSummaryImpl> get copyWith =>
      __$$FinancialSummaryImplCopyWithImpl<_$FinancialSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialSummaryImplToJson(this);
  }
}

abstract class _FinancialSummary implements FinancialSummary {
  const factory _FinancialSummary({
    required final double totalIncome,
    required final double totalExpenses,
    required final double totalInvestments,
    required final double currentInvestmentValue,
    required final double netWorth,
    required final double savingsRate,
    required final DateTime periodStart,
    required final DateTime periodEnd,
    final List<CategorySummary> incomeByCategory,
    final List<CategorySummary> expensesByCategory,
    final List<CategorySummary> investmentsByCategory,
  }) = _$FinancialSummaryImpl;

  factory _FinancialSummary.fromJson(Map<String, dynamic> json) =
      _$FinancialSummaryImpl.fromJson;

  @override
  double get totalIncome;
  @override
  double get totalExpenses;
  @override
  double get totalInvestments;
  @override
  double get currentInvestmentValue;
  @override
  double get netWorth;
  @override
  double get savingsRate;
  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;
  @override
  List<CategorySummary> get incomeByCategory;
  @override
  List<CategorySummary> get expensesByCategory;
  @override
  List<CategorySummary> get investmentsByCategory;

  /// Create a copy of FinancialSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialSummaryImplCopyWith<_$FinancialSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategorySummary _$CategorySummaryFromJson(Map<String, dynamic> json) {
  return _CategorySummary.fromJson(json);
}

/// @nodoc
mixin _$CategorySummary {
  int get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;
  String? get categoryColor => throw _privateConstructorUsedError;
  String? get categoryIcon => throw _privateConstructorUsedError;

  /// Serializes this CategorySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategorySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategorySummaryCopyWith<CategorySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategorySummaryCopyWith<$Res> {
  factory $CategorySummaryCopyWith(
    CategorySummary value,
    $Res Function(CategorySummary) then,
  ) = _$CategorySummaryCopyWithImpl<$Res, CategorySummary>;
  @useResult
  $Res call({
    int categoryId,
    String categoryName,
    double amount,
    double percentage,
    String? categoryColor,
    String? categoryIcon,
  });
}

/// @nodoc
class _$CategorySummaryCopyWithImpl<$Res, $Val extends CategorySummary>
    implements $CategorySummaryCopyWith<$Res> {
  _$CategorySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategorySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? amount = null,
    Object? percentage = null,
    Object? categoryColor = freezed,
    Object? categoryIcon = freezed,
  }) {
    return _then(
      _value.copyWith(
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
            categoryColor: freezed == categoryColor
                ? _value.categoryColor
                : categoryColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryIcon: freezed == categoryIcon
                ? _value.categoryIcon
                : categoryIcon // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategorySummaryImplCopyWith<$Res>
    implements $CategorySummaryCopyWith<$Res> {
  factory _$$CategorySummaryImplCopyWith(
    _$CategorySummaryImpl value,
    $Res Function(_$CategorySummaryImpl) then,
  ) = __$$CategorySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int categoryId,
    String categoryName,
    double amount,
    double percentage,
    String? categoryColor,
    String? categoryIcon,
  });
}

/// @nodoc
class __$$CategorySummaryImplCopyWithImpl<$Res>
    extends _$CategorySummaryCopyWithImpl<$Res, _$CategorySummaryImpl>
    implements _$$CategorySummaryImplCopyWith<$Res> {
  __$$CategorySummaryImplCopyWithImpl(
    _$CategorySummaryImpl _value,
    $Res Function(_$CategorySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategorySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? amount = null,
    Object? percentage = null,
    Object? categoryColor = freezed,
    Object? categoryIcon = freezed,
  }) {
    return _then(
      _$CategorySummaryImpl(
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
        categoryColor: freezed == categoryColor
            ? _value.categoryColor
            : categoryColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryIcon: freezed == categoryIcon
            ? _value.categoryIcon
            : categoryIcon // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategorySummaryImpl implements _CategorySummary {
  const _$CategorySummaryImpl({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    this.categoryColor,
    this.categoryIcon,
  });

  factory _$CategorySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategorySummaryImplFromJson(json);

  @override
  final int categoryId;
  @override
  final String categoryName;
  @override
  final double amount;
  @override
  final double percentage;
  @override
  final String? categoryColor;
  @override
  final String? categoryIcon;

  @override
  String toString() {
    return 'CategorySummary(categoryId: $categoryId, categoryName: $categoryName, amount: $amount, percentage: $percentage, categoryColor: $categoryColor, categoryIcon: $categoryIcon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategorySummaryImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.categoryColor, categoryColor) ||
                other.categoryColor == categoryColor) &&
            (identical(other.categoryIcon, categoryIcon) ||
                other.categoryIcon == categoryIcon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryId,
    categoryName,
    amount,
    percentage,
    categoryColor,
    categoryIcon,
  );

  /// Create a copy of CategorySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategorySummaryImplCopyWith<_$CategorySummaryImpl> get copyWith =>
      __$$CategorySummaryImplCopyWithImpl<_$CategorySummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CategorySummaryImplToJson(this);
  }
}

abstract class _CategorySummary implements CategorySummary {
  const factory _CategorySummary({
    required final int categoryId,
    required final String categoryName,
    required final double amount,
    required final double percentage,
    final String? categoryColor,
    final String? categoryIcon,
  }) = _$CategorySummaryImpl;

  factory _CategorySummary.fromJson(Map<String, dynamic> json) =
      _$CategorySummaryImpl.fromJson;

  @override
  int get categoryId;
  @override
  String get categoryName;
  @override
  double get amount;
  @override
  double get percentage;
  @override
  String? get categoryColor;
  @override
  String? get categoryIcon;

  /// Create a copy of CategorySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategorySummaryImplCopyWith<_$CategorySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

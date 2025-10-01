// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinancialSummaryImpl _$$FinancialSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$FinancialSummaryImpl(
  totalIncome: (json['totalIncome'] as num).toDouble(),
  totalExpenses: (json['totalExpenses'] as num).toDouble(),
  totalInvestments: (json['totalInvestments'] as num).toDouble(),
  currentInvestmentValue: (json['currentInvestmentValue'] as num).toDouble(),
  netWorth: (json['netWorth'] as num).toDouble(),
  savingsRate: (json['savingsRate'] as num).toDouble(),
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  incomeByCategory:
      (json['incomeByCategory'] as List<dynamic>?)
          ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  expensesByCategory:
      (json['expensesByCategory'] as List<dynamic>?)
          ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  investmentsByCategory:
      (json['investmentsByCategory'] as List<dynamic>?)
          ?.map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$FinancialSummaryImplToJson(
  _$FinancialSummaryImpl instance,
) => <String, dynamic>{
  'totalIncome': instance.totalIncome,
  'totalExpenses': instance.totalExpenses,
  'totalInvestments': instance.totalInvestments,
  'currentInvestmentValue': instance.currentInvestmentValue,
  'netWorth': instance.netWorth,
  'savingsRate': instance.savingsRate,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'incomeByCategory': instance.incomeByCategory,
  'expensesByCategory': instance.expensesByCategory,
  'investmentsByCategory': instance.investmentsByCategory,
};

_$CategorySummaryImpl _$$CategorySummaryImplFromJson(
  Map<String, dynamic> json,
) => _$CategorySummaryImpl(
  categoryId: (json['categoryId'] as num).toInt(),
  categoryName: json['categoryName'] as String,
  amount: (json['amount'] as num).toDouble(),
  percentage: (json['percentage'] as num).toDouble(),
  categoryColor: json['categoryColor'] as String?,
  categoryIcon: json['categoryIcon'] as String?,
);

Map<String, dynamic> _$$CategorySummaryImplToJson(
  _$CategorySummaryImpl instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'amount': instance.amount,
  'percentage': instance.percentage,
  'categoryColor': instance.categoryColor,
  'categoryIcon': instance.categoryIcon,
};

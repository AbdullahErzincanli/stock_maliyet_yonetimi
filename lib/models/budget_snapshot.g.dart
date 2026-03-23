// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBudgetSnapshotCollection on Isar {
  IsarCollection<BudgetSnapshot> get budgetSnapshots => this.collection();
}

const BudgetSnapshotSchema = CollectionSchema(
  name: r'BudgetSnapshot',
  id: 4630608857998243371,
  properties: {
    r'budgetRatio': PropertySchema(
      id: 0,
      name: r'budgetRatio',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'suggestedBudget': PropertySchema(
      id: 2,
      name: r'suggestedBudget',
      type: IsarType.double,
    ),
    r'totalCost': PropertySchema(
      id: 3,
      name: r'totalCost',
      type: IsarType.double,
    ),
    r'totalRevenue': PropertySchema(
      id: 4,
      name: r'totalRevenue',
      type: IsarType.double,
    )
  },
  estimateSize: _budgetSnapshotEstimateSize,
  serialize: _budgetSnapshotSerialize,
  deserialize: _budgetSnapshotDeserialize,
  deserializeProp: _budgetSnapshotDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _budgetSnapshotGetId,
  getLinks: _budgetSnapshotGetLinks,
  attach: _budgetSnapshotAttach,
  version: '3.1.0+1',
);

int _budgetSnapshotEstimateSize(
  BudgetSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _budgetSnapshotSerialize(
  BudgetSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.budgetRatio);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeDouble(offsets[2], object.suggestedBudget);
  writer.writeDouble(offsets[3], object.totalCost);
  writer.writeDouble(offsets[4], object.totalRevenue);
}

BudgetSnapshot _budgetSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BudgetSnapshot();
  object.budgetRatio = reader.readDouble(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.id = id;
  object.suggestedBudget = reader.readDouble(offsets[2]);
  object.totalCost = reader.readDouble(offsets[3]);
  object.totalRevenue = reader.readDouble(offsets[4]);
  return object;
}

P _budgetSnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _budgetSnapshotGetId(BudgetSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _budgetSnapshotGetLinks(BudgetSnapshot object) {
  return [];
}

void _budgetSnapshotAttach(
    IsarCollection<dynamic> col, Id id, BudgetSnapshot object) {
  object.id = id;
}

extension BudgetSnapshotQueryWhereSort
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QWhere> {
  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BudgetSnapshotQueryWhere
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QWhereClause> {
  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BudgetSnapshotQueryFilter
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QFilterCondition> {
  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      budgetRatioEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetRatio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      budgetRatioGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'budgetRatio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      budgetRatioLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'budgetRatio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      budgetRatioBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'budgetRatio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      suggestedBudgetEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suggestedBudget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      suggestedBudgetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'suggestedBudget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      suggestedBudgetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'suggestedBudget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      suggestedBudgetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'suggestedBudget',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      totalCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      totalCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      totalCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      totalCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      totalRevenueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalRevenue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      totalRevenueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalRevenue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      totalRevenueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalRevenue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterFilterCondition>
      totalRevenueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalRevenue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension BudgetSnapshotQueryObject
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QFilterCondition> {}

extension BudgetSnapshotQueryLinks
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QFilterCondition> {}

extension BudgetSnapshotQuerySortBy
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QSortBy> {
  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      sortByBudgetRatio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetRatio', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      sortByBudgetRatioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetRatio', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      sortBySuggestedBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedBudget', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      sortBySuggestedBudgetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedBudget', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy> sortByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      sortByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      sortByTotalRevenue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRevenue', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      sortByTotalRevenueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRevenue', Sort.desc);
    });
  }
}

extension BudgetSnapshotQuerySortThenBy
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QSortThenBy> {
  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      thenByBudgetRatio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetRatio', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      thenByBudgetRatioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetRatio', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      thenBySuggestedBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedBudget', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      thenBySuggestedBudgetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedBudget', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy> thenByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      thenByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      thenByTotalRevenue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRevenue', Sort.asc);
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QAfterSortBy>
      thenByTotalRevenueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRevenue', Sort.desc);
    });
  }
}

extension BudgetSnapshotQueryWhereDistinct
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QDistinct> {
  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QDistinct>
      distinctByBudgetRatio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetRatio');
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QDistinct>
      distinctBySuggestedBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suggestedBudget');
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QDistinct>
      distinctByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCost');
    });
  }

  QueryBuilder<BudgetSnapshot, BudgetSnapshot, QDistinct>
      distinctByTotalRevenue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalRevenue');
    });
  }
}

extension BudgetSnapshotQueryProperty
    on QueryBuilder<BudgetSnapshot, BudgetSnapshot, QQueryProperty> {
  QueryBuilder<BudgetSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BudgetSnapshot, double, QQueryOperations> budgetRatioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetRatio');
    });
  }

  QueryBuilder<BudgetSnapshot, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<BudgetSnapshot, double, QQueryOperations>
      suggestedBudgetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suggestedBudget');
    });
  }

  QueryBuilder<BudgetSnapshot, double, QQueryOperations> totalCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCost');
    });
  }

  QueryBuilder<BudgetSnapshot, double, QQueryOperations>
      totalRevenueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalRevenue');
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReportSettingsCollection on Isar {
  IsarCollection<ReportSettings> get reportSettings => this.collection();
}

const ReportSettingsSchema = CollectionSchema(
  name: r'ReportSettings',
  id: -9182605105113159333,
  properties: {
    r'filterEndDate': PropertySchema(
      id: 0,
      name: r'filterEndDate',
      type: IsarType.dateTime,
    ),
    r'filterStartDate': PropertySchema(
      id: 1,
      name: r'filterStartDate',
      type: IsarType.dateTime,
    ),
    r'periodType': PropertySchema(
      id: 2,
      name: r'periodType',
      type: IsarType.string,
    ),
    r'showProfitAndCost': PropertySchema(
      id: 3,
      name: r'showProfitAndCost',
      type: IsarType.bool,
    ),
    r'showTime': PropertySchema(
      id: 4,
      name: r'showTime',
      type: IsarType.bool,
    ),
    r'startDayOfWeek': PropertySchema(
      id: 5,
      name: r'startDayOfWeek',
      type: IsarType.long,
    )
  },
  estimateSize: _reportSettingsEstimateSize,
  serialize: _reportSettingsSerialize,
  deserialize: _reportSettingsDeserialize,
  deserializeProp: _reportSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _reportSettingsGetId,
  getLinks: _reportSettingsGetLinks,
  attach: _reportSettingsAttach,
  version: '3.1.0+1',
);

int _reportSettingsEstimateSize(
  ReportSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.periodType.length * 3;
  return bytesCount;
}

void _reportSettingsSerialize(
  ReportSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.filterEndDate);
  writer.writeDateTime(offsets[1], object.filterStartDate);
  writer.writeString(offsets[2], object.periodType);
  writer.writeBool(offsets[3], object.showProfitAndCost);
  writer.writeBool(offsets[4], object.showTime);
  writer.writeLong(offsets[5], object.startDayOfWeek);
}

ReportSettings _reportSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReportSettings();
  object.filterEndDate = reader.readDateTimeOrNull(offsets[0]);
  object.filterStartDate = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.periodType = reader.readString(offsets[2]);
  object.showProfitAndCost = reader.readBool(offsets[3]);
  object.showTime = reader.readBool(offsets[4]);
  object.startDayOfWeek = reader.readLong(offsets[5]);
  return object;
}

P _reportSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reportSettingsGetId(ReportSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reportSettingsGetLinks(ReportSettings object) {
  return [];
}

void _reportSettingsAttach(
    IsarCollection<dynamic> col, Id id, ReportSettings object) {
  object.id = id;
}

extension ReportSettingsQueryWhereSort
    on QueryBuilder<ReportSettings, ReportSettings, QWhere> {
  QueryBuilder<ReportSettings, ReportSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReportSettingsQueryWhere
    on QueryBuilder<ReportSettings, ReportSettings, QWhereClause> {
  QueryBuilder<ReportSettings, ReportSettings, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ReportSettings, ReportSettings, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterWhereClause> idBetween(
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

extension ReportSettingsQueryFilter
    on QueryBuilder<ReportSettings, ReportSettings, QFilterCondition> {
  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterEndDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'filterEndDate',
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterEndDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'filterEndDate',
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterEndDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filterEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterEndDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filterEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterEndDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filterEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterEndDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filterEndDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterStartDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'filterStartDate',
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterStartDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'filterStartDate',
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterStartDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filterStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterStartDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filterStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterStartDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filterStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      filterStartDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filterStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
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

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
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

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'periodType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodType',
        value: '',
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      periodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'periodType',
        value: '',
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      showProfitAndCostEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showProfitAndCost',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      showTimeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      startDayOfWeekEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      startDayOfWeekGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      startDayOfWeekLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterFilterCondition>
      startDayOfWeekBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDayOfWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReportSettingsQueryObject
    on QueryBuilder<ReportSettings, ReportSettings, QFilterCondition> {}

extension ReportSettingsQueryLinks
    on QueryBuilder<ReportSettings, ReportSettings, QFilterCondition> {}

extension ReportSettingsQuerySortBy
    on QueryBuilder<ReportSettings, ReportSettings, QSortBy> {
  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByFilterEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterEndDate', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByFilterEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterEndDate', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByFilterStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterStartDate', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByFilterStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterStartDate', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByPeriodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByShowProfitAndCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showProfitAndCost', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByShowProfitAndCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showProfitAndCost', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy> sortByShowTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showTime', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByShowTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showTime', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByStartDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDayOfWeek', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      sortByStartDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDayOfWeek', Sort.desc);
    });
  }
}

extension ReportSettingsQuerySortThenBy
    on QueryBuilder<ReportSettings, ReportSettings, QSortThenBy> {
  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByFilterEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterEndDate', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByFilterEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterEndDate', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByFilterStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterStartDate', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByFilterStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterStartDate', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByPeriodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByShowProfitAndCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showProfitAndCost', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByShowProfitAndCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showProfitAndCost', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy> thenByShowTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showTime', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByShowTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showTime', Sort.desc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByStartDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDayOfWeek', Sort.asc);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QAfterSortBy>
      thenByStartDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDayOfWeek', Sort.desc);
    });
  }
}

extension ReportSettingsQueryWhereDistinct
    on QueryBuilder<ReportSettings, ReportSettings, QDistinct> {
  QueryBuilder<ReportSettings, ReportSettings, QDistinct>
      distinctByFilterEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterEndDate');
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QDistinct>
      distinctByFilterStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterStartDate');
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QDistinct> distinctByPeriodType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QDistinct>
      distinctByShowProfitAndCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showProfitAndCost');
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QDistinct> distinctByShowTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showTime');
    });
  }

  QueryBuilder<ReportSettings, ReportSettings, QDistinct>
      distinctByStartDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDayOfWeek');
    });
  }
}

extension ReportSettingsQueryProperty
    on QueryBuilder<ReportSettings, ReportSettings, QQueryProperty> {
  QueryBuilder<ReportSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReportSettings, DateTime?, QQueryOperations>
      filterEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterEndDate');
    });
  }

  QueryBuilder<ReportSettings, DateTime?, QQueryOperations>
      filterStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterStartDate');
    });
  }

  QueryBuilder<ReportSettings, String, QQueryOperations> periodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodType');
    });
  }

  QueryBuilder<ReportSettings, bool, QQueryOperations>
      showProfitAndCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showProfitAndCost');
    });
  }

  QueryBuilder<ReportSettings, bool, QQueryOperations> showTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showTime');
    });
  }

  QueryBuilder<ReportSettings, int, QQueryOperations> startDayOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDayOfWeek');
    });
  }
}

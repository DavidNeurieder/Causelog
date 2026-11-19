// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SearchResultEntityTypeEnum _$searchResultEntityTypeEnum_project =
    const SearchResultEntityTypeEnum._('project');
const SearchResultEntityTypeEnum _$searchResultEntityTypeEnum_goal =
    const SearchResultEntityTypeEnum._('goal');
const SearchResultEntityTypeEnum _$searchResultEntityTypeEnum_decision =
    const SearchResultEntityTypeEnum._('decision');
const SearchResultEntityTypeEnum _$searchResultEntityTypeEnum_experiment =
    const SearchResultEntityTypeEnum._('experiment');
const SearchResultEntityTypeEnum _$searchResultEntityTypeEnum_note =
    const SearchResultEntityTypeEnum._('note');

SearchResultEntityTypeEnum _$searchResultEntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'project':
      return _$searchResultEntityTypeEnum_project;
    case 'goal':
      return _$searchResultEntityTypeEnum_goal;
    case 'decision':
      return _$searchResultEntityTypeEnum_decision;
    case 'experiment':
      return _$searchResultEntityTypeEnum_experiment;
    case 'note':
      return _$searchResultEntityTypeEnum_note;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SearchResultEntityTypeEnum> _$searchResultEntityTypeEnumValues =
    BuiltSet<SearchResultEntityTypeEnum>(const <SearchResultEntityTypeEnum>[
  _$searchResultEntityTypeEnum_project,
  _$searchResultEntityTypeEnum_goal,
  _$searchResultEntityTypeEnum_decision,
  _$searchResultEntityTypeEnum_experiment,
  _$searchResultEntityTypeEnum_note,
]);

Serializer<SearchResultEntityTypeEnum> _$searchResultEntityTypeEnumSerializer =
    _$SearchResultEntityTypeEnumSerializer();

class _$SearchResultEntityTypeEnumSerializer
    implements PrimitiveSerializer<SearchResultEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'project': 'project',
    'goal': 'goal',
    'decision': 'decision',
    'experiment': 'experiment',
    'note': 'note',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'project': 'project',
    'goal': 'goal',
    'decision': 'decision',
    'experiment': 'experiment',
    'note': 'note',
  };

  @override
  final Iterable<Type> types = const <Type>[SearchResultEntityTypeEnum];
  @override
  final String wireName = 'SearchResultEntityTypeEnum';

  @override
  Object serialize(Serializers serializers, SearchResultEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SearchResultEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SearchResultEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SearchResult extends SearchResult {
  @override
  final SearchResultEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String projectId;
  @override
  final String projectTitle;
  @override
  final String title;
  @override
  final String snippet;
  @override
  final num rank;

  factory _$SearchResult([void Function(SearchResultBuilder)? updates]) =>
      (SearchResultBuilder()..update(updates))._build();

  _$SearchResult._(
      {required this.entityType,
      required this.entityId,
      required this.projectId,
      required this.projectTitle,
      required this.title,
      required this.snippet,
      required this.rank})
      : super._();
  @override
  SearchResult rebuild(void Function(SearchResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SearchResultBuilder toBuilder() => SearchResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchResult &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        projectId == other.projectId &&
        projectTitle == other.projectTitle &&
        title == other.title &&
        snippet == other.snippet &&
        rank == other.rank;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, projectTitle.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, snippet.hashCode);
    _$hash = $jc(_$hash, rank.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchResult')
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('projectId', projectId)
          ..add('projectTitle', projectTitle)
          ..add('title', title)
          ..add('snippet', snippet)
          ..add('rank', rank))
        .toString();
  }
}

class SearchResultBuilder
    implements Builder<SearchResult, SearchResultBuilder> {
  _$SearchResult? _$v;

  SearchResultEntityTypeEnum? _entityType;
  SearchResultEntityTypeEnum? get entityType => _$this._entityType;
  set entityType(SearchResultEntityTypeEnum? entityType) =>
      _$this._entityType = entityType;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  String? _projectTitle;
  String? get projectTitle => _$this._projectTitle;
  set projectTitle(String? projectTitle) => _$this._projectTitle = projectTitle;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _snippet;
  String? get snippet => _$this._snippet;
  set snippet(String? snippet) => _$this._snippet = snippet;

  num? _rank;
  num? get rank => _$this._rank;
  set rank(num? rank) => _$this._rank = rank;

  SearchResultBuilder() {
    SearchResult._defaults(this);
  }

  SearchResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _projectId = $v.projectId;
      _projectTitle = $v.projectTitle;
      _title = $v.title;
      _snippet = $v.snippet;
      _rank = $v.rank;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchResult other) {
    _$v = other as _$SearchResult;
  }

  @override
  void update(void Function(SearchResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchResult build() => _build();

  _$SearchResult _build() {
    final _$result = _$v ??
        _$SearchResult._(
          entityType: BuiltValueNullFieldError.checkNotNull(
              entityType, r'SearchResult', 'entityType'),
          entityId: BuiltValueNullFieldError.checkNotNull(
              entityId, r'SearchResult', 'entityId'),
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'SearchResult', 'projectId'),
          projectTitle: BuiltValueNullFieldError.checkNotNull(
              projectTitle, r'SearchResult', 'projectTitle'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'SearchResult', 'title'),
          snippet: BuiltValueNullFieldError.checkNotNull(
              snippet, r'SearchResult', 'snippet'),
          rank: BuiltValueNullFieldError.checkNotNull(
              rank, r'SearchResult', 'rank'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

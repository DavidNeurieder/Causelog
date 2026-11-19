// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActivityItem extends ActivityItem {
  @override
  final String kind;
  @override
  final int atMs;
  @override
  final String? entityType;
  @override
  final String? entityId;
  @override
  final String title;

  factory _$ActivityItem([void Function(ActivityItemBuilder)? updates]) =>
      (ActivityItemBuilder()..update(updates))._build();

  _$ActivityItem._(
      {required this.kind,
      required this.atMs,
      this.entityType,
      this.entityId,
      required this.title})
      : super._();
  @override
  ActivityItem rebuild(void Function(ActivityItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActivityItemBuilder toBuilder() => ActivityItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActivityItem &&
        kind == other.kind &&
        atMs == other.atMs &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, atMs.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActivityItem')
          ..add('kind', kind)
          ..add('atMs', atMs)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('title', title))
        .toString();
  }
}

class ActivityItemBuilder
    implements Builder<ActivityItem, ActivityItemBuilder> {
  _$ActivityItem? _$v;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  int? _atMs;
  int? get atMs => _$this._atMs;
  set atMs(int? atMs) => _$this._atMs = atMs;

  String? _entityType;
  String? get entityType => _$this._entityType;
  set entityType(String? entityType) => _$this._entityType = entityType;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  ActivityItemBuilder() {
    ActivityItem._defaults(this);
  }

  ActivityItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _atMs = $v.atMs;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActivityItem other) {
    _$v = other as _$ActivityItem;
  }

  @override
  void update(void Function(ActivityItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActivityItem build() => _build();

  _$ActivityItem _build() {
    final _$result = _$v ??
        _$ActivityItem._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ActivityItem', 'kind'),
          atMs: BuiltValueNullFieldError.checkNotNull(
              atMs, r'ActivityItem', 'atMs'),
          entityType: entityType,
          entityId: entityId,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'ActivityItem', 'title'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

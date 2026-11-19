// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimelineEvent extends TimelineEvent {
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
  @override
  final String description;

  factory _$TimelineEvent([void Function(TimelineEventBuilder)? updates]) =>
      (TimelineEventBuilder()..update(updates))._build();

  _$TimelineEvent._(
      {required this.kind,
      required this.atMs,
      this.entityType,
      this.entityId,
      required this.title,
      required this.description})
      : super._();
  @override
  TimelineEvent rebuild(void Function(TimelineEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimelineEventBuilder toBuilder() => TimelineEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimelineEvent &&
        kind == other.kind &&
        atMs == other.atMs &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        title == other.title &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, atMs.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimelineEvent')
          ..add('kind', kind)
          ..add('atMs', atMs)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('title', title)
          ..add('description', description))
        .toString();
  }
}

class TimelineEventBuilder
    implements Builder<TimelineEvent, TimelineEventBuilder> {
  _$TimelineEvent? _$v;

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

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  TimelineEventBuilder() {
    TimelineEvent._defaults(this);
  }

  TimelineEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _atMs = $v.atMs;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _title = $v.title;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimelineEvent other) {
    _$v = other as _$TimelineEvent;
  }

  @override
  void update(void Function(TimelineEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimelineEvent build() => _build();

  _$TimelineEvent _build() {
    final _$result = _$v ??
        _$TimelineEvent._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'TimelineEvent', 'kind'),
          atMs: BuiltValueNullFieldError.checkNotNull(
              atMs, r'TimelineEvent', 'atMs'),
          entityType: entityType,
          entityId: entityId,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'TimelineEvent', 'title'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'TimelineEvent', 'description'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RevisionEntityTypeEnum _$revisionEntityTypeEnum_decision =
    const RevisionEntityTypeEnum._('decision');
const RevisionEntityTypeEnum _$revisionEntityTypeEnum_note =
    const RevisionEntityTypeEnum._('note');

RevisionEntityTypeEnum _$revisionEntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'decision':
      return _$revisionEntityTypeEnum_decision;
    case 'note':
      return _$revisionEntityTypeEnum_note;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RevisionEntityTypeEnum> _$revisionEntityTypeEnumValues =
    BuiltSet<RevisionEntityTypeEnum>(const <RevisionEntityTypeEnum>[
  _$revisionEntityTypeEnum_decision,
  _$revisionEntityTypeEnum_note,
]);

Serializer<RevisionEntityTypeEnum> _$revisionEntityTypeEnumSerializer =
    _$RevisionEntityTypeEnumSerializer();

class _$RevisionEntityTypeEnumSerializer
    implements PrimitiveSerializer<RevisionEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'decision': 'decision',
    'note': 'note',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'decision': 'decision',
    'note': 'note',
  };

  @override
  final Iterable<Type> types = const <Type>[RevisionEntityTypeEnum];
  @override
  final String wireName = 'RevisionEntityTypeEnum';

  @override
  Object serialize(Serializers serializers, RevisionEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RevisionEntityTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RevisionEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Revision extends Revision {
  @override
  final String id;
  @override
  final RevisionEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String snapshot;
  @override
  final String? createdBy;
  @override
  final int createdAtMs;

  factory _$Revision([void Function(RevisionBuilder)? updates]) =>
      (RevisionBuilder()..update(updates))._build();

  _$Revision._(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.snapshot,
      this.createdBy,
      required this.createdAtMs})
      : super._();
  @override
  Revision rebuild(void Function(RevisionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RevisionBuilder toBuilder() => RevisionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Revision &&
        id == other.id &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        snapshot == other.snapshot &&
        createdBy == other.createdBy &&
        createdAtMs == other.createdAtMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, snapshot.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Revision')
          ..add('id', id)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('snapshot', snapshot)
          ..add('createdBy', createdBy)
          ..add('createdAtMs', createdAtMs))
        .toString();
  }
}

class RevisionBuilder implements Builder<Revision, RevisionBuilder> {
  _$Revision? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  RevisionEntityTypeEnum? _entityType;
  RevisionEntityTypeEnum? get entityType => _$this._entityType;
  set entityType(RevisionEntityTypeEnum? entityType) =>
      _$this._entityType = entityType;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  String? _snapshot;
  String? get snapshot => _$this._snapshot;
  set snapshot(String? snapshot) => _$this._snapshot = snapshot;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(int? createdAtMs) => _$this._createdAtMs = createdAtMs;

  RevisionBuilder() {
    Revision._defaults(this);
  }

  RevisionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _snapshot = $v.snapshot;
      _createdBy = $v.createdBy;
      _createdAtMs = $v.createdAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Revision other) {
    _$v = other as _$Revision;
  }

  @override
  void update(void Function(RevisionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Revision build() => _build();

  _$Revision _build() {
    final _$result = _$v ??
        _$Revision._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Revision', 'id'),
          entityType: BuiltValueNullFieldError.checkNotNull(
              entityType, r'Revision', 'entityType'),
          entityId: BuiltValueNullFieldError.checkNotNull(
              entityId, r'Revision', 'entityId'),
          snapshot: BuiltValueNullFieldError.checkNotNull(
              snapshot, r'Revision', 'snapshot'),
          createdBy: createdBy,
          createdAtMs: BuiltValueNullFieldError.checkNotNull(
              createdAtMs, r'Revision', 'createdAtMs'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

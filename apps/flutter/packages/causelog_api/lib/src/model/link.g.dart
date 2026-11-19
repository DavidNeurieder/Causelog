// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LinkFromTypeEnum _$linkFromTypeEnum_note =
    const LinkFromTypeEnum._('note');
const LinkFromTypeEnum _$linkFromTypeEnum_decision =
    const LinkFromTypeEnum._('decision');
const LinkFromTypeEnum _$linkFromTypeEnum_experiment =
    const LinkFromTypeEnum._('experiment');

LinkFromTypeEnum _$linkFromTypeEnumValueOf(String name) {
  switch (name) {
    case 'note':
      return _$linkFromTypeEnum_note;
    case 'decision':
      return _$linkFromTypeEnum_decision;
    case 'experiment':
      return _$linkFromTypeEnum_experiment;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LinkFromTypeEnum> _$linkFromTypeEnumValues =
    BuiltSet<LinkFromTypeEnum>(const <LinkFromTypeEnum>[
  _$linkFromTypeEnum_note,
  _$linkFromTypeEnum_decision,
  _$linkFromTypeEnum_experiment,
]);

const LinkToTypeEnum _$linkToTypeEnum_note = const LinkToTypeEnum._('note');
const LinkToTypeEnum _$linkToTypeEnum_decision =
    const LinkToTypeEnum._('decision');
const LinkToTypeEnum _$linkToTypeEnum_experiment =
    const LinkToTypeEnum._('experiment');

LinkToTypeEnum _$linkToTypeEnumValueOf(String name) {
  switch (name) {
    case 'note':
      return _$linkToTypeEnum_note;
    case 'decision':
      return _$linkToTypeEnum_decision;
    case 'experiment':
      return _$linkToTypeEnum_experiment;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LinkToTypeEnum> _$linkToTypeEnumValues =
    BuiltSet<LinkToTypeEnum>(const <LinkToTypeEnum>[
  _$linkToTypeEnum_note,
  _$linkToTypeEnum_decision,
  _$linkToTypeEnum_experiment,
]);

const LinkKindEnum _$linkKindEnum_related = const LinkKindEnum._('related');
const LinkKindEnum _$linkKindEnum_supports = const LinkKindEnum._('supports');
const LinkKindEnum _$linkKindEnum_rejects = const LinkKindEnum._('rejects');
const LinkKindEnum _$linkKindEnum_follows = const LinkKindEnum._('follows');

LinkKindEnum _$linkKindEnumValueOf(String name) {
  switch (name) {
    case 'related':
      return _$linkKindEnum_related;
    case 'supports':
      return _$linkKindEnum_supports;
    case 'rejects':
      return _$linkKindEnum_rejects;
    case 'follows':
      return _$linkKindEnum_follows;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LinkKindEnum> _$linkKindEnumValues =
    BuiltSet<LinkKindEnum>(const <LinkKindEnum>[
  _$linkKindEnum_related,
  _$linkKindEnum_supports,
  _$linkKindEnum_rejects,
  _$linkKindEnum_follows,
]);

Serializer<LinkFromTypeEnum> _$linkFromTypeEnumSerializer =
    _$LinkFromTypeEnumSerializer();
Serializer<LinkToTypeEnum> _$linkToTypeEnumSerializer =
    _$LinkToTypeEnumSerializer();
Serializer<LinkKindEnum> _$linkKindEnumSerializer = _$LinkKindEnumSerializer();

class _$LinkFromTypeEnumSerializer
    implements PrimitiveSerializer<LinkFromTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'note': 'note',
    'decision': 'decision',
    'experiment': 'experiment',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'note': 'note',
    'decision': 'decision',
    'experiment': 'experiment',
  };

  @override
  final Iterable<Type> types = const <Type>[LinkFromTypeEnum];
  @override
  final String wireName = 'LinkFromTypeEnum';

  @override
  Object serialize(Serializers serializers, LinkFromTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LinkFromTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LinkFromTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LinkToTypeEnumSerializer
    implements PrimitiveSerializer<LinkToTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'note': 'note',
    'decision': 'decision',
    'experiment': 'experiment',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'note': 'note',
    'decision': 'decision',
    'experiment': 'experiment',
  };

  @override
  final Iterable<Type> types = const <Type>[LinkToTypeEnum];
  @override
  final String wireName = 'LinkToTypeEnum';

  @override
  Object serialize(Serializers serializers, LinkToTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LinkToTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LinkToTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LinkKindEnumSerializer implements PrimitiveSerializer<LinkKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'related': 'related',
    'supports': 'supports',
    'rejects': 'rejects',
    'follows': 'follows',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'related': 'related',
    'supports': 'supports',
    'rejects': 'rejects',
    'follows': 'follows',
  };

  @override
  final Iterable<Type> types = const <Type>[LinkKindEnum];
  @override
  final String wireName = 'LinkKindEnum';

  @override
  Object serialize(Serializers serializers, LinkKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LinkKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LinkKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Link extends Link {
  @override
  final String id;
  @override
  final String projectId;
  @override
  final LinkFromTypeEnum fromType;
  @override
  final String fromId;
  @override
  final LinkToTypeEnum toType;
  @override
  final String toId;
  @override
  final LinkKindEnum kind;
  @override
  final int createdAtMs;

  factory _$Link([void Function(LinkBuilder)? updates]) =>
      (LinkBuilder()..update(updates))._build();

  _$Link._(
      {required this.id,
      required this.projectId,
      required this.fromType,
      required this.fromId,
      required this.toType,
      required this.toId,
      required this.kind,
      required this.createdAtMs})
      : super._();
  @override
  Link rebuild(void Function(LinkBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LinkBuilder toBuilder() => LinkBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Link &&
        id == other.id &&
        projectId == other.projectId &&
        fromType == other.fromType &&
        fromId == other.fromId &&
        toType == other.toType &&
        toId == other.toId &&
        kind == other.kind &&
        createdAtMs == other.createdAtMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, fromType.hashCode);
    _$hash = $jc(_$hash, fromId.hashCode);
    _$hash = $jc(_$hash, toType.hashCode);
    _$hash = $jc(_$hash, toId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Link')
          ..add('id', id)
          ..add('projectId', projectId)
          ..add('fromType', fromType)
          ..add('fromId', fromId)
          ..add('toType', toType)
          ..add('toId', toId)
          ..add('kind', kind)
          ..add('createdAtMs', createdAtMs))
        .toString();
  }
}

class LinkBuilder implements Builder<Link, LinkBuilder> {
  _$Link? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  LinkFromTypeEnum? _fromType;
  LinkFromTypeEnum? get fromType => _$this._fromType;
  set fromType(LinkFromTypeEnum? fromType) => _$this._fromType = fromType;

  String? _fromId;
  String? get fromId => _$this._fromId;
  set fromId(String? fromId) => _$this._fromId = fromId;

  LinkToTypeEnum? _toType;
  LinkToTypeEnum? get toType => _$this._toType;
  set toType(LinkToTypeEnum? toType) => _$this._toType = toType;

  String? _toId;
  String? get toId => _$this._toId;
  set toId(String? toId) => _$this._toId = toId;

  LinkKindEnum? _kind;
  LinkKindEnum? get kind => _$this._kind;
  set kind(LinkKindEnum? kind) => _$this._kind = kind;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(int? createdAtMs) => _$this._createdAtMs = createdAtMs;

  LinkBuilder() {
    Link._defaults(this);
  }

  LinkBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _projectId = $v.projectId;
      _fromType = $v.fromType;
      _fromId = $v.fromId;
      _toType = $v.toType;
      _toId = $v.toId;
      _kind = $v.kind;
      _createdAtMs = $v.createdAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Link other) {
    _$v = other as _$Link;
  }

  @override
  void update(void Function(LinkBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Link build() => _build();

  _$Link _build() {
    final _$result = _$v ??
        _$Link._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Link', 'id'),
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'Link', 'projectId'),
          fromType: BuiltValueNullFieldError.checkNotNull(
              fromType, r'Link', 'fromType'),
          fromId:
              BuiltValueNullFieldError.checkNotNull(fromId, r'Link', 'fromId'),
          toType:
              BuiltValueNullFieldError.checkNotNull(toType, r'Link', 'toType'),
          toId: BuiltValueNullFieldError.checkNotNull(toId, r'Link', 'toId'),
          kind: BuiltValueNullFieldError.checkNotNull(kind, r'Link', 'kind'),
          createdAtMs: BuiltValueNullFieldError.checkNotNull(
              createdAtMs, r'Link', 'createdAtMs'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

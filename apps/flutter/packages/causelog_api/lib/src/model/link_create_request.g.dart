// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LinkCreateRequestFromTypeEnum _$linkCreateRequestFromTypeEnum_note =
    const LinkCreateRequestFromTypeEnum._('note');
const LinkCreateRequestFromTypeEnum _$linkCreateRequestFromTypeEnum_decision =
    const LinkCreateRequestFromTypeEnum._('decision');
const LinkCreateRequestFromTypeEnum _$linkCreateRequestFromTypeEnum_experiment =
    const LinkCreateRequestFromTypeEnum._('experiment');

LinkCreateRequestFromTypeEnum _$linkCreateRequestFromTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'note':
      return _$linkCreateRequestFromTypeEnum_note;
    case 'decision':
      return _$linkCreateRequestFromTypeEnum_decision;
    case 'experiment':
      return _$linkCreateRequestFromTypeEnum_experiment;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LinkCreateRequestFromTypeEnum>
    _$linkCreateRequestFromTypeEnumValues = BuiltSet<
        LinkCreateRequestFromTypeEnum>(const <LinkCreateRequestFromTypeEnum>[
  _$linkCreateRequestFromTypeEnum_note,
  _$linkCreateRequestFromTypeEnum_decision,
  _$linkCreateRequestFromTypeEnum_experiment,
]);

const LinkCreateRequestToTypeEnum _$linkCreateRequestToTypeEnum_note =
    const LinkCreateRequestToTypeEnum._('note');
const LinkCreateRequestToTypeEnum _$linkCreateRequestToTypeEnum_decision =
    const LinkCreateRequestToTypeEnum._('decision');
const LinkCreateRequestToTypeEnum _$linkCreateRequestToTypeEnum_experiment =
    const LinkCreateRequestToTypeEnum._('experiment');

LinkCreateRequestToTypeEnum _$linkCreateRequestToTypeEnumValueOf(String name) {
  switch (name) {
    case 'note':
      return _$linkCreateRequestToTypeEnum_note;
    case 'decision':
      return _$linkCreateRequestToTypeEnum_decision;
    case 'experiment':
      return _$linkCreateRequestToTypeEnum_experiment;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LinkCreateRequestToTypeEnum>
    _$linkCreateRequestToTypeEnumValues =
    BuiltSet<LinkCreateRequestToTypeEnum>(const <LinkCreateRequestToTypeEnum>[
  _$linkCreateRequestToTypeEnum_note,
  _$linkCreateRequestToTypeEnum_decision,
  _$linkCreateRequestToTypeEnum_experiment,
]);

const LinkCreateRequestKindEnum _$linkCreateRequestKindEnum_related =
    const LinkCreateRequestKindEnum._('related');
const LinkCreateRequestKindEnum _$linkCreateRequestKindEnum_supports =
    const LinkCreateRequestKindEnum._('supports');
const LinkCreateRequestKindEnum _$linkCreateRequestKindEnum_rejects =
    const LinkCreateRequestKindEnum._('rejects');
const LinkCreateRequestKindEnum _$linkCreateRequestKindEnum_follows =
    const LinkCreateRequestKindEnum._('follows');

LinkCreateRequestKindEnum _$linkCreateRequestKindEnumValueOf(String name) {
  switch (name) {
    case 'related':
      return _$linkCreateRequestKindEnum_related;
    case 'supports':
      return _$linkCreateRequestKindEnum_supports;
    case 'rejects':
      return _$linkCreateRequestKindEnum_rejects;
    case 'follows':
      return _$linkCreateRequestKindEnum_follows;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LinkCreateRequestKindEnum> _$linkCreateRequestKindEnumValues =
    BuiltSet<LinkCreateRequestKindEnum>(const <LinkCreateRequestKindEnum>[
  _$linkCreateRequestKindEnum_related,
  _$linkCreateRequestKindEnum_supports,
  _$linkCreateRequestKindEnum_rejects,
  _$linkCreateRequestKindEnum_follows,
]);

Serializer<LinkCreateRequestFromTypeEnum>
    _$linkCreateRequestFromTypeEnumSerializer =
    _$LinkCreateRequestFromTypeEnumSerializer();
Serializer<LinkCreateRequestToTypeEnum>
    _$linkCreateRequestToTypeEnumSerializer =
    _$LinkCreateRequestToTypeEnumSerializer();
Serializer<LinkCreateRequestKindEnum> _$linkCreateRequestKindEnumSerializer =
    _$LinkCreateRequestKindEnumSerializer();

class _$LinkCreateRequestFromTypeEnumSerializer
    implements PrimitiveSerializer<LinkCreateRequestFromTypeEnum> {
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
  final Iterable<Type> types = const <Type>[LinkCreateRequestFromTypeEnum];
  @override
  final String wireName = 'LinkCreateRequestFromTypeEnum';

  @override
  Object serialize(
          Serializers serializers, LinkCreateRequestFromTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LinkCreateRequestFromTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LinkCreateRequestFromTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LinkCreateRequestToTypeEnumSerializer
    implements PrimitiveSerializer<LinkCreateRequestToTypeEnum> {
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
  final Iterable<Type> types = const <Type>[LinkCreateRequestToTypeEnum];
  @override
  final String wireName = 'LinkCreateRequestToTypeEnum';

  @override
  Object serialize(Serializers serializers, LinkCreateRequestToTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LinkCreateRequestToTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LinkCreateRequestToTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LinkCreateRequestKindEnumSerializer
    implements PrimitiveSerializer<LinkCreateRequestKindEnum> {
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
  final Iterable<Type> types = const <Type>[LinkCreateRequestKindEnum];
  @override
  final String wireName = 'LinkCreateRequestKindEnum';

  @override
  Object serialize(Serializers serializers, LinkCreateRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LinkCreateRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LinkCreateRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LinkCreateRequest extends LinkCreateRequest {
  @override
  final String toId;
  @override
  final LinkCreateRequestToTypeEnum toType;
  @override
  final LinkCreateRequestFromTypeEnum fromType;
  @override
  final LinkCreateRequestKindEnum kind;
  @override
  final String fromId;
  @override
  final String? csrfToken;

  factory _$LinkCreateRequest(
          [void Function(LinkCreateRequestBuilder)? updates]) =>
      (LinkCreateRequestBuilder()..update(updates))._build();

  _$LinkCreateRequest._(
      {required this.toId,
      required this.toType,
      required this.fromType,
      required this.kind,
      required this.fromId,
      this.csrfToken})
      : super._();
  @override
  LinkCreateRequest rebuild(void Function(LinkCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LinkCreateRequestBuilder toBuilder() =>
      LinkCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LinkCreateRequest &&
        toId == other.toId &&
        toType == other.toType &&
        fromType == other.fromType &&
        kind == other.kind &&
        fromId == other.fromId &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, toId.hashCode);
    _$hash = $jc(_$hash, toType.hashCode);
    _$hash = $jc(_$hash, fromType.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, fromId.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LinkCreateRequest')
          ..add('toId', toId)
          ..add('toType', toType)
          ..add('fromType', fromType)
          ..add('kind', kind)
          ..add('fromId', fromId)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class LinkCreateRequestBuilder
    implements
        Builder<LinkCreateRequest, LinkCreateRequestBuilder>,
        CsrfBodyBuilder {
  _$LinkCreateRequest? _$v;

  String? _toId;
  String? get toId => _$this._toId;
  set toId(covariant String? toId) => _$this._toId = toId;

  LinkCreateRequestToTypeEnum? _toType;
  LinkCreateRequestToTypeEnum? get toType => _$this._toType;
  set toType(covariant LinkCreateRequestToTypeEnum? toType) =>
      _$this._toType = toType;

  LinkCreateRequestFromTypeEnum? _fromType;
  LinkCreateRequestFromTypeEnum? get fromType => _$this._fromType;
  set fromType(covariant LinkCreateRequestFromTypeEnum? fromType) =>
      _$this._fromType = fromType;

  LinkCreateRequestKindEnum? _kind;
  LinkCreateRequestKindEnum? get kind => _$this._kind;
  set kind(covariant LinkCreateRequestKindEnum? kind) => _$this._kind = kind;

  String? _fromId;
  String? get fromId => _$this._fromId;
  set fromId(covariant String? fromId) => _$this._fromId = fromId;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  LinkCreateRequestBuilder() {
    LinkCreateRequest._defaults(this);
  }

  LinkCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _toId = $v.toId;
      _toType = $v.toType;
      _fromType = $v.fromType;
      _kind = $v.kind;
      _fromId = $v.fromId;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant LinkCreateRequest other) {
    _$v = other as _$LinkCreateRequest;
  }

  @override
  void update(void Function(LinkCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LinkCreateRequest build() => _build();

  _$LinkCreateRequest _build() {
    final _$result = _$v ??
        _$LinkCreateRequest._(
          toId: BuiltValueNullFieldError.checkNotNull(
              toId, r'LinkCreateRequest', 'toId'),
          toType: BuiltValueNullFieldError.checkNotNull(
              toType, r'LinkCreateRequest', 'toType'),
          fromType: BuiltValueNullFieldError.checkNotNull(
              fromType, r'LinkCreateRequest', 'fromType'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'LinkCreateRequest', 'kind'),
          fromId: BuiltValueNullFieldError.checkNotNull(
              fromId, r'LinkCreateRequest', 'fromId'),
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

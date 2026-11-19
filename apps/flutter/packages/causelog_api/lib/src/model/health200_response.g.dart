// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Health200ResponseStatusEnum _$health200ResponseStatusEnum_ok =
    const Health200ResponseStatusEnum._('ok');

Health200ResponseStatusEnum _$health200ResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$health200ResponseStatusEnum_ok;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<Health200ResponseStatusEnum>
    _$health200ResponseStatusEnumValues =
    BuiltSet<Health200ResponseStatusEnum>(const <Health200ResponseStatusEnum>[
  _$health200ResponseStatusEnum_ok,
]);

Serializer<Health200ResponseStatusEnum>
    _$health200ResponseStatusEnumSerializer =
    _$Health200ResponseStatusEnumSerializer();

class _$Health200ResponseStatusEnumSerializer
    implements PrimitiveSerializer<Health200ResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
  };

  @override
  final Iterable<Type> types = const <Type>[Health200ResponseStatusEnum];
  @override
  final String wireName = 'Health200ResponseStatusEnum';

  @override
  Object serialize(Serializers serializers, Health200ResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  Health200ResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Health200ResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Health200Response extends Health200Response {
  @override
  final Health200ResponseStatusEnum status;

  factory _$Health200Response(
          [void Function(Health200ResponseBuilder)? updates]) =>
      (Health200ResponseBuilder()..update(updates))._build();

  _$Health200Response._({required this.status}) : super._();
  @override
  Health200Response rebuild(void Function(Health200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Health200ResponseBuilder toBuilder() =>
      Health200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Health200Response && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Health200Response')
          ..add('status', status))
        .toString();
  }
}

class Health200ResponseBuilder
    implements Builder<Health200Response, Health200ResponseBuilder> {
  _$Health200Response? _$v;

  Health200ResponseStatusEnum? _status;
  Health200ResponseStatusEnum? get status => _$this._status;
  set status(Health200ResponseStatusEnum? status) => _$this._status = status;

  Health200ResponseBuilder() {
    Health200Response._defaults(this);
  }

  Health200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Health200Response other) {
    _$v = other as _$Health200Response;
  }

  @override
  void update(void Function(Health200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Health200Response build() => _build();

  _$Health200Response _build() {
    final _$result = _$v ??
        _$Health200Response._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Health200Response', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

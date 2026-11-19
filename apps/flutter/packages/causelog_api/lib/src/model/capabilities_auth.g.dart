// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capabilities_auth.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CapabilitiesAuthModeEnum _$capabilitiesAuthModeEnum_cookieCsrf =
    const CapabilitiesAuthModeEnum._('cookieCsrf');

CapabilitiesAuthModeEnum _$capabilitiesAuthModeEnumValueOf(String name) {
  switch (name) {
    case 'cookieCsrf':
      return _$capabilitiesAuthModeEnum_cookieCsrf;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CapabilitiesAuthModeEnum> _$capabilitiesAuthModeEnumValues =
    BuiltSet<CapabilitiesAuthModeEnum>(const <CapabilitiesAuthModeEnum>[
  _$capabilitiesAuthModeEnum_cookieCsrf,
]);

Serializer<CapabilitiesAuthModeEnum> _$capabilitiesAuthModeEnumSerializer =
    _$CapabilitiesAuthModeEnumSerializer();

class _$CapabilitiesAuthModeEnumSerializer
    implements PrimitiveSerializer<CapabilitiesAuthModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cookieCsrf': 'cookie_csrf',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cookie_csrf': 'cookieCsrf',
  };

  @override
  final Iterable<Type> types = const <Type>[CapabilitiesAuthModeEnum];
  @override
  final String wireName = 'CapabilitiesAuthModeEnum';

  @override
  Object serialize(Serializers serializers, CapabilitiesAuthModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CapabilitiesAuthModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CapabilitiesAuthModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CapabilitiesAuth extends CapabilitiesAuth {
  @override
  final CapabilitiesAuthModeEnum mode;
  @override
  final String csrfHeader;
  @override
  final String sessionCookie;

  factory _$CapabilitiesAuth(
          [void Function(CapabilitiesAuthBuilder)? updates]) =>
      (CapabilitiesAuthBuilder()..update(updates))._build();

  _$CapabilitiesAuth._(
      {required this.mode,
      required this.csrfHeader,
      required this.sessionCookie})
      : super._();
  @override
  CapabilitiesAuth rebuild(void Function(CapabilitiesAuthBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CapabilitiesAuthBuilder toBuilder() =>
      CapabilitiesAuthBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CapabilitiesAuth &&
        mode == other.mode &&
        csrfHeader == other.csrfHeader &&
        sessionCookie == other.sessionCookie;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, csrfHeader.hashCode);
    _$hash = $jc(_$hash, sessionCookie.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CapabilitiesAuth')
          ..add('mode', mode)
          ..add('csrfHeader', csrfHeader)
          ..add('sessionCookie', sessionCookie))
        .toString();
  }
}

class CapabilitiesAuthBuilder
    implements Builder<CapabilitiesAuth, CapabilitiesAuthBuilder> {
  _$CapabilitiesAuth? _$v;

  CapabilitiesAuthModeEnum? _mode;
  CapabilitiesAuthModeEnum? get mode => _$this._mode;
  set mode(CapabilitiesAuthModeEnum? mode) => _$this._mode = mode;

  String? _csrfHeader;
  String? get csrfHeader => _$this._csrfHeader;
  set csrfHeader(String? csrfHeader) => _$this._csrfHeader = csrfHeader;

  String? _sessionCookie;
  String? get sessionCookie => _$this._sessionCookie;
  set sessionCookie(String? sessionCookie) =>
      _$this._sessionCookie = sessionCookie;

  CapabilitiesAuthBuilder() {
    CapabilitiesAuth._defaults(this);
  }

  CapabilitiesAuthBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mode = $v.mode;
      _csrfHeader = $v.csrfHeader;
      _sessionCookie = $v.sessionCookie;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CapabilitiesAuth other) {
    _$v = other as _$CapabilitiesAuth;
  }

  @override
  void update(void Function(CapabilitiesAuthBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CapabilitiesAuth build() => _build();

  _$CapabilitiesAuth _build() {
    final _$result = _$v ??
        _$CapabilitiesAuth._(
          mode: BuiltValueNullFieldError.checkNotNull(
              mode, r'CapabilitiesAuth', 'mode'),
          csrfHeader: BuiltValueNullFieldError.checkNotNull(
              csrfHeader, r'CapabilitiesAuth', 'csrfHeader'),
          sessionCookie: BuiltValueNullFieldError.checkNotNull(
              sessionCookie, r'CapabilitiesAuth', 'sessionCookie'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

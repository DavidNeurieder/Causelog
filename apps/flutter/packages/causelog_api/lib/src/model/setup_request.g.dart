// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetupRequest extends SetupRequest {
  @override
  final String username;
  @override
  final String? displayName;
  @override
  final String password;

  factory _$SetupRequest([void Function(SetupRequestBuilder)? updates]) =>
      (SetupRequestBuilder()..update(updates))._build();

  _$SetupRequest._(
      {required this.username, this.displayName, required this.password})
      : super._();
  @override
  SetupRequest rebuild(void Function(SetupRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SetupRequestBuilder toBuilder() => SetupRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetupRequest &&
        username == other.username &&
        displayName == other.displayName &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SetupRequest')
          ..add('username', username)
          ..add('displayName', displayName)
          ..add('password', password))
        .toString();
  }
}

class SetupRequestBuilder
    implements Builder<SetupRequest, SetupRequestBuilder> {
  _$SetupRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  SetupRequestBuilder() {
    SetupRequest._defaults(this);
  }

  SetupRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _displayName = $v.displayName;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetupRequest other) {
    _$v = other as _$SetupRequest;
  }

  @override
  void update(void Function(SetupRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetupRequest build() => _build();

  _$SetupRequest _build() {
    final _$result = _$v ??
        _$SetupRequest._(
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'SetupRequest', 'username'),
          displayName: displayName,
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'SetupRequest', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

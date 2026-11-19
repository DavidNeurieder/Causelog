// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SessionResponse extends SessionResponse {
  @override
  final User user;
  @override
  final String csrfToken;

  factory _$SessionResponse([void Function(SessionResponseBuilder)? updates]) =>
      (SessionResponseBuilder()..update(updates))._build();

  _$SessionResponse._({required this.user, required this.csrfToken})
      : super._();
  @override
  SessionResponse rebuild(void Function(SessionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SessionResponseBuilder toBuilder() => SessionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SessionResponse &&
        user == other.user &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SessionResponse')
          ..add('user', user)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class SessionResponseBuilder
    implements Builder<SessionResponse, SessionResponseBuilder> {
  _$SessionResponse? _$v;

  UserBuilder? _user;
  UserBuilder get user => _$this._user ??= UserBuilder();
  set user(UserBuilder? user) => _$this._user = user;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(String? csrfToken) => _$this._csrfToken = csrfToken;

  SessionResponseBuilder() {
    SessionResponse._defaults(this);
  }

  SessionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SessionResponse other) {
    _$v = other as _$SessionResponse;
  }

  @override
  void update(void Function(SessionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SessionResponse build() => _build();

  _$SessionResponse _build() {
    _$SessionResponse _$result;
    try {
      _$result = _$v ??
          _$SessionResponse._(
            user: user.build(),
            csrfToken: BuiltValueNullFieldError.checkNotNull(
                csrfToken, r'SessionResponse', 'csrfToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SessionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csrf_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class CsrfBodyBuilder {
  void replace(CsrfBody other);
  void update(void Function(CsrfBodyBuilder) updates);
  String? get csrfToken;
  set csrfToken(String? csrfToken);
}

class _$$CsrfBody extends $CsrfBody {
  @override
  final String? csrfToken;

  factory _$$CsrfBody([void Function($CsrfBodyBuilder)? updates]) =>
      ($CsrfBodyBuilder()..update(updates))._build();

  _$$CsrfBody._({this.csrfToken}) : super._();
  @override
  $CsrfBody rebuild(void Function($CsrfBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $CsrfBodyBuilder toBuilder() => $CsrfBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $CsrfBody && csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$CsrfBody')
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class $CsrfBodyBuilder
    implements Builder<$CsrfBody, $CsrfBodyBuilder>, CsrfBodyBuilder {
  _$$CsrfBody? _$v;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  $CsrfBodyBuilder() {
    $CsrfBody._defaults(this);
  }

  $CsrfBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $CsrfBody other) {
    _$v = other as _$$CsrfBody;
  }

  @override
  void update(void Function($CsrfBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $CsrfBody build() => _build();

  _$$CsrfBody _build() {
    final _$result = _$v ??
        _$$CsrfBody._(
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

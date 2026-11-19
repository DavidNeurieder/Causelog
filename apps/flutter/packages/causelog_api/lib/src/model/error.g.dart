// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Error extends Error {
  @override
  final String error;
  @override
  final String? code;

  factory _$Error([void Function(ErrorBuilder)? updates]) =>
      (ErrorBuilder()..update(updates))._build();

  _$Error._({required this.error, this.code}) : super._();
  @override
  Error rebuild(void Function(ErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorBuilder toBuilder() => ErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Error && error == other.error && code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Error')
          ..add('error', error)
          ..add('code', code))
        .toString();
  }
}

class ErrorBuilder implements Builder<Error, ErrorBuilder> {
  _$Error? _$v;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  ErrorBuilder() {
    Error._defaults(this);
  }

  ErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Error other) {
    _$v = other as _$Error;
  }

  @override
  void update(void Function(ErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Error build() => _build();

  _$Error _build() {
    final _$result = _$v ??
        _$Error._(
          error:
              BuiltValueNullFieldError.checkNotNull(error, r'Error', 'error'),
          code: code,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

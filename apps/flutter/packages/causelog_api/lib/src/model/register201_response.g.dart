// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Register201Response extends Register201Response {
  @override
  final bool pendingApproval;

  factory _$Register201Response(
          [void Function(Register201ResponseBuilder)? updates]) =>
      (Register201ResponseBuilder()..update(updates))._build();

  _$Register201Response._({required this.pendingApproval}) : super._();
  @override
  Register201Response rebuild(
          void Function(Register201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Register201ResponseBuilder toBuilder() =>
      Register201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Register201Response &&
        pendingApproval == other.pendingApproval;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pendingApproval.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Register201Response')
          ..add('pendingApproval', pendingApproval))
        .toString();
  }
}

class Register201ResponseBuilder
    implements Builder<Register201Response, Register201ResponseBuilder> {
  _$Register201Response? _$v;

  bool? _pendingApproval;
  bool? get pendingApproval => _$this._pendingApproval;
  set pendingApproval(bool? pendingApproval) =>
      _$this._pendingApproval = pendingApproval;

  Register201ResponseBuilder() {
    Register201Response._defaults(this);
  }

  Register201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pendingApproval = $v.pendingApproval;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Register201Response other) {
    _$v = other as _$Register201Response;
  }

  @override
  void update(void Function(Register201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Register201Response build() => _build();

  _$Register201Response _build() {
    final _$result = _$v ??
        _$Register201Response._(
          pendingApproval: BuiltValueNullFieldError.checkNotNull(
              pendingApproval, r'Register201Response', 'pendingApproval'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

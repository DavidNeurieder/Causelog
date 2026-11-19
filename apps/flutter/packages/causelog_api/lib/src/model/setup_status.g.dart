// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetupStatus extends SetupStatus {
  @override
  final bool setupRequired;

  factory _$SetupStatus([void Function(SetupStatusBuilder)? updates]) =>
      (SetupStatusBuilder()..update(updates))._build();

  _$SetupStatus._({required this.setupRequired}) : super._();
  @override
  SetupStatus rebuild(void Function(SetupStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SetupStatusBuilder toBuilder() => SetupStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetupStatus && setupRequired == other.setupRequired;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, setupRequired.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SetupStatus')
          ..add('setupRequired', setupRequired))
        .toString();
  }
}

class SetupStatusBuilder implements Builder<SetupStatus, SetupStatusBuilder> {
  _$SetupStatus? _$v;

  bool? _setupRequired;
  bool? get setupRequired => _$this._setupRequired;
  set setupRequired(bool? setupRequired) =>
      _$this._setupRequired = setupRequired;

  SetupStatusBuilder() {
    SetupStatus._defaults(this);
  }

  SetupStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _setupRequired = $v.setupRequired;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetupStatus other) {
    _$v = other as _$SetupStatus;
  }

  @override
  void update(void Function(SetupStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetupStatus build() => _build();

  _$SetupStatus _build() {
    final _$result = _$v ??
        _$SetupStatus._(
          setupRequired: BuiltValueNullFieldError.checkNotNull(
              setupRequired, r'SetupStatus', 'setupRequired'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

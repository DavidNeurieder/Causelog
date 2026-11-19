// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_option.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DecisionOption extends DecisionOption {
  @override
  final String id;
  @override
  final String label;
  @override
  final String pros;
  @override
  final String cons;

  factory _$DecisionOption([void Function(DecisionOptionBuilder)? updates]) =>
      (DecisionOptionBuilder()..update(updates))._build();

  _$DecisionOption._(
      {required this.id,
      required this.label,
      required this.pros,
      required this.cons})
      : super._();
  @override
  DecisionOption rebuild(void Function(DecisionOptionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DecisionOptionBuilder toBuilder() => DecisionOptionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DecisionOption &&
        id == other.id &&
        label == other.label &&
        pros == other.pros &&
        cons == other.cons;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, pros.hashCode);
    _$hash = $jc(_$hash, cons.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DecisionOption')
          ..add('id', id)
          ..add('label', label)
          ..add('pros', pros)
          ..add('cons', cons))
        .toString();
  }
}

class DecisionOptionBuilder
    implements Builder<DecisionOption, DecisionOptionBuilder> {
  _$DecisionOption? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _pros;
  String? get pros => _$this._pros;
  set pros(String? pros) => _$this._pros = pros;

  String? _cons;
  String? get cons => _$this._cons;
  set cons(String? cons) => _$this._cons = cons;

  DecisionOptionBuilder() {
    DecisionOption._defaults(this);
  }

  DecisionOptionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _label = $v.label;
      _pros = $v.pros;
      _cons = $v.cons;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DecisionOption other) {
    _$v = other as _$DecisionOption;
  }

  @override
  void update(void Function(DecisionOptionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DecisionOption build() => _build();

  _$DecisionOption _build() {
    final _$result = _$v ??
        _$DecisionOption._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'DecisionOption', 'id'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'DecisionOption', 'label'),
          pros: BuiltValueNullFieldError.checkNotNull(
              pros, r'DecisionOption', 'pros'),
          cons: BuiltValueNullFieldError.checkNotNull(
              cons, r'DecisionOption', 'cons'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision_comparison.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RevisionComparison extends RevisionComparison {
  @override
  final Revision from;
  @override
  final Revision to;
  @override
  final String? unifiedDiff;

  factory _$RevisionComparison(
          [void Function(RevisionComparisonBuilder)? updates]) =>
      (RevisionComparisonBuilder()..update(updates))._build();

  _$RevisionComparison._(
      {required this.from, required this.to, this.unifiedDiff})
      : super._();
  @override
  RevisionComparison rebuild(
          void Function(RevisionComparisonBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RevisionComparisonBuilder toBuilder() =>
      RevisionComparisonBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RevisionComparison &&
        from == other.from &&
        to == other.to &&
        unifiedDiff == other.unifiedDiff;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jc(_$hash, unifiedDiff.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RevisionComparison')
          ..add('from', from)
          ..add('to', to)
          ..add('unifiedDiff', unifiedDiff))
        .toString();
  }
}

class RevisionComparisonBuilder
    implements Builder<RevisionComparison, RevisionComparisonBuilder> {
  _$RevisionComparison? _$v;

  RevisionBuilder? _from;
  RevisionBuilder get from => _$this._from ??= RevisionBuilder();
  set from(RevisionBuilder? from) => _$this._from = from;

  RevisionBuilder? _to;
  RevisionBuilder get to => _$this._to ??= RevisionBuilder();
  set to(RevisionBuilder? to) => _$this._to = to;

  String? _unifiedDiff;
  String? get unifiedDiff => _$this._unifiedDiff;
  set unifiedDiff(String? unifiedDiff) => _$this._unifiedDiff = unifiedDiff;

  RevisionComparisonBuilder() {
    RevisionComparison._defaults(this);
  }

  RevisionComparisonBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _from = $v.from.toBuilder();
      _to = $v.to.toBuilder();
      _unifiedDiff = $v.unifiedDiff;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RevisionComparison other) {
    _$v = other as _$RevisionComparison;
  }

  @override
  void update(void Function(RevisionComparisonBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RevisionComparison build() => _build();

  _$RevisionComparison _build() {
    _$RevisionComparison _$result;
    try {
      _$result = _$v ??
          _$RevisionComparison._(
            from: from.build(),
            to: to.build(),
            unifiedDiff: unifiedDiff,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'from';
        from.build();
        _$failedField = 'to';
        to.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RevisionComparison', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

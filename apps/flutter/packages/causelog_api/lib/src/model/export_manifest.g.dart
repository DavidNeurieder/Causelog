// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_manifest.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportManifest extends ExportManifest {
  @override
  final BuiltList<ExportItem> items;

  factory _$ExportManifest([void Function(ExportManifestBuilder)? updates]) =>
      (ExportManifestBuilder()..update(updates))._build();

  _$ExportManifest._({required this.items}) : super._();
  @override
  ExportManifest rebuild(void Function(ExportManifestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportManifestBuilder toBuilder() => ExportManifestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportManifest && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportManifest')..add('items', items))
        .toString();
  }
}

class ExportManifestBuilder
    implements Builder<ExportManifest, ExportManifestBuilder> {
  _$ExportManifest? _$v;

  ListBuilder<ExportItem>? _items;
  ListBuilder<ExportItem> get items =>
      _$this._items ??= ListBuilder<ExportItem>();
  set items(ListBuilder<ExportItem>? items) => _$this._items = items;

  ExportManifestBuilder() {
    ExportManifest._defaults(this);
  }

  ExportManifestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportManifest other) {
    _$v = other as _$ExportManifest;
  }

  @override
  void update(void Function(ExportManifestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportManifest build() => _build();

  _$ExportManifest _build() {
    _$ExportManifest _$result;
    try {
      _$result = _$v ??
          _$ExportManifest._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ExportManifest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

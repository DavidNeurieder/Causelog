// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RevisionPage extends RevisionPage {
  @override
  final BuiltList<Revision> items;

  factory _$RevisionPage([void Function(RevisionPageBuilder)? updates]) =>
      (RevisionPageBuilder()..update(updates))._build();

  _$RevisionPage._({required this.items}) : super._();
  @override
  RevisionPage rebuild(void Function(RevisionPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RevisionPageBuilder toBuilder() => RevisionPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RevisionPage && items == other.items;
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
    return (newBuiltValueToStringHelper(r'RevisionPage')..add('items', items))
        .toString();
  }
}

class RevisionPageBuilder
    implements Builder<RevisionPage, RevisionPageBuilder> {
  _$RevisionPage? _$v;

  ListBuilder<Revision>? _items;
  ListBuilder<Revision> get items => _$this._items ??= ListBuilder<Revision>();
  set items(ListBuilder<Revision>? items) => _$this._items = items;

  RevisionPageBuilder() {
    RevisionPage._defaults(this);
  }

  RevisionPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RevisionPage other) {
    _$v = other as _$RevisionPage;
  }

  @override
  void update(void Function(RevisionPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RevisionPage build() => _build();

  _$RevisionPage _build() {
    _$RevisionPage _$result;
    try {
      _$result = _$v ??
          _$RevisionPage._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RevisionPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

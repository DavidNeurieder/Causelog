// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotePage extends NotePage {
  @override
  final BuiltList<Note> items;
  @override
  final PageInfo page;

  factory _$NotePage([void Function(NotePageBuilder)? updates]) =>
      (NotePageBuilder()..update(updates))._build();

  _$NotePage._({required this.items, required this.page}) : super._();
  @override
  NotePage rebuild(void Function(NotePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotePageBuilder toBuilder() => NotePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotePage && items == other.items && page == other.page;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotePage')
          ..add('items', items)
          ..add('page', page))
        .toString();
  }
}

class NotePageBuilder implements Builder<NotePage, NotePageBuilder> {
  _$NotePage? _$v;

  ListBuilder<Note>? _items;
  ListBuilder<Note> get items => _$this._items ??= ListBuilder<Note>();
  set items(ListBuilder<Note>? items) => _$this._items = items;

  PageInfoBuilder? _page;
  PageInfoBuilder get page => _$this._page ??= PageInfoBuilder();
  set page(PageInfoBuilder? page) => _$this._page = page;

  NotePageBuilder() {
    NotePage._defaults(this);
  }

  NotePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotePage other) {
    _$v = other as _$NotePage;
  }

  @override
  void update(void Function(NotePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotePage build() => _build();

  _$NotePage _build() {
    _$NotePage _$result;
    try {
      _$result = _$v ??
          _$NotePage._(
            items: items.build(),
            page: page.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
        _$failedField = 'page';
        page.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

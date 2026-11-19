// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchPage extends SearchPage {
  @override
  final BuiltList<SearchResult> items;
  @override
  final PageInfo page;

  factory _$SearchPage([void Function(SearchPageBuilder)? updates]) =>
      (SearchPageBuilder()..update(updates))._build();

  _$SearchPage._({required this.items, required this.page}) : super._();
  @override
  SearchPage rebuild(void Function(SearchPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SearchPageBuilder toBuilder() => SearchPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchPage && items == other.items && page == other.page;
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
    return (newBuiltValueToStringHelper(r'SearchPage')
          ..add('items', items)
          ..add('page', page))
        .toString();
  }
}

class SearchPageBuilder implements Builder<SearchPage, SearchPageBuilder> {
  _$SearchPage? _$v;

  ListBuilder<SearchResult>? _items;
  ListBuilder<SearchResult> get items =>
      _$this._items ??= ListBuilder<SearchResult>();
  set items(ListBuilder<SearchResult>? items) => _$this._items = items;

  PageInfoBuilder? _page;
  PageInfoBuilder get page => _$this._page ??= PageInfoBuilder();
  set page(PageInfoBuilder? page) => _$this._page = page;

  SearchPageBuilder() {
    SearchPage._defaults(this);
  }

  SearchPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchPage other) {
    _$v = other as _$SearchPage;
  }

  @override
  void update(void Function(SearchPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchPage build() => _build();

  _$SearchPage _build() {
    _$SearchPage _$result;
    try {
      _$result = _$v ??
          _$SearchPage._(
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
            r'SearchPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

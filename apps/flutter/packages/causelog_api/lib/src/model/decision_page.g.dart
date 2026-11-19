// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DecisionPage extends DecisionPage {
  @override
  final BuiltList<Decision> items;
  @override
  final PageInfo page;

  factory _$DecisionPage([void Function(DecisionPageBuilder)? updates]) =>
      (DecisionPageBuilder()..update(updates))._build();

  _$DecisionPage._({required this.items, required this.page}) : super._();
  @override
  DecisionPage rebuild(void Function(DecisionPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DecisionPageBuilder toBuilder() => DecisionPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DecisionPage && items == other.items && page == other.page;
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
    return (newBuiltValueToStringHelper(r'DecisionPage')
          ..add('items', items)
          ..add('page', page))
        .toString();
  }
}

class DecisionPageBuilder
    implements Builder<DecisionPage, DecisionPageBuilder> {
  _$DecisionPage? _$v;

  ListBuilder<Decision>? _items;
  ListBuilder<Decision> get items => _$this._items ??= ListBuilder<Decision>();
  set items(ListBuilder<Decision>? items) => _$this._items = items;

  PageInfoBuilder? _page;
  PageInfoBuilder get page => _$this._page ??= PageInfoBuilder();
  set page(PageInfoBuilder? page) => _$this._page = page;

  DecisionPageBuilder() {
    DecisionPage._defaults(this);
  }

  DecisionPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DecisionPage other) {
    _$v = other as _$DecisionPage;
  }

  @override
  void update(void Function(DecisionPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DecisionPage build() => _build();

  _$DecisionPage _build() {
    _$DecisionPage _$result;
    try {
      _$result = _$v ??
          _$DecisionPage._(
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
            r'DecisionPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

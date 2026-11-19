// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GoalPage extends GoalPage {
  @override
  final BuiltList<Goal> items;
  @override
  final PageInfo page;

  factory _$GoalPage([void Function(GoalPageBuilder)? updates]) =>
      (GoalPageBuilder()..update(updates))._build();

  _$GoalPage._({required this.items, required this.page}) : super._();
  @override
  GoalPage rebuild(void Function(GoalPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GoalPageBuilder toBuilder() => GoalPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GoalPage && items == other.items && page == other.page;
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
    return (newBuiltValueToStringHelper(r'GoalPage')
          ..add('items', items)
          ..add('page', page))
        .toString();
  }
}

class GoalPageBuilder implements Builder<GoalPage, GoalPageBuilder> {
  _$GoalPage? _$v;

  ListBuilder<Goal>? _items;
  ListBuilder<Goal> get items => _$this._items ??= ListBuilder<Goal>();
  set items(ListBuilder<Goal>? items) => _$this._items = items;

  PageInfoBuilder? _page;
  PageInfoBuilder get page => _$this._page ??= PageInfoBuilder();
  set page(PageInfoBuilder? page) => _$this._page = page;

  GoalPageBuilder() {
    GoalPage._defaults(this);
  }

  GoalPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GoalPage other) {
    _$v = other as _$GoalPage;
  }

  @override
  void update(void Function(GoalPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GoalPage build() => _build();

  _$GoalPage _build() {
    _$GoalPage _$result;
    try {
      _$result = _$v ??
          _$GoalPage._(
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
            r'GoalPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

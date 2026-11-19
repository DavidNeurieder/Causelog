// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExperimentPage extends ExperimentPage {
  @override
  final BuiltList<Experiment> items;
  @override
  final PageInfo page;

  factory _$ExperimentPage([void Function(ExperimentPageBuilder)? updates]) =>
      (ExperimentPageBuilder()..update(updates))._build();

  _$ExperimentPage._({required this.items, required this.page}) : super._();
  @override
  ExperimentPage rebuild(void Function(ExperimentPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExperimentPageBuilder toBuilder() => ExperimentPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExperimentPage &&
        items == other.items &&
        page == other.page;
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
    return (newBuiltValueToStringHelper(r'ExperimentPage')
          ..add('items', items)
          ..add('page', page))
        .toString();
  }
}

class ExperimentPageBuilder
    implements Builder<ExperimentPage, ExperimentPageBuilder> {
  _$ExperimentPage? _$v;

  ListBuilder<Experiment>? _items;
  ListBuilder<Experiment> get items =>
      _$this._items ??= ListBuilder<Experiment>();
  set items(ListBuilder<Experiment>? items) => _$this._items = items;

  PageInfoBuilder? _page;
  PageInfoBuilder get page => _$this._page ??= PageInfoBuilder();
  set page(PageInfoBuilder? page) => _$this._page = page;

  ExperimentPageBuilder() {
    ExperimentPage._defaults(this);
  }

  ExperimentPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExperimentPage other) {
    _$v = other as _$ExperimentPage;
  }

  @override
  void update(void Function(ExperimentPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExperimentPage build() => _build();

  _$ExperimentPage _build() {
    _$ExperimentPage _$result;
    try {
      _$result = _$v ??
          _$ExperimentPage._(
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
            r'ExperimentPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_info.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageInfo extends PageInfo {
  @override
  final int page;
  @override
  final int perPage;
  @override
  final int total;
  @override
  final int totalPages;

  factory _$PageInfo([void Function(PageInfoBuilder)? updates]) =>
      (PageInfoBuilder()..update(updates))._build();

  _$PageInfo._(
      {required this.page,
      required this.perPage,
      required this.total,
      required this.totalPages})
      : super._();
  @override
  PageInfo rebuild(void Function(PageInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageInfoBuilder toBuilder() => PageInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageInfo &&
        page == other.page &&
        perPage == other.perPage &&
        total == other.total &&
        totalPages == other.totalPages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, perPage.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, totalPages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PageInfo')
          ..add('page', page)
          ..add('perPage', perPage)
          ..add('total', total)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class PageInfoBuilder implements Builder<PageInfo, PageInfoBuilder> {
  _$PageInfo? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _perPage;
  int? get perPage => _$this._perPage;
  set perPage(int? perPage) => _$this._perPage = perPage;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _totalPages;
  int? get totalPages => _$this._totalPages;
  set totalPages(int? totalPages) => _$this._totalPages = totalPages;

  PageInfoBuilder() {
    PageInfo._defaults(this);
  }

  PageInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _page = $v.page;
      _perPage = $v.perPage;
      _total = $v.total;
      _totalPages = $v.totalPages;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PageInfo other) {
    _$v = other as _$PageInfo;
  }

  @override
  void update(void Function(PageInfoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageInfo build() => _build();

  _$PageInfo _build() {
    final _$result = _$v ??
        _$PageInfo._(
          page:
              BuiltValueNullFieldError.checkNotNull(page, r'PageInfo', 'page'),
          perPage: BuiltValueNullFieldError.checkNotNull(
              perPage, r'PageInfo', 'perPage'),
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'PageInfo', 'total'),
          totalPages: BuiltValueNullFieldError.checkNotNull(
              totalPages, r'PageInfo', 'totalPages'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

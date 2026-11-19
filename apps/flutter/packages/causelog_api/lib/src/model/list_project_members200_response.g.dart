// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_project_members200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListProjectMembers200Response extends ListProjectMembers200Response {
  @override
  final BuiltList<ProjectMemberInfo> items;

  factory _$ListProjectMembers200Response(
          [void Function(ListProjectMembers200ResponseBuilder)? updates]) =>
      (ListProjectMembers200ResponseBuilder()..update(updates))._build();

  _$ListProjectMembers200Response._({required this.items}) : super._();
  @override
  ListProjectMembers200Response rebuild(
          void Function(ListProjectMembers200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListProjectMembers200ResponseBuilder toBuilder() =>
      ListProjectMembers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListProjectMembers200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'ListProjectMembers200Response')
          ..add('items', items))
        .toString();
  }
}

class ListProjectMembers200ResponseBuilder
    implements
        Builder<ListProjectMembers200Response,
            ListProjectMembers200ResponseBuilder> {
  _$ListProjectMembers200Response? _$v;

  ListBuilder<ProjectMemberInfo>? _items;
  ListBuilder<ProjectMemberInfo> get items =>
      _$this._items ??= ListBuilder<ProjectMemberInfo>();
  set items(ListBuilder<ProjectMemberInfo>? items) => _$this._items = items;

  ListProjectMembers200ResponseBuilder() {
    ListProjectMembers200Response._defaults(this);
  }

  ListProjectMembers200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListProjectMembers200Response other) {
    _$v = other as _$ListProjectMembers200Response;
  }

  @override
  void update(void Function(ListProjectMembers200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListProjectMembers200Response build() => _build();

  _$ListProjectMembers200Response _build() {
    _$ListProjectMembers200Response _$result;
    try {
      _$result = _$v ??
          _$ListProjectMembers200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListProjectMembers200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

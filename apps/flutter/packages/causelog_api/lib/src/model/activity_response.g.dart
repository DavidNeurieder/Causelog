// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActivityResponse extends ActivityResponse {
  @override
  final BuiltList<ActivityItem> items;

  factory _$ActivityResponse(
          [void Function(ActivityResponseBuilder)? updates]) =>
      (ActivityResponseBuilder()..update(updates))._build();

  _$ActivityResponse._({required this.items}) : super._();
  @override
  ActivityResponse rebuild(void Function(ActivityResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActivityResponseBuilder toBuilder() =>
      ActivityResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActivityResponse && items == other.items;
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
    return (newBuiltValueToStringHelper(r'ActivityResponse')
          ..add('items', items))
        .toString();
  }
}

class ActivityResponseBuilder
    implements Builder<ActivityResponse, ActivityResponseBuilder> {
  _$ActivityResponse? _$v;

  ListBuilder<ActivityItem>? _items;
  ListBuilder<ActivityItem> get items =>
      _$this._items ??= ListBuilder<ActivityItem>();
  set items(ListBuilder<ActivityItem>? items) => _$this._items = items;

  ActivityResponseBuilder() {
    ActivityResponse._defaults(this);
  }

  ActivityResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActivityResponse other) {
    _$v = other as _$ActivityResponse;
  }

  @override
  void update(void Function(ActivityResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActivityResponse build() => _build();

  _$ActivityResponse _build() {
    _$ActivityResponse _$result;
    try {
      _$result = _$v ??
          _$ActivityResponse._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActivityResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

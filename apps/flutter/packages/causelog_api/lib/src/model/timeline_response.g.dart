// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimelineResponse extends TimelineResponse {
  @override
  final BuiltList<TimelineEvent> items;

  factory _$TimelineResponse(
          [void Function(TimelineResponseBuilder)? updates]) =>
      (TimelineResponseBuilder()..update(updates))._build();

  _$TimelineResponse._({required this.items}) : super._();
  @override
  TimelineResponse rebuild(void Function(TimelineResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimelineResponseBuilder toBuilder() =>
      TimelineResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimelineResponse && items == other.items;
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
    return (newBuiltValueToStringHelper(r'TimelineResponse')
          ..add('items', items))
        .toString();
  }
}

class TimelineResponseBuilder
    implements Builder<TimelineResponse, TimelineResponseBuilder> {
  _$TimelineResponse? _$v;

  ListBuilder<TimelineEvent>? _items;
  ListBuilder<TimelineEvent> get items =>
      _$this._items ??= ListBuilder<TimelineEvent>();
  set items(ListBuilder<TimelineEvent>? items) => _$this._items = items;

  TimelineResponseBuilder() {
    TimelineResponse._defaults(this);
  }

  TimelineResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimelineResponse other) {
    _$v = other as _$TimelineResponse;
  }

  @override
  void update(void Function(TimelineResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimelineResponse build() => _build();

  _$TimelineResponse _build() {
    _$TimelineResponse _$result;
    try {
      _$result = _$v ??
          _$TimelineResponse._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TimelineResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GoalUpdateRequest extends GoalUpdateRequest {
  @override
  final String? title;
  @override
  final String? body;
  @override
  final String? assignedTo;
  @override
  final GoalStatus? status;
  @override
  final String? csrfToken;

  factory _$GoalUpdateRequest(
          [void Function(GoalUpdateRequestBuilder)? updates]) =>
      (GoalUpdateRequestBuilder()..update(updates))._build();

  _$GoalUpdateRequest._(
      {this.title, this.body, this.assignedTo, this.status, this.csrfToken})
      : super._();
  @override
  GoalUpdateRequest rebuild(void Function(GoalUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GoalUpdateRequestBuilder toBuilder() =>
      GoalUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GoalUpdateRequest &&
        title == other.title &&
        body == other.body &&
        assignedTo == other.assignedTo &&
        status == other.status &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, assignedTo.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GoalUpdateRequest')
          ..add('title', title)
          ..add('body', body)
          ..add('assignedTo', assignedTo)
          ..add('status', status)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class GoalUpdateRequestBuilder
    implements
        Builder<GoalUpdateRequest, GoalUpdateRequestBuilder>,
        CsrfBodyBuilder {
  _$GoalUpdateRequest? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(covariant String? body) => _$this._body = body;

  String? _assignedTo;
  String? get assignedTo => _$this._assignedTo;
  set assignedTo(covariant String? assignedTo) =>
      _$this._assignedTo = assignedTo;

  GoalStatus? _status;
  GoalStatus? get status => _$this._status;
  set status(covariant GoalStatus? status) => _$this._status = status;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  GoalUpdateRequestBuilder() {
    GoalUpdateRequest._defaults(this);
  }

  GoalUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _body = $v.body;
      _assignedTo = $v.assignedTo;
      _status = $v.status;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant GoalUpdateRequest other) {
    _$v = other as _$GoalUpdateRequest;
  }

  @override
  void update(void Function(GoalUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GoalUpdateRequest build() => _build();

  _$GoalUpdateRequest _build() {
    final _$result = _$v ??
        _$GoalUpdateRequest._(
          title: title,
          body: body,
          assignedTo: assignedTo,
          status: status,
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GoalCreateRequest extends GoalCreateRequest {
  @override
  final String title;
  @override
  final String? body;
  @override
  final String? assignedTo;
  @override
  final GoalStatus? status;
  @override
  final String? csrfToken;

  factory _$GoalCreateRequest(
          [void Function(GoalCreateRequestBuilder)? updates]) =>
      (GoalCreateRequestBuilder()..update(updates))._build();

  _$GoalCreateRequest._(
      {required this.title,
      this.body,
      this.assignedTo,
      this.status,
      this.csrfToken})
      : super._();
  @override
  GoalCreateRequest rebuild(void Function(GoalCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GoalCreateRequestBuilder toBuilder() =>
      GoalCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GoalCreateRequest &&
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
    return (newBuiltValueToStringHelper(r'GoalCreateRequest')
          ..add('title', title)
          ..add('body', body)
          ..add('assignedTo', assignedTo)
          ..add('status', status)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class GoalCreateRequestBuilder
    implements
        Builder<GoalCreateRequest, GoalCreateRequestBuilder>,
        CsrfBodyBuilder {
  _$GoalCreateRequest? _$v;

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

  GoalCreateRequestBuilder() {
    GoalCreateRequest._defaults(this);
  }

  GoalCreateRequestBuilder get _$this {
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
  void replace(covariant GoalCreateRequest other) {
    _$v = other as _$GoalCreateRequest;
  }

  @override
  void update(void Function(GoalCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GoalCreateRequest build() => _build();

  _$GoalCreateRequest _build() {
    final _$result = _$v ??
        _$GoalCreateRequest._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GoalCreateRequest', 'title'),
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

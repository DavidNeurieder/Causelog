// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExperimentCreateRequest extends ExperimentCreateRequest {
  @override
  final String? goalId;
  @override
  final String? decisionId;
  @override
  final String title;
  @override
  final String? hypothesis;
  @override
  final ExperimentStatus? status;
  @override
  final String? csrfToken;

  factory _$ExperimentCreateRequest(
          [void Function(ExperimentCreateRequestBuilder)? updates]) =>
      (ExperimentCreateRequestBuilder()..update(updates))._build();

  _$ExperimentCreateRequest._(
      {this.goalId,
      this.decisionId,
      required this.title,
      this.hypothesis,
      this.status,
      this.csrfToken})
      : super._();
  @override
  ExperimentCreateRequest rebuild(
          void Function(ExperimentCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExperimentCreateRequestBuilder toBuilder() =>
      ExperimentCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExperimentCreateRequest &&
        goalId == other.goalId &&
        decisionId == other.decisionId &&
        title == other.title &&
        hypothesis == other.hypothesis &&
        status == other.status &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, goalId.hashCode);
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, hypothesis.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExperimentCreateRequest')
          ..add('goalId', goalId)
          ..add('decisionId', decisionId)
          ..add('title', title)
          ..add('hypothesis', hypothesis)
          ..add('status', status)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class ExperimentCreateRequestBuilder
    implements
        Builder<ExperimentCreateRequest, ExperimentCreateRequestBuilder>,
        CsrfBodyBuilder {
  _$ExperimentCreateRequest? _$v;

  String? _goalId;
  String? get goalId => _$this._goalId;
  set goalId(covariant String? goalId) => _$this._goalId = goalId;

  String? _decisionId;
  String? get decisionId => _$this._decisionId;
  set decisionId(covariant String? decisionId) =>
      _$this._decisionId = decisionId;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  String? _hypothesis;
  String? get hypothesis => _$this._hypothesis;
  set hypothesis(covariant String? hypothesis) =>
      _$this._hypothesis = hypothesis;

  ExperimentStatus? _status;
  ExperimentStatus? get status => _$this._status;
  set status(covariant ExperimentStatus? status) => _$this._status = status;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  ExperimentCreateRequestBuilder() {
    ExperimentCreateRequest._defaults(this);
  }

  ExperimentCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _goalId = $v.goalId;
      _decisionId = $v.decisionId;
      _title = $v.title;
      _hypothesis = $v.hypothesis;
      _status = $v.status;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ExperimentCreateRequest other) {
    _$v = other as _$ExperimentCreateRequest;
  }

  @override
  void update(void Function(ExperimentCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExperimentCreateRequest build() => _build();

  _$ExperimentCreateRequest _build() {
    final _$result = _$v ??
        _$ExperimentCreateRequest._(
          goalId: goalId,
          decisionId: decisionId,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'ExperimentCreateRequest', 'title'),
          hypothesis: hypothesis,
          status: status,
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

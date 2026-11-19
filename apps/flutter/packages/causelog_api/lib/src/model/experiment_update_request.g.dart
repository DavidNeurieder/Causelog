// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExperimentUpdateRequest extends ExperimentUpdateRequest {
  @override
  final String? result;
  @override
  final String? goalId;
  @override
  final String? lesson;
  @override
  final int? endedAtMs;
  @override
  final String? decisionId;
  @override
  final String? title;
  @override
  final String? hypothesis;
  @override
  final int? startedAtMs;
  @override
  final ExperimentStatus? status;
  @override
  final String? csrfToken;

  factory _$ExperimentUpdateRequest(
          [void Function(ExperimentUpdateRequestBuilder)? updates]) =>
      (ExperimentUpdateRequestBuilder()..update(updates))._build();

  _$ExperimentUpdateRequest._(
      {this.result,
      this.goalId,
      this.lesson,
      this.endedAtMs,
      this.decisionId,
      this.title,
      this.hypothesis,
      this.startedAtMs,
      this.status,
      this.csrfToken})
      : super._();
  @override
  ExperimentUpdateRequest rebuild(
          void Function(ExperimentUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExperimentUpdateRequestBuilder toBuilder() =>
      ExperimentUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExperimentUpdateRequest &&
        result == other.result &&
        goalId == other.goalId &&
        lesson == other.lesson &&
        endedAtMs == other.endedAtMs &&
        decisionId == other.decisionId &&
        title == other.title &&
        hypothesis == other.hypothesis &&
        startedAtMs == other.startedAtMs &&
        status == other.status &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, result.hashCode);
    _$hash = $jc(_$hash, goalId.hashCode);
    _$hash = $jc(_$hash, lesson.hashCode);
    _$hash = $jc(_$hash, endedAtMs.hashCode);
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, hypothesis.hashCode);
    _$hash = $jc(_$hash, startedAtMs.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExperimentUpdateRequest')
          ..add('result', result)
          ..add('goalId', goalId)
          ..add('lesson', lesson)
          ..add('endedAtMs', endedAtMs)
          ..add('decisionId', decisionId)
          ..add('title', title)
          ..add('hypothesis', hypothesis)
          ..add('startedAtMs', startedAtMs)
          ..add('status', status)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class ExperimentUpdateRequestBuilder
    implements
        Builder<ExperimentUpdateRequest, ExperimentUpdateRequestBuilder>,
        CsrfBodyBuilder {
  _$ExperimentUpdateRequest? _$v;

  String? _result;
  String? get result => _$this._result;
  set result(covariant String? result) => _$this._result = result;

  String? _goalId;
  String? get goalId => _$this._goalId;
  set goalId(covariant String? goalId) => _$this._goalId = goalId;

  String? _lesson;
  String? get lesson => _$this._lesson;
  set lesson(covariant String? lesson) => _$this._lesson = lesson;

  int? _endedAtMs;
  int? get endedAtMs => _$this._endedAtMs;
  set endedAtMs(covariant int? endedAtMs) => _$this._endedAtMs = endedAtMs;

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

  int? _startedAtMs;
  int? get startedAtMs => _$this._startedAtMs;
  set startedAtMs(covariant int? startedAtMs) =>
      _$this._startedAtMs = startedAtMs;

  ExperimentStatus? _status;
  ExperimentStatus? get status => _$this._status;
  set status(covariant ExperimentStatus? status) => _$this._status = status;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  ExperimentUpdateRequestBuilder() {
    ExperimentUpdateRequest._defaults(this);
  }

  ExperimentUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _result = $v.result;
      _goalId = $v.goalId;
      _lesson = $v.lesson;
      _endedAtMs = $v.endedAtMs;
      _decisionId = $v.decisionId;
      _title = $v.title;
      _hypothesis = $v.hypothesis;
      _startedAtMs = $v.startedAtMs;
      _status = $v.status;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ExperimentUpdateRequest other) {
    _$v = other as _$ExperimentUpdateRequest;
  }

  @override
  void update(void Function(ExperimentUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExperimentUpdateRequest build() => _build();

  _$ExperimentUpdateRequest _build() {
    final _$result = _$v ??
        _$ExperimentUpdateRequest._(
          result: result,
          goalId: goalId,
          lesson: lesson,
          endedAtMs: endedAtMs,
          decisionId: decisionId,
          title: title,
          hypothesis: hypothesis,
          startedAtMs: startedAtMs,
          status: status,
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

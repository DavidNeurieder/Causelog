// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class ExperimentBuilder {
  void replace(Experiment other);
  void update(void Function(ExperimentBuilder) updates);
  String? get id;
  set id(String? id);

  String? get projectId;
  set projectId(String? projectId);

  String? get goalId;
  set goalId(String? goalId);

  String? get decisionId;
  set decisionId(String? decisionId);

  String? get title;
  set title(String? title);

  String? get hypothesis;
  set hypothesis(String? hypothesis);

  ExperimentStatus? get status;
  set status(ExperimentStatus? status);

  int? get startedAtMs;
  set startedAtMs(int? startedAtMs);

  int? get endedAtMs;
  set endedAtMs(int? endedAtMs);

  String? get result;
  set result(String? result);

  String? get lesson;
  set lesson(String? lesson);

  String? get createdBy;
  set createdBy(String? createdBy);

  int? get createdAtMs;
  set createdAtMs(int? createdAtMs);

  int? get updatedAtMs;
  set updatedAtMs(int? updatedAtMs);
}

class _$$Experiment extends $Experiment {
  @override
  final String id;
  @override
  final String projectId;
  @override
  final String? goalId;
  @override
  final String? decisionId;
  @override
  final String title;
  @override
  final String hypothesis;
  @override
  final ExperimentStatus status;
  @override
  final int? startedAtMs;
  @override
  final int? endedAtMs;
  @override
  final String result;
  @override
  final String lesson;
  @override
  final String? createdBy;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;

  factory _$$Experiment([void Function($ExperimentBuilder)? updates]) =>
      ($ExperimentBuilder()..update(updates))._build();

  _$$Experiment._(
      {required this.id,
      required this.projectId,
      this.goalId,
      this.decisionId,
      required this.title,
      required this.hypothesis,
      required this.status,
      this.startedAtMs,
      this.endedAtMs,
      required this.result,
      required this.lesson,
      this.createdBy,
      required this.createdAtMs,
      required this.updatedAtMs})
      : super._();
  @override
  $Experiment rebuild(void Function($ExperimentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $ExperimentBuilder toBuilder() => $ExperimentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $Experiment &&
        id == other.id &&
        projectId == other.projectId &&
        goalId == other.goalId &&
        decisionId == other.decisionId &&
        title == other.title &&
        hypothesis == other.hypothesis &&
        status == other.status &&
        startedAtMs == other.startedAtMs &&
        endedAtMs == other.endedAtMs &&
        result == other.result &&
        lesson == other.lesson &&
        createdBy == other.createdBy &&
        createdAtMs == other.createdAtMs &&
        updatedAtMs == other.updatedAtMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, goalId.hashCode);
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, hypothesis.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, startedAtMs.hashCode);
    _$hash = $jc(_$hash, endedAtMs.hashCode);
    _$hash = $jc(_$hash, result.hashCode);
    _$hash = $jc(_$hash, lesson.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jc(_$hash, updatedAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$Experiment')
          ..add('id', id)
          ..add('projectId', projectId)
          ..add('goalId', goalId)
          ..add('decisionId', decisionId)
          ..add('title', title)
          ..add('hypothesis', hypothesis)
          ..add('status', status)
          ..add('startedAtMs', startedAtMs)
          ..add('endedAtMs', endedAtMs)
          ..add('result', result)
          ..add('lesson', lesson)
          ..add('createdBy', createdBy)
          ..add('createdAtMs', createdAtMs)
          ..add('updatedAtMs', updatedAtMs))
        .toString();
  }
}

class $ExperimentBuilder
    implements Builder<$Experiment, $ExperimentBuilder>, ExperimentBuilder {
  _$$Experiment? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(covariant String? projectId) => _$this._projectId = projectId;

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

  int? _startedAtMs;
  int? get startedAtMs => _$this._startedAtMs;
  set startedAtMs(covariant int? startedAtMs) =>
      _$this._startedAtMs = startedAtMs;

  int? _endedAtMs;
  int? get endedAtMs => _$this._endedAtMs;
  set endedAtMs(covariant int? endedAtMs) => _$this._endedAtMs = endedAtMs;

  String? _result;
  String? get result => _$this._result;
  set result(covariant String? result) => _$this._result = result;

  String? _lesson;
  String? get lesson => _$this._lesson;
  set lesson(covariant String? lesson) => _$this._lesson = lesson;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(covariant String? createdBy) => _$this._createdBy = createdBy;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(covariant int? createdAtMs) =>
      _$this._createdAtMs = createdAtMs;

  int? _updatedAtMs;
  int? get updatedAtMs => _$this._updatedAtMs;
  set updatedAtMs(covariant int? updatedAtMs) =>
      _$this._updatedAtMs = updatedAtMs;

  $ExperimentBuilder() {
    $Experiment._defaults(this);
  }

  $ExperimentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _projectId = $v.projectId;
      _goalId = $v.goalId;
      _decisionId = $v.decisionId;
      _title = $v.title;
      _hypothesis = $v.hypothesis;
      _status = $v.status;
      _startedAtMs = $v.startedAtMs;
      _endedAtMs = $v.endedAtMs;
      _result = $v.result;
      _lesson = $v.lesson;
      _createdBy = $v.createdBy;
      _createdAtMs = $v.createdAtMs;
      _updatedAtMs = $v.updatedAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $Experiment other) {
    _$v = other as _$$Experiment;
  }

  @override
  void update(void Function($ExperimentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $Experiment build() => _build();

  _$$Experiment _build() {
    final _$result = _$v ??
        _$$Experiment._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'$Experiment', 'id'),
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'$Experiment', 'projectId'),
          goalId: goalId,
          decisionId: decisionId,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'$Experiment', 'title'),
          hypothesis: BuiltValueNullFieldError.checkNotNull(
              hypothesis, r'$Experiment', 'hypothesis'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'$Experiment', 'status'),
          startedAtMs: startedAtMs,
          endedAtMs: endedAtMs,
          result: BuiltValueNullFieldError.checkNotNull(
              result, r'$Experiment', 'result'),
          lesson: BuiltValueNullFieldError.checkNotNull(
              lesson, r'$Experiment', 'lesson'),
          createdBy: createdBy,
          createdAtMs: BuiltValueNullFieldError.checkNotNull(
              createdAtMs, r'$Experiment', 'createdAtMs'),
          updatedAtMs: BuiltValueNullFieldError.checkNotNull(
              updatedAtMs, r'$Experiment', 'updatedAtMs'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

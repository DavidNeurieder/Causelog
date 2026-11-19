// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Goal extends Goal {
  @override
  final String id;
  @override
  final String projectId;
  @override
  final String title;
  @override
  final String body;
  @override
  final GoalStatus status;
  @override
  final String? createdBy;
  @override
  final String? assignedTo;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;

  factory _$Goal([void Function(GoalBuilder)? updates]) =>
      (GoalBuilder()..update(updates))._build();

  _$Goal._(
      {required this.id,
      required this.projectId,
      required this.title,
      required this.body,
      required this.status,
      this.createdBy,
      this.assignedTo,
      required this.createdAtMs,
      required this.updatedAtMs})
      : super._();
  @override
  Goal rebuild(void Function(GoalBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GoalBuilder toBuilder() => GoalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Goal &&
        id == other.id &&
        projectId == other.projectId &&
        title == other.title &&
        body == other.body &&
        status == other.status &&
        createdBy == other.createdBy &&
        assignedTo == other.assignedTo &&
        createdAtMs == other.createdAtMs &&
        updatedAtMs == other.updatedAtMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, assignedTo.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jc(_$hash, updatedAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Goal')
          ..add('id', id)
          ..add('projectId', projectId)
          ..add('title', title)
          ..add('body', body)
          ..add('status', status)
          ..add('createdBy', createdBy)
          ..add('assignedTo', assignedTo)
          ..add('createdAtMs', createdAtMs)
          ..add('updatedAtMs', updatedAtMs))
        .toString();
  }
}

class GoalBuilder implements Builder<Goal, GoalBuilder> {
  _$Goal? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  GoalStatus? _status;
  GoalStatus? get status => _$this._status;
  set status(GoalStatus? status) => _$this._status = status;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  String? _assignedTo;
  String? get assignedTo => _$this._assignedTo;
  set assignedTo(String? assignedTo) => _$this._assignedTo = assignedTo;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(int? createdAtMs) => _$this._createdAtMs = createdAtMs;

  int? _updatedAtMs;
  int? get updatedAtMs => _$this._updatedAtMs;
  set updatedAtMs(int? updatedAtMs) => _$this._updatedAtMs = updatedAtMs;

  GoalBuilder() {
    Goal._defaults(this);
  }

  GoalBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _projectId = $v.projectId;
      _title = $v.title;
      _body = $v.body;
      _status = $v.status;
      _createdBy = $v.createdBy;
      _assignedTo = $v.assignedTo;
      _createdAtMs = $v.createdAtMs;
      _updatedAtMs = $v.updatedAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Goal other) {
    _$v = other as _$Goal;
  }

  @override
  void update(void Function(GoalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Goal build() => _build();

  _$Goal _build() {
    final _$result = _$v ??
        _$Goal._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Goal', 'id'),
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'Goal', 'projectId'),
          title: BuiltValueNullFieldError.checkNotNull(title, r'Goal', 'title'),
          body: BuiltValueNullFieldError.checkNotNull(body, r'Goal', 'body'),
          status:
              BuiltValueNullFieldError.checkNotNull(status, r'Goal', 'status'),
          createdBy: createdBy,
          assignedTo: assignedTo,
          createdAtMs: BuiltValueNullFieldError.checkNotNull(
              createdAtMs, r'Goal', 'createdAtMs'),
          updatedAtMs: BuiltValueNullFieldError.checkNotNull(
              updatedAtMs, r'Goal', 'updatedAtMs'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

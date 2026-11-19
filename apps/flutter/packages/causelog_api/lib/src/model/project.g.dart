// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Project extends Project {
  @override
  final String id;
  @override
  final String title;
  @override
  final String summary;
  @override
  final ProjectStatus status;
  @override
  final String? createdBy;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;

  factory _$Project([void Function(ProjectBuilder)? updates]) =>
      (ProjectBuilder()..update(updates))._build();

  _$Project._(
      {required this.id,
      required this.title,
      required this.summary,
      required this.status,
      this.createdBy,
      required this.createdAtMs,
      required this.updatedAtMs})
      : super._();
  @override
  Project rebuild(void Function(ProjectBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectBuilder toBuilder() => ProjectBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Project &&
        id == other.id &&
        title == other.title &&
        summary == other.summary &&
        status == other.status &&
        createdBy == other.createdBy &&
        createdAtMs == other.createdAtMs &&
        updatedAtMs == other.updatedAtMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jc(_$hash, updatedAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Project')
          ..add('id', id)
          ..add('title', title)
          ..add('summary', summary)
          ..add('status', status)
          ..add('createdBy', createdBy)
          ..add('createdAtMs', createdAtMs)
          ..add('updatedAtMs', updatedAtMs))
        .toString();
  }
}

class ProjectBuilder implements Builder<Project, ProjectBuilder> {
  _$Project? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  ProjectStatus? _status;
  ProjectStatus? get status => _$this._status;
  set status(ProjectStatus? status) => _$this._status = status;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(int? createdAtMs) => _$this._createdAtMs = createdAtMs;

  int? _updatedAtMs;
  int? get updatedAtMs => _$this._updatedAtMs;
  set updatedAtMs(int? updatedAtMs) => _$this._updatedAtMs = updatedAtMs;

  ProjectBuilder() {
    Project._defaults(this);
  }

  ProjectBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _summary = $v.summary;
      _status = $v.status;
      _createdBy = $v.createdBy;
      _createdAtMs = $v.createdAtMs;
      _updatedAtMs = $v.updatedAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Project other) {
    _$v = other as _$Project;
  }

  @override
  void update(void Function(ProjectBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Project build() => _build();

  _$Project _build() {
    final _$result = _$v ??
        _$Project._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Project', 'id'),
          title:
              BuiltValueNullFieldError.checkNotNull(title, r'Project', 'title'),
          summary: BuiltValueNullFieldError.checkNotNull(
              summary, r'Project', 'summary'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Project', 'status'),
          createdBy: createdBy,
          createdAtMs: BuiltValueNullFieldError.checkNotNull(
              createdAtMs, r'Project', 'createdAtMs'),
          updatedAtMs: BuiltValueNullFieldError.checkNotNull(
              updatedAtMs, r'Project', 'updatedAtMs'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

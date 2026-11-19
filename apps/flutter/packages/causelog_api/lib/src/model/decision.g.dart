// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Decision extends Decision {
  @override
  final String id;
  @override
  final String projectId;
  @override
  final String? goalId;
  @override
  final String title;
  @override
  final String context;
  @override
  final BuiltList<DecisionOption> options;
  @override
  final DecisionStatus status;
  @override
  final String? decidedOption;
  @override
  final String rationale;
  @override
  final int? decidedAtMs;
  @override
  final int? reviewAtMs;
  @override
  final String? createdBy;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;

  factory _$Decision([void Function(DecisionBuilder)? updates]) =>
      (DecisionBuilder()..update(updates))._build();

  _$Decision._(
      {required this.id,
      required this.projectId,
      this.goalId,
      required this.title,
      required this.context,
      required this.options,
      required this.status,
      this.decidedOption,
      required this.rationale,
      this.decidedAtMs,
      this.reviewAtMs,
      this.createdBy,
      required this.createdAtMs,
      required this.updatedAtMs})
      : super._();
  @override
  Decision rebuild(void Function(DecisionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DecisionBuilder toBuilder() => DecisionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Decision &&
        id == other.id &&
        projectId == other.projectId &&
        goalId == other.goalId &&
        title == other.title &&
        context == other.context &&
        options == other.options &&
        status == other.status &&
        decidedOption == other.decidedOption &&
        rationale == other.rationale &&
        decidedAtMs == other.decidedAtMs &&
        reviewAtMs == other.reviewAtMs &&
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
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, context.hashCode);
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, decidedOption.hashCode);
    _$hash = $jc(_$hash, rationale.hashCode);
    _$hash = $jc(_$hash, decidedAtMs.hashCode);
    _$hash = $jc(_$hash, reviewAtMs.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jc(_$hash, updatedAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Decision')
          ..add('id', id)
          ..add('projectId', projectId)
          ..add('goalId', goalId)
          ..add('title', title)
          ..add('context', context)
          ..add('options', options)
          ..add('status', status)
          ..add('decidedOption', decidedOption)
          ..add('rationale', rationale)
          ..add('decidedAtMs', decidedAtMs)
          ..add('reviewAtMs', reviewAtMs)
          ..add('createdBy', createdBy)
          ..add('createdAtMs', createdAtMs)
          ..add('updatedAtMs', updatedAtMs))
        .toString();
  }
}

class DecisionBuilder implements Builder<Decision, DecisionBuilder> {
  _$Decision? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  String? _goalId;
  String? get goalId => _$this._goalId;
  set goalId(String? goalId) => _$this._goalId = goalId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _context;
  String? get context => _$this._context;
  set context(String? context) => _$this._context = context;

  ListBuilder<DecisionOption>? _options;
  ListBuilder<DecisionOption> get options =>
      _$this._options ??= ListBuilder<DecisionOption>();
  set options(ListBuilder<DecisionOption>? options) =>
      _$this._options = options;

  DecisionStatus? _status;
  DecisionStatus? get status => _$this._status;
  set status(DecisionStatus? status) => _$this._status = status;

  String? _decidedOption;
  String? get decidedOption => _$this._decidedOption;
  set decidedOption(String? decidedOption) =>
      _$this._decidedOption = decidedOption;

  String? _rationale;
  String? get rationale => _$this._rationale;
  set rationale(String? rationale) => _$this._rationale = rationale;

  int? _decidedAtMs;
  int? get decidedAtMs => _$this._decidedAtMs;
  set decidedAtMs(int? decidedAtMs) => _$this._decidedAtMs = decidedAtMs;

  int? _reviewAtMs;
  int? get reviewAtMs => _$this._reviewAtMs;
  set reviewAtMs(int? reviewAtMs) => _$this._reviewAtMs = reviewAtMs;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(int? createdAtMs) => _$this._createdAtMs = createdAtMs;

  int? _updatedAtMs;
  int? get updatedAtMs => _$this._updatedAtMs;
  set updatedAtMs(int? updatedAtMs) => _$this._updatedAtMs = updatedAtMs;

  DecisionBuilder() {
    Decision._defaults(this);
  }

  DecisionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _projectId = $v.projectId;
      _goalId = $v.goalId;
      _title = $v.title;
      _context = $v.context;
      _options = $v.options.toBuilder();
      _status = $v.status;
      _decidedOption = $v.decidedOption;
      _rationale = $v.rationale;
      _decidedAtMs = $v.decidedAtMs;
      _reviewAtMs = $v.reviewAtMs;
      _createdBy = $v.createdBy;
      _createdAtMs = $v.createdAtMs;
      _updatedAtMs = $v.updatedAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Decision other) {
    _$v = other as _$Decision;
  }

  @override
  void update(void Function(DecisionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Decision build() => _build();

  _$Decision _build() {
    _$Decision _$result;
    try {
      _$result = _$v ??
          _$Decision._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Decision', 'id'),
            projectId: BuiltValueNullFieldError.checkNotNull(
                projectId, r'Decision', 'projectId'),
            goalId: goalId,
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'Decision', 'title'),
            context: BuiltValueNullFieldError.checkNotNull(
                context, r'Decision', 'context'),
            options: options.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Decision', 'status'),
            decidedOption: decidedOption,
            rationale: BuiltValueNullFieldError.checkNotNull(
                rationale, r'Decision', 'rationale'),
            decidedAtMs: decidedAtMs,
            reviewAtMs: reviewAtMs,
            createdBy: createdBy,
            createdAtMs: BuiltValueNullFieldError.checkNotNull(
                createdAtMs, r'Decision', 'createdAtMs'),
            updatedAtMs: BuiltValueNullFieldError.checkNotNull(
                updatedAtMs, r'Decision', 'updatedAtMs'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'options';
        options.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Decision', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

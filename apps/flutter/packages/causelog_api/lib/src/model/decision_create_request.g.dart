// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DecisionCreateRequest extends DecisionCreateRequest {
  @override
  final String? goalId;
  @override
  final int? reviewAtMs;
  @override
  final String? decidedOption;
  @override
  final String? context;
  @override
  final BuiltList<DecisionOption>? options;
  @override
  final String title;
  @override
  final String? rationale;
  @override
  final DecisionStatus? status;
  @override
  final String? csrfToken;

  factory _$DecisionCreateRequest(
          [void Function(DecisionCreateRequestBuilder)? updates]) =>
      (DecisionCreateRequestBuilder()..update(updates))._build();

  _$DecisionCreateRequest._(
      {this.goalId,
      this.reviewAtMs,
      this.decidedOption,
      this.context,
      this.options,
      required this.title,
      this.rationale,
      this.status,
      this.csrfToken})
      : super._();
  @override
  DecisionCreateRequest rebuild(
          void Function(DecisionCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DecisionCreateRequestBuilder toBuilder() =>
      DecisionCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DecisionCreateRequest &&
        goalId == other.goalId &&
        reviewAtMs == other.reviewAtMs &&
        decidedOption == other.decidedOption &&
        context == other.context &&
        options == other.options &&
        title == other.title &&
        rationale == other.rationale &&
        status == other.status &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, goalId.hashCode);
    _$hash = $jc(_$hash, reviewAtMs.hashCode);
    _$hash = $jc(_$hash, decidedOption.hashCode);
    _$hash = $jc(_$hash, context.hashCode);
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, rationale.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DecisionCreateRequest')
          ..add('goalId', goalId)
          ..add('reviewAtMs', reviewAtMs)
          ..add('decidedOption', decidedOption)
          ..add('context', context)
          ..add('options', options)
          ..add('title', title)
          ..add('rationale', rationale)
          ..add('status', status)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class DecisionCreateRequestBuilder
    implements
        Builder<DecisionCreateRequest, DecisionCreateRequestBuilder>,
        CsrfBodyBuilder {
  _$DecisionCreateRequest? _$v;

  String? _goalId;
  String? get goalId => _$this._goalId;
  set goalId(covariant String? goalId) => _$this._goalId = goalId;

  int? _reviewAtMs;
  int? get reviewAtMs => _$this._reviewAtMs;
  set reviewAtMs(covariant int? reviewAtMs) => _$this._reviewAtMs = reviewAtMs;

  String? _decidedOption;
  String? get decidedOption => _$this._decidedOption;
  set decidedOption(covariant String? decidedOption) =>
      _$this._decidedOption = decidedOption;

  String? _context;
  String? get context => _$this._context;
  set context(covariant String? context) => _$this._context = context;

  ListBuilder<DecisionOption>? _options;
  ListBuilder<DecisionOption> get options =>
      _$this._options ??= ListBuilder<DecisionOption>();
  set options(covariant ListBuilder<DecisionOption>? options) =>
      _$this._options = options;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  String? _rationale;
  String? get rationale => _$this._rationale;
  set rationale(covariant String? rationale) => _$this._rationale = rationale;

  DecisionStatus? _status;
  DecisionStatus? get status => _$this._status;
  set status(covariant DecisionStatus? status) => _$this._status = status;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  DecisionCreateRequestBuilder() {
    DecisionCreateRequest._defaults(this);
  }

  DecisionCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _goalId = $v.goalId;
      _reviewAtMs = $v.reviewAtMs;
      _decidedOption = $v.decidedOption;
      _context = $v.context;
      _options = $v.options?.toBuilder();
      _title = $v.title;
      _rationale = $v.rationale;
      _status = $v.status;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant DecisionCreateRequest other) {
    _$v = other as _$DecisionCreateRequest;
  }

  @override
  void update(void Function(DecisionCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DecisionCreateRequest build() => _build();

  _$DecisionCreateRequest _build() {
    _$DecisionCreateRequest _$result;
    try {
      _$result = _$v ??
          _$DecisionCreateRequest._(
            goalId: goalId,
            reviewAtMs: reviewAtMs,
            decidedOption: decidedOption,
            context: context,
            options: _options?.build(),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'DecisionCreateRequest', 'title'),
            rationale: rationale,
            status: status,
            csrfToken: csrfToken,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'options';
        _options?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DecisionCreateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

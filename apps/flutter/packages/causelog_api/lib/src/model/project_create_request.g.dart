// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProjectCreateRequest extends ProjectCreateRequest {
  @override
  final String? summary;
  @override
  final String title;
  @override
  final ProjectStatus? status;
  @override
  final String? csrfToken;

  factory _$ProjectCreateRequest(
          [void Function(ProjectCreateRequestBuilder)? updates]) =>
      (ProjectCreateRequestBuilder()..update(updates))._build();

  _$ProjectCreateRequest._(
      {this.summary, required this.title, this.status, this.csrfToken})
      : super._();
  @override
  ProjectCreateRequest rebuild(
          void Function(ProjectCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectCreateRequestBuilder toBuilder() =>
      ProjectCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectCreateRequest &&
        summary == other.summary &&
        title == other.title &&
        status == other.status &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProjectCreateRequest')
          ..add('summary', summary)
          ..add('title', title)
          ..add('status', status)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class ProjectCreateRequestBuilder
    implements
        Builder<ProjectCreateRequest, ProjectCreateRequestBuilder>,
        CsrfBodyBuilder {
  _$ProjectCreateRequest? _$v;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(covariant String? summary) => _$this._summary = summary;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  ProjectStatus? _status;
  ProjectStatus? get status => _$this._status;
  set status(covariant ProjectStatus? status) => _$this._status = status;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  ProjectCreateRequestBuilder() {
    ProjectCreateRequest._defaults(this);
  }

  ProjectCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _summary = $v.summary;
      _title = $v.title;
      _status = $v.status;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ProjectCreateRequest other) {
    _$v = other as _$ProjectCreateRequest;
  }

  @override
  void update(void Function(ProjectCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectCreateRequest build() => _build();

  _$ProjectCreateRequest _build() {
    final _$result = _$v ??
        _$ProjectCreateRequest._(
          summary: summary,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'ProjectCreateRequest', 'title'),
          status: status,
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

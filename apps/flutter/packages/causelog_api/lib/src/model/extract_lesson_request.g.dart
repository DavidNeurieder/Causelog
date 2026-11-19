// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extract_lesson_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExtractLessonRequest extends ExtractLessonRequest {
  @override
  final String? title;
  @override
  final String? body;
  @override
  final String? csrfToken;

  factory _$ExtractLessonRequest(
          [void Function(ExtractLessonRequestBuilder)? updates]) =>
      (ExtractLessonRequestBuilder()..update(updates))._build();

  _$ExtractLessonRequest._({this.title, this.body, this.csrfToken}) : super._();
  @override
  ExtractLessonRequest rebuild(
          void Function(ExtractLessonRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExtractLessonRequestBuilder toBuilder() =>
      ExtractLessonRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExtractLessonRequest &&
        title == other.title &&
        body == other.body &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExtractLessonRequest')
          ..add('title', title)
          ..add('body', body)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class ExtractLessonRequestBuilder
    implements
        Builder<ExtractLessonRequest, ExtractLessonRequestBuilder>,
        CsrfBodyBuilder {
  _$ExtractLessonRequest? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(covariant String? body) => _$this._body = body;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  ExtractLessonRequestBuilder() {
    ExtractLessonRequest._defaults(this);
  }

  ExtractLessonRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _body = $v.body;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ExtractLessonRequest other) {
    _$v = other as _$ExtractLessonRequest;
  }

  @override
  void update(void Function(ExtractLessonRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExtractLessonRequest build() => _build();

  _$ExtractLessonRequest _build() {
    final _$result = _$v ??
        _$ExtractLessonRequest._(
          title: title,
          body: body,
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

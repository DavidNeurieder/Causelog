// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NoteUpdateRequest extends NoteUpdateRequest {
  @override
  final String? title;
  @override
  final String? body;
  @override
  final String? csrfToken;

  factory _$NoteUpdateRequest(
          [void Function(NoteUpdateRequestBuilder)? updates]) =>
      (NoteUpdateRequestBuilder()..update(updates))._build();

  _$NoteUpdateRequest._({this.title, this.body, this.csrfToken}) : super._();
  @override
  NoteUpdateRequest rebuild(void Function(NoteUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NoteUpdateRequestBuilder toBuilder() =>
      NoteUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NoteUpdateRequest &&
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
    return (newBuiltValueToStringHelper(r'NoteUpdateRequest')
          ..add('title', title)
          ..add('body', body)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class NoteUpdateRequestBuilder
    implements
        Builder<NoteUpdateRequest, NoteUpdateRequestBuilder>,
        CsrfBodyBuilder {
  _$NoteUpdateRequest? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(covariant String? body) => _$this._body = body;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  NoteUpdateRequestBuilder() {
    NoteUpdateRequest._defaults(this);
  }

  NoteUpdateRequestBuilder get _$this {
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
  void replace(covariant NoteUpdateRequest other) {
    _$v = other as _$NoteUpdateRequest;
  }

  @override
  void update(void Function(NoteUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NoteUpdateRequest build() => _build();

  _$NoteUpdateRequest _build() {
    final _$result = _$v ??
        _$NoteUpdateRequest._(
          title: title,
          body: body,
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

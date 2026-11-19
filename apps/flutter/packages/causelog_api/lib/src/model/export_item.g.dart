// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExportItemFormatEnum _$exportItemFormatEnum_json =
    const ExportItemFormatEnum._('json');
const ExportItemFormatEnum _$exportItemFormatEnum_md =
    const ExportItemFormatEnum._('md');
const ExportItemFormatEnum _$exportItemFormatEnum_html =
    const ExportItemFormatEnum._('html');
const ExportItemFormatEnum _$exportItemFormatEnum_zip =
    const ExportItemFormatEnum._('zip');
const ExportItemFormatEnum _$exportItemFormatEnum_odp =
    const ExportItemFormatEnum._('odp');

ExportItemFormatEnum _$exportItemFormatEnumValueOf(String name) {
  switch (name) {
    case 'json':
      return _$exportItemFormatEnum_json;
    case 'md':
      return _$exportItemFormatEnum_md;
    case 'html':
      return _$exportItemFormatEnum_html;
    case 'zip':
      return _$exportItemFormatEnum_zip;
    case 'odp':
      return _$exportItemFormatEnum_odp;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExportItemFormatEnum> _$exportItemFormatEnumValues =
    BuiltSet<ExportItemFormatEnum>(const <ExportItemFormatEnum>[
  _$exportItemFormatEnum_json,
  _$exportItemFormatEnum_md,
  _$exportItemFormatEnum_html,
  _$exportItemFormatEnum_zip,
  _$exportItemFormatEnum_odp,
]);

Serializer<ExportItemFormatEnum> _$exportItemFormatEnumSerializer =
    _$ExportItemFormatEnumSerializer();

class _$ExportItemFormatEnumSerializer
    implements PrimitiveSerializer<ExportItemFormatEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'json': 'json',
    'md': 'md',
    'html': 'html',
    'zip': 'zip',
    'odp': 'odp',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'json': 'json',
    'md': 'md',
    'html': 'html',
    'zip': 'zip',
    'odp': 'odp',
  };

  @override
  final Iterable<Type> types = const <Type>[ExportItemFormatEnum];
  @override
  final String wireName = 'ExportItemFormatEnum';

  @override
  Object serialize(Serializers serializers, ExportItemFormatEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExportItemFormatEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExportItemFormatEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ExportItem extends ExportItem {
  @override
  final ExportItemFormatEnum format;
  @override
  final String url;
  @override
  final String contentType;
  @override
  final String? description;

  factory _$ExportItem([void Function(ExportItemBuilder)? updates]) =>
      (ExportItemBuilder()..update(updates))._build();

  _$ExportItem._(
      {required this.format,
      required this.url,
      required this.contentType,
      this.description})
      : super._();
  @override
  ExportItem rebuild(void Function(ExportItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportItemBuilder toBuilder() => ExportItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportItem &&
        format == other.format &&
        url == other.url &&
        contentType == other.contentType &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, format.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportItem')
          ..add('format', format)
          ..add('url', url)
          ..add('contentType', contentType)
          ..add('description', description))
        .toString();
  }
}

class ExportItemBuilder implements Builder<ExportItem, ExportItemBuilder> {
  _$ExportItem? _$v;

  ExportItemFormatEnum? _format;
  ExportItemFormatEnum? get format => _$this._format;
  set format(ExportItemFormatEnum? format) => _$this._format = format;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ExportItemBuilder() {
    ExportItem._defaults(this);
  }

  ExportItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _format = $v.format;
      _url = $v.url;
      _contentType = $v.contentType;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportItem other) {
    _$v = other as _$ExportItem;
  }

  @override
  void update(void Function(ExportItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportItem build() => _build();

  _$ExportItem _build() {
    final _$result = _$v ??
        _$ExportItem._(
          format: BuiltValueNullFieldError.checkNotNull(
              format, r'ExportItem', 'format'),
          url: BuiltValueNullFieldError.checkNotNull(url, r'ExportItem', 'url'),
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'ExportItem', 'contentType'),
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capabilities.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CapabilitiesExportFormatsEnum _$capabilitiesExportFormatsEnum_json =
    const CapabilitiesExportFormatsEnum._('json');
const CapabilitiesExportFormatsEnum _$capabilitiesExportFormatsEnum_md =
    const CapabilitiesExportFormatsEnum._('md');
const CapabilitiesExportFormatsEnum _$capabilitiesExportFormatsEnum_html =
    const CapabilitiesExportFormatsEnum._('html');
const CapabilitiesExportFormatsEnum _$capabilitiesExportFormatsEnum_zip =
    const CapabilitiesExportFormatsEnum._('zip');
const CapabilitiesExportFormatsEnum _$capabilitiesExportFormatsEnum_odp =
    const CapabilitiesExportFormatsEnum._('odp');

CapabilitiesExportFormatsEnum _$capabilitiesExportFormatsEnumValueOf(
    String name) {
  switch (name) {
    case 'json':
      return _$capabilitiesExportFormatsEnum_json;
    case 'md':
      return _$capabilitiesExportFormatsEnum_md;
    case 'html':
      return _$capabilitiesExportFormatsEnum_html;
    case 'zip':
      return _$capabilitiesExportFormatsEnum_zip;
    case 'odp':
      return _$capabilitiesExportFormatsEnum_odp;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CapabilitiesExportFormatsEnum>
    _$capabilitiesExportFormatsEnumValues = BuiltSet<
        CapabilitiesExportFormatsEnum>(const <CapabilitiesExportFormatsEnum>[
  _$capabilitiesExportFormatsEnum_json,
  _$capabilitiesExportFormatsEnum_md,
  _$capabilitiesExportFormatsEnum_html,
  _$capabilitiesExportFormatsEnum_zip,
  _$capabilitiesExportFormatsEnum_odp,
]);

Serializer<CapabilitiesExportFormatsEnum>
    _$capabilitiesExportFormatsEnumSerializer =
    _$CapabilitiesExportFormatsEnumSerializer();

class _$CapabilitiesExportFormatsEnumSerializer
    implements PrimitiveSerializer<CapabilitiesExportFormatsEnum> {
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
  final Iterable<Type> types = const <Type>[CapabilitiesExportFormatsEnum];
  @override
  final String wireName = 'CapabilitiesExportFormatsEnum';

  @override
  Object serialize(
          Serializers serializers, CapabilitiesExportFormatsEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CapabilitiesExportFormatsEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CapabilitiesExportFormatsEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Capabilities extends Capabilities {
  @override
  final String apiVersion;
  @override
  final String serverVersion;
  @override
  final CapabilitiesAuth auth;
  @override
  final BuiltList<CapabilitiesExportFormatsEnum> exportFormats;

  factory _$Capabilities([void Function(CapabilitiesBuilder)? updates]) =>
      (CapabilitiesBuilder()..update(updates))._build();

  _$Capabilities._(
      {required this.apiVersion,
      required this.serverVersion,
      required this.auth,
      required this.exportFormats})
      : super._();
  @override
  Capabilities rebuild(void Function(CapabilitiesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CapabilitiesBuilder toBuilder() => CapabilitiesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Capabilities &&
        apiVersion == other.apiVersion &&
        serverVersion == other.serverVersion &&
        auth == other.auth &&
        exportFormats == other.exportFormats;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, apiVersion.hashCode);
    _$hash = $jc(_$hash, serverVersion.hashCode);
    _$hash = $jc(_$hash, auth.hashCode);
    _$hash = $jc(_$hash, exportFormats.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Capabilities')
          ..add('apiVersion', apiVersion)
          ..add('serverVersion', serverVersion)
          ..add('auth', auth)
          ..add('exportFormats', exportFormats))
        .toString();
  }
}

class CapabilitiesBuilder
    implements Builder<Capabilities, CapabilitiesBuilder> {
  _$Capabilities? _$v;

  String? _apiVersion;
  String? get apiVersion => _$this._apiVersion;
  set apiVersion(String? apiVersion) => _$this._apiVersion = apiVersion;

  String? _serverVersion;
  String? get serverVersion => _$this._serverVersion;
  set serverVersion(String? serverVersion) =>
      _$this._serverVersion = serverVersion;

  CapabilitiesAuthBuilder? _auth;
  CapabilitiesAuthBuilder get auth =>
      _$this._auth ??= CapabilitiesAuthBuilder();
  set auth(CapabilitiesAuthBuilder? auth) => _$this._auth = auth;

  ListBuilder<CapabilitiesExportFormatsEnum>? _exportFormats;
  ListBuilder<CapabilitiesExportFormatsEnum> get exportFormats =>
      _$this._exportFormats ??= ListBuilder<CapabilitiesExportFormatsEnum>();
  set exportFormats(
          ListBuilder<CapabilitiesExportFormatsEnum>? exportFormats) =>
      _$this._exportFormats = exportFormats;

  CapabilitiesBuilder() {
    Capabilities._defaults(this);
  }

  CapabilitiesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _apiVersion = $v.apiVersion;
      _serverVersion = $v.serverVersion;
      _auth = $v.auth.toBuilder();
      _exportFormats = $v.exportFormats.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Capabilities other) {
    _$v = other as _$Capabilities;
  }

  @override
  void update(void Function(CapabilitiesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Capabilities build() => _build();

  _$Capabilities _build() {
    _$Capabilities _$result;
    try {
      _$result = _$v ??
          _$Capabilities._(
            apiVersion: BuiltValueNullFieldError.checkNotNull(
                apiVersion, r'Capabilities', 'apiVersion'),
            serverVersion: BuiltValueNullFieldError.checkNotNull(
                serverVersion, r'Capabilities', 'serverVersion'),
            auth: auth.build(),
            exportFormats: exportFormats.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'auth';
        auth.build();
        _$failedField = 'exportFormats';
        exportFormats.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Capabilities', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

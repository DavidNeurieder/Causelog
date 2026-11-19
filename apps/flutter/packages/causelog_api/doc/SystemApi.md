# openapi.api.SystemApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCapabilities**](SystemApi.md#getcapabilities) | **GET** /api/v1/capabilities | Server capabilities and version
[**getSetupStatus**](SystemApi.md#getsetupstatus) | **GET** /api/v1/setup/status | Whether initial setup is required
[**health**](SystemApi.md#health) | **GET** /health | Liveness probe (existing)


# **getCapabilities**
> Capabilities getCapabilities()

Server capabilities and version

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getSystemApi();

try {
    final response = api.getCapabilities();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->getCapabilities: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Capabilities**](Capabilities.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSetupStatus**
> SetupStatus getSetupStatus()

Whether initial setup is required

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getSystemApi();

try {
    final response = api.getSetupStatus();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->getSetupStatus: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SetupStatus**](SetupStatus.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **health**
> Health200Response health()

Liveness probe (existing)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getSystemApi();

try {
    final response = api.health();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->health: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Health200Response**](Health200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


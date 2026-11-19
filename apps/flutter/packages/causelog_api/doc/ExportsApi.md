# openapi.api.ExportsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listExports**](ExportsApi.md#listexports) | **GET** /api/v1/projects/{projectId}/exports | Export format manifest and download URLs


# **listExports**
> ExportManifest listExports(projectId)

Export format manifest and download URLs

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getExportsApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.listExports(projectId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExportsApi->listExports: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 

### Return type

[**ExportManifest**](ExportManifest.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


# openapi.api.AuthApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSession**](AuthApi.md#getsession) | **GET** /api/v1/session | Current session, user, and CSRF token
[**login**](AuthApi.md#login) | **POST** /api/v1/auth/login | Log in and create a session
[**logout**](AuthApi.md#logout) | **POST** /api/v1/auth/logout | Log out and clear the session
[**register**](AuthApi.md#register) | **POST** /api/v1/auth/register | Register a new user (pending admin approval)
[**setup**](AuthApi.md#setup) | **POST** /api/v1/setup | Create the first admin user and session (idempotent semantics as today)


# **getSession**
> SessionResponse getSession()

Current session, user, and CSRF token

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

final api = Openapi().getAuthApi();

try {
    final response = api.getSession();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->getSession: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SessionResponse**](SessionResponse.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **login**
> SessionResponse login(loginRequest, idempotencyKey)

Log in and create a session

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAuthApi();
final LoginRequest loginRequest = ; // LoginRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.login(loginRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**SessionResponse**](SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> logout(idempotencyKey, csrfBody)

Log out and clear the session

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

final api = Openapi().getAuthApi();
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.
final CsrfBody csrfBody = ; // CsrfBody | 

try {
    api.logout(idempotencyKey, csrfBody);
} on DioException catch (e) {
    print('Exception when calling AuthApi->logout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 
 **csrfBody** | [**CsrfBody**](CsrfBody.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **register**
> Register201Response register(registerRequest, idempotencyKey)

Register a new user (pending admin approval)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAuthApi();
final RegisterRequest registerRequest = ; // RegisterRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.register(registerRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->register: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Register201Response**](Register201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setup**
> SessionResponse setup(setupRequest, idempotencyKey)

Create the first admin user and session (idempotent semantics as today)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAuthApi();
final SetupRequest setupRequest = ; // SetupRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.setup(setupRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->setup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **setupRequest** | [**SetupRequest**](SetupRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**SessionResponse**](SessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


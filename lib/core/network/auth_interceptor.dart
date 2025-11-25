import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/datasources/auth_local_datasource.dart';

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final AuthLocalDataSource _localDataSource;

  AuthenticatedClient(this._inner, this._localDataSource);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final user = await _localDataSource.getCachedUser();
    
    if (user != null) {
      request.headers['Authorization'] = '${user.tokenType} ${user.accessToken}';
    }
    
    return _inner.send(request);
  }
}

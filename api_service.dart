import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'models.dart';

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';
  final HttpClient _client = HttpClient();
  final Random _random = Random();

  Future<T> retryWithBackoff<T>(Future<T> Function() fn) async {
    const maxRetries = 3;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await fn();
      } on SocketException catch (e) {
        if (attempt == maxRetries - 1) rethrow;
        final delay = Duration(seconds: pow(2, attempt).toInt());
        print(
          '  Error de red: ${e.osError?.message ?? e.message}. Reintentando en ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);
      } on HttpException catch (e) {
        if (attempt == maxRetries - 1) rethrow;
        final delay = Duration(seconds: pow(2, attempt).toInt());
        print(
          '  Error HTTP: ${e.message}. Reintentando en ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);
      } on TimeoutException catch (e) {
        if (attempt == maxRetries - 1) rethrow;
        final delay = Duration(seconds: pow(2, attempt).toInt());
        print(
          '  Timeout: ${e.message}. Reintentando en ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries exceeded');
  }

  Future<String> _getJson(String path, {Map<String, String>? headers}) async {
    final request = await _client.getUrl(Uri.parse('$baseUrl$path'));
    headers?.forEach((key, value) => request.headers.set(key, value));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('Error en GET $path: ${response.statusCode}');
    }
    return await response.transform(utf8.decoder).join();
  }

  Future<String> _postJson(String path, Map<String, dynamic> body) async {
    final request = await _client.postUrl(Uri.parse('$baseUrl$path'));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    if (response.statusCode != 201) {
      throw HttpException('Error en POST $path: ${response.statusCode}');
    }
    return await response.transform(utf8.decoder).join();
  }

  Future<String> getToken() async {
    return retryWithBackoff(() async {
      await _postJson('/posts', {
        'title': 'login',
        'body': 'authentication',
        'userId': _random.nextInt(10) + 1,
      });

      final body = await _getJson('/comments');
      final List<dynamic> commentsJson = jsonDecode(body) as List<dynamic>;
      final comments = commentsJson
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList();
      final tokenComment = comments[_random.nextInt(comments.length)];
      return tokenComment.email;
    });
  }

  Future<List<User>> getUsers(String token) async {
    return retryWithBackoff(() async {
      final body = await _getJson(
        '/users',
        headers: {'Authorization': 'Bearer $token'},
      );
      final List<dynamic> jsonList = jsonDecode(body) as List<dynamic>;
      return jsonList
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<Post>> getPosts(int userId) async {
    return retryWithBackoff(() async {
      final body = await _getJson('/posts?userId=$userId');
      final List<dynamic> jsonList = jsonDecode(body) as List<dynamic>;
      return jsonList
          .map((p) => Post.fromJson(p as Map<String, dynamic>))
          .toList();
    });
  }

  void close() {
    _client.close();
  }
}

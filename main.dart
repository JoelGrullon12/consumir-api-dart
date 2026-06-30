import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'api_service.dart';

String _pad(int n) => n.toString().padLeft(2, '0');

void main(List<String> arguments) async {
  final api = ApiService();
  final random = Random();

  try {
    print('Obteniendo token...');
    final token = await api.getToken();
    print('Token obtenido: $token');
    print('');

    print('Obteniendo usuarios...');
    final users = await api.getUsers(token);
    print('${users.length} usuarios encontrados.');
    print('');

    users.shuffle(random);
    final selected = users.take(random.nextInt(3) + 2);

    for (final user in selected) {
      print('=== Posts de ${user.name} (id=${user.id}) ===');
      final posts = await api.getPosts(user.id);

      posts.shuffle(random);
      final count = random.nextInt(posts.length.clamp(3, 5)) + 1;
      user.posts = posts.take(count).toList();

      for (final post in user.posts) {
        print('[${post.id}] ${post.title}');
      }
      print('');
    }

    final data = {
      'token': token,
      'users': selected.map((u) => u.toJson()).toList(),
    };

    final dir = Directory('result');
    if (!await dir.exists()) await dir.create();

    final now = DateTime.now();
    final filename =
        'result/user_posts_${now.year}-${_pad(now.month)}-${_pad(now.day)}-${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}.json';

    final file = File(filename);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    print('Datos guardados en $filename');
  } catch (e) {
    print('Error: $e');
  } finally {
    api.close();
  }
}

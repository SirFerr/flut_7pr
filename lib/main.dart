import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рецепты',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RecipeListScreen(),
    );
  }
}

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://api.api-ninjas.com/v1/recipe';
  final String _apiKey = '';

  List<dynamic> _recipes = [];
  bool _isLoading = false;

  Future<void> fetchRecipes(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _dio.get(
        _apiUrl,
        queryParameters: {'query': query},
        options: Options(
          headers: {'X-Api-Key': _apiKey},
        ),
      );
      setState(() {
        _recipes = response.data;
      });
    } catch (e) {
      print('Ошибка при получении рецептов: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепты'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск рецептов',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                fetchRecipes(query);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return Card(
                        child: ListTile(
                          title: Text(recipe['title'] ?? 'Без названия'),
                          subtitle: Text(
                              recipe['ingredients']?.replaceAll('|', '\n') ??
                                  'Нет ингредиентов'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

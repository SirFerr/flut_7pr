import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flut_7pr/api.dart';
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

class RecipeRepository {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://api.api-ninjas.com/v1/recipe';
  final String _apiKey = API;

  Future<Response> fetchRecipes(String query) {
    return _dio.get(
      _apiUrl,
      queryParameters: {'query': query},
      options: Options(
        headers: {'X-Api-Key': _apiKey},
      ),
    );
  }
}

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeRepository _repository = RecipeRepository();

  List<dynamic> _recipesFuture = [];
  List<dynamic> _recipesAsyncAwait = [];
  bool _isLoadingFuture = false;
  bool _isLoadingAsyncAwait = false;

  fetchRecipesFuture(String query) {
    setState(() {
      _isLoadingFuture = true;
    });
    try {
      print("Начало функции fetchRecipesFuture");
      final Future<Response> responseFuture = _repository.fetchRecipes(query);
      responseFuture.then((response) {
        setState(() {
          _recipesFuture = response.data;
        });
        print("Получено сообщение: ${response.data}");
      });
    } catch (e) {
      print('Ошибка при получении рецептов: $e');
    } finally {
      setState(() {
        _isLoadingFuture = false;
      });
      print("Завершение функции fetchRecipesFuture");
    }
  }

  Future<void> fetchRecipesAsyncAwait(String query) async {
    setState(() {
      _isLoadingAsyncAwait = true;
    });
    try {
      print("Начало функции fetchRecipesAsyncAwait");
      final response = await _repository.fetchRecipes(query);
      setState(() {
        _recipesAsyncAwait = response.data;
      });
      print("Получено сообщение: ${response.data}");
    } catch (e) {
      print('Ошибка при получении рецептов: $e');
    } finally {
      setState(() {
        _isLoadingAsyncAwait = false;
      });
      print("Завершение функции fetchRecipesAsyncAwait");
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
                fetchRecipesFuture(query); // Future API
                fetchRecipesAsyncAwait(query); // async-await
              },
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Future API Рецепты',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: _isLoadingFuture
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: _recipesFuture.length,
                                itemBuilder: (context, index) {
                                  final recipe = _recipesFuture[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                          recipe['title'] ?? 'Без названия'),
                                      subtitle: Text(recipe['ingredients']
                                              ?.replaceAll('|', '\n') ??
                                          'Нет ингредиентов'),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Async/Await Рецепты',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: _isLoadingAsyncAwait
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: _recipesAsyncAwait.length,
                                itemBuilder: (context, index) {
                                  final recipe = _recipesAsyncAwait[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                          recipe['title'] ?? 'Без названия'),
                                      subtitle: Text(recipe['ingredients']
                                              ?.replaceAll('|', '\n') ??
                                          'Нет ингредиентов'),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

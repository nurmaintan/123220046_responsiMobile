import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsi_046/models/movie.dart';

class ApiService {
  static const String baseUrl =
      'https://681388b3129f6313e2119693.mockapi.io/api/v1';

  Future<List<Movie>> getMovies() async {
    try {
      print('Fetching movies from: $baseUrl/movie');
      final response = await http.get(Uri.parse('$baseUrl/movie'));

      if (response.statusCode == 200) {
        // Debug the response
        print('API Response status: ${response.statusCode}');
        print('API Response headers: ${response.headers}');
        print(
            'First 200 chars of response: ${response.body.substring(0, min(200, response.body.length))}...');

        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);

        // Print the first movie data to see structure
        if (data.isNotEmpty) {
          print('First movie data structure: ${json.encode(data.first)}');
        }

        return data.map((json) => Movie.fromJson(json)).toList();
      } else {
        print('Failed API response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching movies: $e');
      throw Exception('Failed to load movies: $e');
    }
  }

  Future<Movie> getMovieById(String id) async {
    try {
      print('Fetching movie details for ID: $id');
      final response = await http.get(Uri.parse('$baseUrl/movie/$id'));

      if (response.statusCode == 200) {
        print('Movie detail response: ${response.statusCode}');
        print(
            'First 200 chars: ${response.body.substring(0, min(200, response.body.length))}...');

        final dynamic data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        print(
            'Failed to get movie details: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching movie details: $e');
      throw Exception('Failed to load movie details: $e');
    }
  }

  // Helper method to limit string length
  int min(int a, int b) {
    if (a < b) return a;
    return b;
  }
}

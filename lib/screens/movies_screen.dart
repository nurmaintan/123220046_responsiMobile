import 'package:flutter/material.dart';
import 'package:responsi_046/models/movie.dart';
import 'package:responsi_046/screens/movie_details_screen.dart';
import 'package:responsi_046/services/api_service.dart';
import 'package:responsi_046/services/shared_pref_manager.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Movie>> _moviesFuture;
  String _username = '';
  String _selectedGenre = 'All';
  List<String> _genres = ['All'];
  List<Movie> _allMovies = [];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _moviesFuture = _fetchMovies();
  }

  Future<void> _loadUsername() async {
    final username = await SharedPrefManager.getUsername();
    setState(() {
      _username = username;
    });
  }

  Future<List<Movie>> _fetchMovies() async {
    final movies = await _apiService.getMovies();
    _allMovies = movies;

    // Extract unique genres
    final uniqueGenres = <String>{'All'};
    for (var movie in movies) {
      uniqueGenres.add(movie.genre);
    }

    setState(() {
      _genres = uniqueGenres.toList();
    });

    return movies;
  }

  List<Movie> _filterMoviesByGenre(List<Movie> movies, String genre) {
    if (genre == 'All') return movies;
    return movies.where((movie) => movie.genre == genre).toList();
  }

  Future<void> _logout() async {
    await SharedPrefManager.clearAll();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies | $_username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).pushNamed('/favorites');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  'Filter by Genre: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedGenre,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGenre = newValue!;
                      });
                    },
                    items:
                        _genres.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No movies found'));
                } else {
                  final filteredMovies = _filterMoviesByGenre(
                    snapshot.data!,
                    _selectedGenre,
                  );

                  return ListView.builder(
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = filteredMovies[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailsScreen(
                                  movieId: movie.id,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 180,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                  child: movie.posterUrl.isNotEmpty
                                      ? Image.network(
                                          movie.posterUrl,
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 180,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 120,
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                'Error loading image: $error');
                                            return Container(
                                              width: 120,
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.error,
                                                      color: Colors.red),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "Image not available",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 120,
                                          height: 180,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                                Icons.image_not_supported,
                                                size: 40),
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Release Date: ${movie.releaseDate}'),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text('${movie.rating}'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(movie.genre),
                                        backgroundColor: const Color.fromARGB(255, 210, 119, 151),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

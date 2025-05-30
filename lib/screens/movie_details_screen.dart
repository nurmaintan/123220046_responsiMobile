import 'package:flutter/material.dart';
import 'package:responsi_046/models/movie.dart';
import 'package:responsi_046/services/api_service.dart';
import 'package:responsi_046/services/database_helper.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<Movie> _movieFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _movieFuture = _fetchMovieDetails();
    _checkIfFavorite();
  }

  Future<Movie> _fetchMovieDetails() async {
    return await _apiService.getMovieById(widget.movieId);
  }

  Future<void> _checkIfFavorite() async {
    final isFavorite = await DatabaseHelper.instance.isFavorite(widget.movieId);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite(Movie movie) async {
    await DatabaseHelper.instance.toggleFavorite(movie);

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: _isFavorite ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
        actions: [
          FutureBuilder<Movie>(
            future: _movieFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  if (snapshot.hasData) {
                    _toggleFavorite(snapshot.data!);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Movie>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No movie details found'));
          }

          final movie = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie poster with backdrop
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      child: movie.posterUrl.isNotEmpty
                          ? Image.network(
                              movie.posterUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading detail image: $error');
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image,
                                          size: 60, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text(
                                        "Failed to load image",
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 60, color: Colors.grey),
                            ),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.7),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '${movie.rating}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Chip(
                                label: Text(movie.genre),
                                backgroundColor: const Color.fromARGB(255, 205, 195, 192),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Movie details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection('Release Date', movie.releaseDate),
                      _buildInfoSection('Language', movie.language),
                      _buildInfoSection('Duration', movie.duration),
                      _buildInfoSection('Director', movie.director),
                      _buildInfoSection('Description', movie.description),
                      const SizedBox(height: 16),
                      const Text(
                        'Cast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.cast.map((actor) {
                          return Chip(
                            label: Text(actor),
                            backgroundColor: const Color.fromARGB(255, 210, 119, 151),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

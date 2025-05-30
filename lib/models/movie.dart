class Movie {
  final String id;
  final String title;
  final String releaseDate;
  final String posterUrl;
  final double rating;
  final String genre;
  final String description;
  final String director;
  final String language;
  final String duration;
  final List<String> cast;
  bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.posterUrl,
    required this.rating,
    required this.genre,
    required this.description,
    required this.director,
    required this.cast,
    required this.language,
    required this.duration,
    this.isFavorite = false,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Handle the cast field which might be a List or a String
    List<String> castList = [];
    if (json['cast'] != null) {
      if (json['cast'] is List) {
        castList =
            List<String>.from(json['cast'].map((item) => item.toString()));
      } else if (json['cast'] is String) {
        // If it's a comma-separated string, split it
        castList = (json['cast'] as String).split(',');
      }
    }

    // Handle genre which might be a List or a String
    String genreText = '';
    if (json['genre'] != null) {
      if (json['genre'] is List) {
        // Join the genres with a comma if it's a list
        genreText = (json['genre'] as List).join(', ');
      } else if (json['genre'] is String) {
        genreText = json['genre'] as String;
      }
    }

    // Look for imgUrl which is used in the actual API
    String posterUrl = '';
    if (json['imgUrl'] != null) {
      posterUrl = json['imgUrl'].toString();
    } else if (json['poster'] != null) {
      posterUrl = json['poster'].toString();
    } else if (json['poster_url'] != null) {
      posterUrl = json['poster_url'].toString();
    } else if (json['image'] != null) {
      posterUrl = json['image'].toString();
    } else if (json['imageUrl'] != null) {
      posterUrl = json['imageUrl'].toString();
    }

    // Log the poster URL for debugging
    print('Poster URL for ${json['title']}: $posterUrl');

    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      releaseDate: json['release_date']?.toString() ?? '',
      posterUrl: posterUrl,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      genre: genreText,
      description: json['description']?.toString() ?? '',
      director: json['director']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      cast: castList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'releaseDate': releaseDate,
      'posterUrl': posterUrl,
      'rating': rating,
      'genre': genre,
      'description': description,
      'director': director,
      'language': language,
      'duration': duration,
      'cast': cast.join(','),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      releaseDate: map['releaseDate'],
      posterUrl: map['posterUrl'],
      rating: map['rating'],
      genre: map['genre'],
      description: map['description'],
      director: map['director'],
      language: map['language'],
      duration: map['duration'],
      cast: (map['cast'] as String).split(','),
      isFavorite: map['isFavorite'] == 1,
    );
  }
}

import 'package:flutter/material.dart';
import '../api_service.dart';
import 'add_edit_review_screen.dart';

class MovieReviewsScreen extends StatefulWidget {
  final String username;

  const MovieReviewsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _MovieReviewsScreenState createState() => _MovieReviewsScreenState();
}

class _MovieReviewsScreenState extends State<MovieReviewsScreen> {
  final _apiService = ApiService();
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await _apiService.getReviews(widget.username);
    setState(() {
      _reviews = reviews;
    });
  }

  void _deleteReview(String id) async {
    final success = await _apiService.deleteReview(id);
    if (success) {
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus review')),
      );
    }
  }

  void _updateReview(String username, String id, String title, int rating, String comment, int like) async {
    final success = await _apiService.updateReview(username, id, title, rating, comment, like);
    if (success) {
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan like')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Film Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditReviewScreen(username: widget.username),
                ),
              );
              if (result == true) _loadReviews();
            },
          ),
        ],
      ),
      body: _reviews.isEmpty
          ? Center(child: Text('Belum ada review. Tambahkan sekarang!'))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  title: Text(review['title']),
                  subtitle: Text('${review['rating']} / 10\n${review['comment']}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditReviewScreen(
                                username: widget.username,
                                review: review,
                              ),
                            ),
                          );
                          if (result == true) _loadReviews();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteReview(review['_id']),
                      ),
                      IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () {
                          final currentLikes = (review['like'] ?? 0) as int;
                          _updateReview(review['username'], review['_id'], review['title'], review['rating'], review['comment'], currentLikes + 1);
                        },
                      ),
                      Text(
                        (review['like'] ?? '0').toString(), 
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

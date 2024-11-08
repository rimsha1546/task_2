import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For making API calls

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comments with Search Filter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blueGrey[50], // Light background color
      ),
      home: CommentListScreen(),
    );
  }
}

// Model class to represent a Comment
class Comment {
  final int id;
  final String name;
  final String email;
  final String body;

  Comment(
      {required this.id,
      required this.name,
      required this.email,
      required this.body});

  // Factory method to create a Comment from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      body: json['body'],
    );
  }
}

// Main screen that displays the ListView and search bar
class CommentListScreen extends StatefulWidget {
  @override
  _CommentListScreenState createState() => _CommentListScreenState();
}

class _CommentListScreenState extends State<CommentListScreen> {
  List<Comment> _comments = []; // List to hold all comments
  List<Comment> _filteredComments =
      []; // List to hold filtered comments based on search
  bool _isLoading = true; // For showing a loading indicator
  final TextEditingController _searchController = TextEditingController();

  // Fetch data from the API
  Future<void> _fetchComments() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Comment> loadedComments =
          jsonData.map((data) => Comment.fromJson(data)).toList();

      setState(() {
        _comments = loadedComments;
        _filteredComments = loadedComments;
        _isLoading = false; // Data fetched, so loading is complete
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchComments(); // Fetch data when the screen is initialized

    // Add a listener to the search bar to filter the list as the user types
    _searchController.addListener(() {
      _filterComments();
    });
  }

  // Filter comments based on the search input
  void _filterComments() {
    String query = _searchController.text.toLowerCase();
    List<Comment> filteredComments = _comments.where((comment) {
      return comment.name.toLowerCase().contains(query) ||
          comment.body.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _filteredComments = filteredComments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments with Search Filter'),
        backgroundColor: Colors.blueAccent, // Updated app bar color
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while data is fetching
          : Column(
              children: [
                // Search bar at the top
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                      filled: true,
                      fillColor:
                          Colors.white, // White background for search bar
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                    ),
                  ),
                ),
                // ListView to display the comments
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredComments.length,
                    itemBuilder: (context, index) {
                      Comment comment = _filteredComments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Rounded corners for card
                          ),
                          child: ListTile(
                            title: Text(
                              comment.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                comment.body,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                            ),
                            trailing: Text(
                              comment.email,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12.0,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController
        .dispose(); // Dispose the controller when the screen is closed
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding and decoding JSON

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<dynamic>> fetchPopularDestinations() async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:8080/api/v1/place', // Replace with your actual API endpoint
      ),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load destinations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi Guy!'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Search and Greeting
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Where are you going next?',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search your destination',
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton(Icons.hotel, 'Hotels'),
                _buildCategoryButton(Icons.flight, 'Flights'),
                _buildCategoryButton(Icons.all_inclusive, 'All'),
              ],
            ),
          ),

          // Popular Destinations fetched from API
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Popular Destinations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Use Flexible instead of Expanded to allow scrolling
          Flexible(
            child: FutureBuilder<List<dynamic>>(
              future: fetchPopularDestinations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  // Display data in a grid view
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var destination = snapshot.data![index];
                      return _buildDestinationCard(
                        destination['name'], // Display place name
                        destination['image'], // Use the image URL from JSON
                        destination['star'],  // Use the star rating from JSON
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.purple,
      ),
    );
  }

  // Helper function for Category Buttons
  Widget _buildCategoryButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.purple),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.black)),
      ],
    );
  }

  // Helper function for Destination Cards
  Widget _buildDestinationCard(String name, String imageUrl, double rating) {
    return Card(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow),
                  Text(rating.toString()),
                ],
              ),
            ],
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Icon(Icons.favorite_border, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

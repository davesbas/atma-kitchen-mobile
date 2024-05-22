import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Atma Kitchen'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where Flavor Meets Soul, Every Dish Tells a Story',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://st4.depositphotos.com/1010121/24692/i/450/depositphotos_246923750-stock-photo-one-whole-german-black-forest.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Welcome to Atma Kitchen, where every dish is a story waiting to be tasted. Our chefs blend tradition with innovation, crafting culinary experiences that ignite the senses. From carefully sourced ingredients to bold flavors, each bite is a journey of authenticity and delight.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              'Our Philosophy:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'At Atma Kitchen, we believe that food is more than just sustenance - it is a reflection of culture, heritage, and passion. Each dish we create is infused with soul, telling a unique story that celebrates the diversity of flavors and traditions from around the world.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              'Our Mission:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Our mission is simple: to create memorable culinary experiences that inspire and delight our guests. We strive to push the boundaries of flavor, constantly innovating and exploring new techniques and ingredients. At Atma Kitchen, every dish is crafted with care, passion, and a touch of soul.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AboutPage(),
  ));
}

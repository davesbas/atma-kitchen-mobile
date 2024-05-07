import 'package:atma_kitchen_mobile/auth_service/auth_service.dart';
import 'package:atma_kitchen_mobile/auth_service/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:atma_kitchen_mobile/view/loginView.dart';
// import 'package:atma_kitchen_mobile/auth_service/auth_service.dart';

class customerViewPage extends StatefulWidget {
  const customerViewPage({super.key});

  @override
  _customerViewPageState createState() => _customerViewPageState();
}

class _customerViewPageState extends State<customerViewPage> {
  String _userName = '';
  String _userEmail = '';
  int _userPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    _getUserInfo();
    super.initState();
    // Ambil informasi pengguna saat initState
  }

  // Method untuk mengambil informasi pengguna
  Future<void> _getUserInfo() async {
    await CustomerService.getUserInfo().then((c) {
      setState(() {
        _userName = c.nama;
        _userEmail = c.email; // Change this to the actual email from c
        _userPoints = c.jumlahPoin;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atma Kitchen',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromRGBO(240, 240, 240, 240),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: _isLoading
            ? const Center(child: Text("Loading"))
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(_userName), // Tampilkan nama pengguna
                    accountEmail: Row(
                      children: [
                        Text(_userEmail), // Tampilkan email pengguna
                        const SizedBox(width: 8.0),
                        // Points with coin icon
                        Row(
                          children: [
                            Text(
                              '$_userPoints Points', // Tampilkan poin pengguna
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8.0),
                        InkWell(
                          onTap: () {
                            // Add navigation logic to edit profile page
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    currentAccountPicture: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                  ListTile(
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      // Add navigation logic to home page
                    },
                  ),
                  ListTile(
                    title: const Text('History'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Logout'),
                    onTap: () async {
                      await AuthService.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                      );
                    },
                  ),
                ],
              ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(240, 240, 240, 240),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 16.0),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    // Add logic for when the image is clicked
                  },
                  child: Container(
                    height: 200.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://st4.depositphotos.com/1010121/24692/i/450/depositphotos_246923750-stock-photo-one-whole-german-black-forest.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 16.0,
                  left: 16.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi Hari Ini',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        'Black Forest',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const Text(
                      'Our Menu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Menu Items
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMenuItem(
                          'Red Velvet',
                          'Rp. 70.000',
                          'https://img.freepik.com/free-photo/red-velvet-cake-slices-with-yellof-cherry-top-mint-leaves_114579-2593.jpg?t=st=1712044026~exp=1712047626~hmac=95ffc92b21fed5600d087f69210cf3f48aaecdb566fde2e342af1aaa75a8274d&w=360',
                        ),
                        _buildMenuItem(
                          'Chocolate Cake',
                          'Rp. 55.000',
                          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?q=80&w=1989&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ),
                        // Add more menu items as needed
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            // Reviews Carousel
            // You can implement a carousel widget here
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String description, String imageUrl) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      shadows: [
                        Shadow(
                          blurRadius: 7.0,
                          color: Colors.black,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: customerViewPage(),
  ));
}

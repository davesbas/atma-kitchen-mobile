import 'package:flutter/material.dart';
import 'package:atma_kitchen_mobile/view/loginView.dart';
import 'package:atma_kitchen_mobile/model/produk.dart';
import 'package:atma_kitchen_mobile/client/produkClient.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AtmaKitchenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Atma Kitchen',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Color.fromRGBO(240, 240, 240, 240),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 14.0),
                  CircleAvatar(
                    radius: 20.0,
                    child: Icon(Icons.person),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Welcome Guest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Produk>>(
        future: ProdukClient.fetchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available'));
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 240),
              ),
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  SizedBox(height: 16.0),
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
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://st4.depositphotos.com/1010121/24692/i/450/depositphotos_246923750-stock-photo-one-whole-german-black-forest.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
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
                  SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          'Our Menu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return _buildMenuItem(
                              snapshot.data![index].nama,
                              snapshot.data![index].stok.toString(),
                              snapshot.data![index].kuota_produksi.toString(),
                              'Rp. ${snapshot.data![index].harga.toString()}',
                              snapshot.data![index].gambar,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(height: 16.0),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(
      String title, String stock, String quota, String price, String imageUrl) {
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
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Center(child: Icon(Icons.error)),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
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
                    SizedBox(height: 8.0),
                    _buildItemInfo('Stock', stock),
                    _buildItemInfo('Quota', quota),
                    _buildItemInfo('Price', price),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfo(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AtmaKitchenPage(),
  ));
}

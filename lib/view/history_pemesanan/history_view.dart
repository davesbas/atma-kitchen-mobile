import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> dummyOrders = [
    {
      'id': 1,
      'date': '2024-05-01',
      'items': ['Red Velvet Cake', 'Chocolate Cake'],
      'totalPrice': 125000,
      'status': 'Delivered',
    },
    {
      'id': 2,
      'date': '2024-04-25',
      'items': ['Black Forest Cake'],
      'totalPrice': 70000,
      'status': 'Canceled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: ListView.builder(
        itemCount: dummyOrders.length,
        itemBuilder: (context, index) {
          final order = dummyOrders[index];
          return ListTile(
            title: Text('Order #${order['id']}'),
            subtitle: Text('Date: ${order['date']}'),
            trailing: Text('Total: Rp ${order['totalPrice']}'),
            onTap: () {
              _showOrderDetails(context, order);
            },
          );
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order #${order['id']} Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${order['date']}'),
              SizedBox(height: 8),
              Text('Items:'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  order['items'].length,
                  (index) => Text('- ${order['items'][index]}'),
                ),
              ),
              SizedBox(height: 8),
              Text('Total: Rp ${order['totalPrice']}'),
              SizedBox(height: 8),
              Text('Status: ${order['status']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OrderHistoryPage(),
  ));
}

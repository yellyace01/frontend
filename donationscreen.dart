import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DonationsScreen extends StatefulWidget {
  final Function(double) onFundUpdated;

  const DonationsScreen({Key? key, required this.onFundUpdated})
      : super(key: key);

  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  List<Map<String, dynamic>> donations = [];
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    try {
      final response =
          await http.get(Uri.parse('https://backend-s4rm.onrender.com/get-donations'));
      if (response.statusCode == 200) {
        setState(() {
          donations =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load donations');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addDonation(String description, double amount) async {
    final response = await http.post(
      Uri.parse('https://backend-s4rm.onrender.com/add-donation'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'description': description,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      widget.onFundUpdated(amount); // Update total fund in the dashboard
      _fetchDonations(); // Refresh the list
    }
  }

  Future<void> _deleteDonation(int id) async {
    final response = await http
        .delete(Uri.parse('https://backend-s4rm.onrender.com/delete-donation/$id'));
    if (response.statusCode == 200) {
      _fetchDonations(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Donations Screen'),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/PlainBG.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      onPressed: () {
                        String description = descriptionController.text;
                        double amount =
                            double.tryParse(amountController.text) ?? 0.0;
                        if (amount > 0) {
                          _addDonation(description, amount);
                          descriptionController.clear();
                          amountController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please enter a valid amount.')),
                          );
                        }
                      },
                      child: Text('Add Donation'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                height: screenHeight * 0.5,
                child: ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          donations[index]['description'],
                          style: TextStyle(fontSize: 18.0),
                        ),
                        subtitle: Text(
                          'Amount: ₱${donations[index]['amount'].toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              _deleteDonation(donations[index]['id']),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

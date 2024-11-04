import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'donationscreen.dart';
import 'projectscreen.dart';
import 'budgetscreen.dart';

class FinancialDashboard extends StatefulWidget {
  @override
  _FinancialDashboardState createState() => _FinancialDashboardState();
}

class _FinancialDashboardState extends State<FinancialDashboard> {
  double totalFund = 0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final response =
          await http.get(Uri.parse('https://backend-s4rm.onrender.com/get-transactions'));
      if (response.statusCode == 200) {
        setState(() {
          transactions =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('https://backend-s4rm.onrender.com/delete-transaction/$id'));
      if (response.statusCode == 200) {
        setState(() {
          transactions.removeWhere((transaction) => transaction['id'] == id);
        });
      } else {
        throw Exception('Failed to delete transaction');
      }
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      _fetchTransactions();
    });
  }

  void _updateTotalFund(double fundChange) {
    setState(() {
      totalFund += fundChange;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Financial Dashboard"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/PlainBG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Total Fund: ₱${totalFund.toStringAsFixed(2)}",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _navigateToPage(
                            DonationsScreen(onFundUpdated: _updateTotalFund)),
                        child: Text("Donations"),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToPage(ProjectsScreen()),
                        child: Text("Projects"),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToPage(
                            BudgetScreen(onFundUpdated: _updateTotalFund)),
                        child: Text("Budget"),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "Transaction History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: screenHeight * 0.5,
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              transactions[index]['description'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Type: ${transactions[index]['type']}\nAmount: ₱${transactions[index]['amount'].toStringAsFixed(2)}",
                              style: TextStyle(color: Colors.black54),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete Transaction"),
                                      content: Text(
                                          "Are you sure you want to delete this transaction?"),
                                      actions: [
                                        TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text("Delete"),
                                          onPressed: () async {
                                            await _deleteTransaction(
                                                transactions[index]['id']);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
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
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BudgetScreen extends StatefulWidget {
  final Function(double) onFundUpdated;

  BudgetScreen({required this.onFundUpdated});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Map<String, dynamic>> budgets = [];
  double totalFund = 0;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    try {
      final response =
          await http.get(Uri.parse('https://backend-s4rm.onrender.com/get-budgets'));
      if (response.statusCode == 200) {
        setState(() {
          budgets = List<Map<String, dynamic>>.from(json.decode(response.body));
          totalFund = budgets.fold(0, (sum, item) => sum + item['amount']);
          widget.onFundUpdated(totalFund); // Update total fund in the dashboard
        });
      } else {
        throw Exception('Failed to load budgets');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addBudget() async {
    final String description = descriptionController.text;
    final double amount = double.tryParse(amountController.text) ?? 0.0;

    if (description.isNotEmpty && amount > 0) {
      final response = await http.post(
        Uri.parse('https://backend-s4rm.onrender.com/add-budget'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'description': description,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        _fetchBudgets(); // Refresh the list
        descriptionController.clear();
        amountController.clear();
        _showSnackBar("Budget successfully added!");
      } else {
        _showSnackBar("Failed to add budget.");
      }
    } else {
      _showSnackBar("Please enter a valid description and amount.");
    }
  }

  Future<void> _deleteBudget(int id) async {
    final response =
        await http.delete(Uri.parse('https://backend-s4rm.onrender.com/delete-budget/$id'));
    if (response.statusCode == 200) {
      _fetchBudgets(); // Refresh the list
      _showSnackBar("Budget successfully deleted!");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Screen'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/PlainBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Enable scrolling
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addBudget,
                      child: Text('Add Budget'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ListView.builder(
                itemCount: budgets.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(budgets[index]['description']),
                      subtitle: Text(
                          'Amount: ₱${budgets[index]['amount'].toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteBudget(budgets[index]['id']),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

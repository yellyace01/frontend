import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApprovalScreen extends StatefulWidget {
  @override
  _ApprovalScreenState createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  List<Map<String, dynamic>> requests = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchApprovalRequests();
  }

  Future<void> fetchApprovalRequests() async {
    final response =
        await http.get(Uri.parse('https://backend-s4rm.onrender.com/api/requests'));
    if (response.statusCode == 200) {
      setState(() {
        requests = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load requests');
    }
  }

  Future<void> updateRequestStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('https://backend-s4rm.onrender.com/api/requests/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      fetchApprovalRequests(); // Refresh the list
    } else {
      throw Exception('Failed to update status');
    }
  }

  Future<void> deleteRequest(int id) async {
    final response = await http.delete(
      Uri.parse('https://backend-s4rm.onrender.com/api/requests/$id'),
    );

    if (response.statusCode == 200) {
      fetchApprovalRequests(); // Refresh the list
    } else {
      throw Exception('Failed to delete request');
    }
  }

  void _filterRequests(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRequests = requests.where((request) {
      return request['name']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          request['documentType']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          request['reason'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Approval Screen"),
        actions: [
          Container(
            width: 200,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              onChanged: _filterRequests,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/PlainBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.all(16),
            child: DataTable(
              columns: [
                DataColumn(label: Text('Document Type')),
                DataColumn(label: Text('Reason')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Purok')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: filteredRequests.map((request) {
                return DataRow(cells: [
                  DataCell(Text(request['documentType'] ?? '')),
                  DataCell(Text(request['reason'] ?? '')),
                  DataCell(Text(request['name'] ?? '')),
                  DataCell(Text(request['purok'].toString())),
                  DataCell(Text(request['status'] ?? '')),
                  DataCell(
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              updateRequestStatus(request['id'], 'Approved'),
                          child: Text("Approve"),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              updateRequestStatus(request['id'], 'Rejected'),
                          child: Text("Reject"),
                        ),
                        ElevatedButton(
                          onPressed: () => deleteRequest(request['id']),
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

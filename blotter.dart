import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BlotterReportScreen extends StatefulWidget {
  @override
  _BlotterReportScreenState createState() => _BlotterReportScreenState();
}

class _BlotterReportScreenState extends State<BlotterReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _complainantName, _respondentName, _details;
  List<dynamic> _blotterReports = [];
  List<dynamic> _filteredReports = [];
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBlotterReports();
  }

  Future<void> _submitBlotterReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse('https://backend-s4rm.onrender.com/blotter_report'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'complainant_name': _complainantName,
          'respondent_name': _respondentName,
          'details': _details,
          'date_reported': formattedDate,
          'status': 'pending', // Default status
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blotter report submitted successfully!')),
        );
        _fetchBlotterReports();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report.')),
        );
      }
    }
  }

  Future<void> _deleteReport(String id) async {
    final response = await http.delete(
      Uri.parse('https://backend-s4rm.onrender.com/blotter_report/$id'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report deleted successfully!')),
      );
      _fetchBlotterReports();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete report.')),
      );
    }
  }

  Future<void> _fetchBlotterReports() async {
    final response =
        await http.get(Uri.parse('https://backend-s4rm.onrender.com/blotter_reports'));
    if (response.statusCode == 200) {
      setState(() {
        _blotterReports = json.decode(response.body);
        _filteredReports = _blotterReports;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reports.')),
      );
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    final response = await http.patch(
      Uri.parse('https://backend-s4rm.onrender.com/blotter_report/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated successfully!')),
      );
      _fetchBlotterReports();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status.')),
      );
    }
  }

  void _filterReports(String query) {
    setState(() {
      _searchQuery = query;
      _filteredReports = _blotterReports.where((report) {
        final complainantName = report['complainant_name'].toLowerCase();
        final respondentName = report['respondent_name'].toLowerCase();
        final details = report['details'].toLowerCase();
        final searchLower = query.toLowerCase();
        return complainantName.contains(searchLower) ||
            respondentName.contains(searchLower) ||
            details.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Barangay Blotter Report'),
        actions: [
          Container(
            width: isSmallScreen ? 100 : 200,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              onChanged: _filterReports,
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/PlainBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Complainant Name'),
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter complainant name'
                                  : null,
                              onSaved: (value) => _complainantName = value,
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Respondent Name'),
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter respondent name'
                                  : null,
                              onSaved: (value) => _respondentName = value,
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Details'),
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter details'
                                  : null,
                              onSaved: (value) => _details = value,
                            ),
                            SizedBox(height: 20),
                            Center(
                                child: ElevatedButton(
                              onPressed: _submitBlotterReport,
                              child: Text('Submit Report'),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Submitted Blotter Reports (${_filteredReports.length}):',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: isSmallScreen ? 300 : 500,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: _filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = _filteredReports[index];
                        final isResolved = report['status'] == 'resolved';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(report['complainant_name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Respondent: ${report['respondent_name']}'),
                                Text('Details: ${report['details']}'),
                                Text('Date: ${report['date_reported']}'),
                                Text('Status: ${report['status']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: isResolved,
                                  onChanged: (bool? value) {
                                    _updateStatus(
                                        report['id'].toString(),
                                        value! ? 'resolved' : 'pending');
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteReport(
                                      report['id'].toString()),
                                ),
                              ],
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
        ),
      ),
    );
  }
}

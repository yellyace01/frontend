import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnnouncementScreen extends StatefulWidget {
  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;
  String? errorMessage; // Error message for displaying

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      // Update this to your correct API URL
      final response =
          await http.get(Uri.parse('https://backend-s4rm.onrender.com/api/requests'));

      if (response.statusCode == 200) {
        setState(() {
          announcements =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load announcements';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Document Status"),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/PlainBG.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? CircularProgressIndicator()
                : errorMessage != null
                    ? Text(errorMessage!, style: TextStyle(color: Colors.red))
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: [
                              DataColumn(
                                  label: Text('Document Type',
                                      style: TextStyle(fontSize: 18.0))),
                              DataColumn(
                                  label: Text('Reason',
                                      style: TextStyle(fontSize: 18.0))),
                              DataColumn(
                                  label: Text('Name',
                                      style: TextStyle(fontSize: 18.0))),
                              DataColumn(
                                  label: Text('Purok',
                                      style: TextStyle(fontSize: 18.0))),
                              DataColumn(
                                  label: Text('Status',
                                      style: TextStyle(fontSize: 18.0))),
                            ],
                            rows: announcements.map((announcement) {
                              return DataRow(cells: [
                                DataCell(Text(
                                    announcement['documentType'] ?? '',
                                    style: TextStyle(fontSize: 16.0))),
                                DataCell(Text(announcement['reason'] ?? '',
                                    style: TextStyle(fontSize: 16.0))),
                                DataCell(Text(announcement['name'] ?? '',
                                    style: TextStyle(fontSize: 16.0))),
                                DataCell(Text(announcement['purok'].toString(),
                                    style: TextStyle(fontSize: 16.0))),
                                DataCell(Text(announcement['status'] ?? '',
                                    style: TextStyle(fontSize: 16.0))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

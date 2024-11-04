import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestDocumentScreen extends StatefulWidget {
  @override
  _RequestDocumentScreenState createState() => _RequestDocumentScreenState();
}

class _RequestDocumentScreenState extends State<RequestDocumentScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedDocumentType;
  int? _selectedPurok;

  final List<String> _documentTypes = [
    'Certificate of Residency',
    'Business Permit',
    'Barangay Clearance',
    'Indigency Certificate',
    'Cedula',
  ];

  final List<int> _purokList = List.generate(6, (index) => index + 1);

  Future<void> submitRequest() async {
    if (_selectedDocumentType == null ||
        _reasonController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _selectedPurok == null ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields.'),
      ));
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/request'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'documentType': _selectedDocumentType,
        'reason': _reasonController.text,
        'name': _nameController.text,
        'purok': _selectedPurok.toString(),
        'address': _addressController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Request submitted successfully!'),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit request.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('Request Document'),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    DropdownButtonFormField<int>(
                      value: _selectedPurok,
                      decoration: InputDecoration(labelText: 'Select Purok'),
                      items: _purokList.map((int purok) {
                        return DropdownMenuItem<int>(
                          value: purok,
                          child: Text('Purok $purok'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedPurok = newValue;
                        });
                      },
                      hint: Text('Select Purok'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedDocumentType,
                      decoration:
                          InputDecoration(labelText: 'Type of Document'),
                      items: _documentTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDocumentType = newValue;
                        });
                      },
                      hint: Text('Select Document Type'),
                    ),
                    TextField(
                      controller: _reasonController,
                      decoration:
                          InputDecoration(labelText: 'Reason for Request'),
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Address'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: submitRequest,
                      child: Text('Submit Request'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

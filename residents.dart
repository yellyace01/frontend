import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResidentsScreen extends StatefulWidget {
  @override
  _ResidentsScreenState createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName, _lastName, _address, _contactNumber;
  DateTime? _birthdate;
  List<dynamic> _residents = [];
  List<dynamic> _filteredResidents = [];
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchResidents();
  }

  Future<void> _fetchResidents() async {
    final response =
        await http.get(Uri.parse('https://backend-s4rm.onrender.com/residents'));
    if (response.statusCode == 200) {
      setState(() {
        _residents = json.decode(response.body);
        _filteredResidents = _residents;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load residents.')),
      );
    }
  }

  Future<void> _submitResident() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final response = await http.post(
        Uri.parse('https://backend-s4rm.onrender.com/residents'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'first_name': _firstName,
          'last_name': _lastName,
          'address': _address,
          'birthdate': _birthdate!.toLocal().toString().split(' ')[0],
          'contact_number': _contactNumber,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resident added successfully!')),
        );
        _fetchResidents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add resident.')),
        );
      }
    }
  }

  Future<void> _deleteResident(int id) async {
    final response = await http.delete(
      Uri.parse('https://backend-s4rm.onrender.com/residents/$id'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resident deleted successfully!')),
      );
      _fetchResidents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete resident.')),
      );
    }
  }

  void _filterResidents(String query) {
    setState(() {
      _searchQuery = query;
      _filteredResidents = _residents.where((resident) {
        final fullName = '${resident['first_name']} ${resident['last_name']}';
        return fullName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Residents'),
        actions: [
          Container(
            width: 200,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              onChanged: _filterResidents,
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
                                InputDecoration(labelText: 'First Name'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter first name'
                                : null,
                            onSaved: (value) => _firstName = value,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Last Name'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter last name'
                                : null,
                            onSaved: (value) => _lastName = value,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Address'),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter address' : null,
                            onSaved: (value) => _address = value,
                          ),
                          TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Birthdate',
                              hintText: _birthdate == null
                                  ? 'Select Date'
                                  : "${_birthdate!.toLocal()}".split(' ')[0],
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _birthdate ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null &&
                                  pickedDate != _birthdate) {
                                setState(() {
                                  _birthdate = pickedDate;
                                });
                              }
                            },
                          ),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Contact Number'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter contact number'
                                : null,
                            onSaved: (value) => _contactNumber = value,
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitResident,
                              child: Text('Add Resident'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min,
                    children: [
                      Text(
                        'Residents',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' (${_filteredResidents.length})',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
                    itemCount: _filteredResidents.length,
                    itemBuilder: (context, index) {
                      final resident = _filteredResidents[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                              '${resident['first_name']} ${resident['last_name']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Address: ${resident['address']}'),
                              Text('Birthdate: ${resident['birthdate']}'),
                              Text('Contact: ${resident['contact_number']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                _deleteResident(resident['resident_id']),
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
    );
  }
}

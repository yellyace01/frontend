import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectsScreen extends StatefulWidget {
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<dynamic> projects = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final response =
        await http.get(Uri.parse('https://backend-s4rm.onrender.com/projects'));

    if (response.statusCode == 200) {
      setState(() {
        projects = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<void> addProject() async {
    final response = await http.post(
      Uri.parse('https://backend-s4rm.onrender.com/projects'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'name': nameController.text,
        'description': descriptionController.text,
      }),
    );

    if (response.statusCode == 200) {
      nameController.clear();
      descriptionController.clear();
      fetchProjects();
      _showSnackBar("Project successfully added!");
    } else {
      throw Exception('Failed to add project');
    }
  }

  Future<void> deleteProject(int id) async {
    final response =
        await http.delete(Uri.parse('https://backend-s4rm.onrender.com/projects/$id'));

    if (response.statusCode == 200) {
      fetchProjects();
      _showSnackBar("Project successfully deleted!");
    } else {
      throw Exception('Failed to delete project');
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
        title: Text("Projects"),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Project Name'),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        addProject();
                      },
                      child: Text('Add Project'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true, // Important for ListView inside a Column
                physics:
                    NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        project['name'],
                        style: TextStyle(fontSize: 18.0),
                      ),
                      subtitle: Text(
                        'Description: ${project['description']}\nDate: ${project['date']}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteProject(project['id']);
                        },
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

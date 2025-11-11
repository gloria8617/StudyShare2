import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = 'https://nl5ekmyl0h.execute-api.eu-north-1.amazonaws.com/poskus';
const String apiKey = 'm7KR0SCFnW1ybUdFJ4Sg08UGHaWwcVZh3Y64kBrU';

void main() {
  runApp(StudyShareApp());
}

class StudyShareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyShare',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: SchoolSelectionPage(),
    );
  }
}

class SchoolSelectionPage extends StatefulWidget {
  @override
  _SchoolSelectionPageState createState() => _SchoolSelectionPageState();
}

class _SchoolSelectionPageState extends State<SchoolSelectionPage> {
  List<String> schools = [];

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  void fetchSchools() async {
    final response = await http.get(
      Uri.parse('$apiUrl/schools'),
      headers: {'x-api-key': apiKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        schools = data.map((item) => item['Ime_ustanove'].toString()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Izberi šolo')),
      body: ListView.builder(
        itemCount: schools.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(schools[index]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProgramSelectionPage(school: schools[index]),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgramSelectionPage extends StatefulWidget {
  final String school;
  ProgramSelectionPage({required this.school});

  @override
  _ProgramSelectionPageState createState() => _ProgramSelectionPageState();
}

class _ProgramSelectionPageState extends State<ProgramSelectionPage> {
  List<String> programs = [];

  @override
  void initState() {
    super.initState();
    fetchPrograms();
  }

  void fetchPrograms() async {
    final response = await http.get(
      Uri.parse('$apiUrl/programs?school=${Uri.encodeComponent(widget.school)}'),
      headers: {'x-api-key': apiKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        programs = data.map((item) => item['Ime_programa'].toString()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Izberi program')),
      body: ListView.builder(
        itemCount: programs.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(programs[index]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YearSelectionPage(
                school: widget.school,
                program: programs[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class YearSelectionPage extends StatelessWidget {
  final String school;
  final String program;
  final List<int> years = [1, 2];

  YearSelectionPage({required this.school, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Izberi letnik')),
      body: ListView.builder(
        itemCount: years.length,
        itemBuilder: (context, index) => ListTile(
          title: Text('${years[index]}. letnik'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectPage(
                school: school,
                program: program,
                year: years[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectPage extends StatefulWidget {
  final String school;
  final String program;
  final int year;

  SubjectPage({required this.school, required this.program, required this.year});

  @override
  _SubjectPageState createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  List<String> subjects = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  void fetchSubjects() async {
    final response = await http.get(
      Uri.parse('$apiUrl/subjects?school=${Uri.encodeComponent(widget.school)}&program=${Uri.encodeComponent(widget.program)}&year=${widget.year}'),
      headers: {'x-api-key': apiKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        subjects = data.map((item) => item['Ime_predmeta'].toString()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = subjects.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.program} - ${widget.year}. letnik')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(labelText: 'Išči predmet'),
              onChanged: (val) => setState(() => query = val),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('Ni predmetov za prikaz'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(filtered[index]),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Odprl bi zapiske za ${filtered[index]}')),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

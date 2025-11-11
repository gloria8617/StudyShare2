import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ This fixes your error
import 'package:file_picker/file_picker.dart'; // You will need this
import 'package:open_file/open_file.dart'; // You will also need this
import 'dart:convert'; // And this one

void main() async {
  // Ensure Flutter bindings are initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences to check user's login/onboarding status
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final bool isOnboardingComplete = prefs.getBool('isOnboardingComplete') ?? false;

  // Determine the starting page based on saved status
  String initialRoute = '/'; // Default route is SignIn
  if (isLoggedIn) {
    // If logged in, check if they finished onboarding
    initialRoute = isOnboardingComplete ? '/main' : '/onboarding';
  }

  runApp(StudyShareApp(initialRoute: initialRoute));
}

class StudyShareApp extends StatelessWidget {
  // Receive the initial route from main()
  final String initialRoute;
  const StudyShareApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyShare',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set the initial route dynamically
      initialRoute: initialRoute,
      // Define all app routes
      routes: {
        '/': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/forgot': (context) => ForgotPasswordPage(),
        '/onboarding': (context) => OnboardingPage(), // New Onboarding page
        '/main': (context) => MainPage(),
        // New routes for viewing and adding materials
        '/subject_materials': (context) => SubjectMaterialsPage(
              subjectName: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/add_material': (context) => AddMaterialPage(
              subjectName: ModalRoute.of(context)!.settings.arguments as String,
            ),
      },
    );
  }
}

// --- Authentication Pages ---

class SignInPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Mock sign-in function
  void signIn(BuildContext context) async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      // Save login state to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      // Mock saving user data
      await prefs.setString('email', emailController.text);

      // Check if onboarding is complete
      final bool isOnboardingComplete = prefs.getBool('isOnboardingComplete') ?? false;

      // Navigate based on onboarding status
      if (isOnboardingComplete) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vnesi podatke')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prijava')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Gmail')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Geslo'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => signIn(context), child: Text('Prijavi se')),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: Text('Ustvari račun')),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/forgot'), child: Text('Pozabljeno geslo?')),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  // Removed school, program, and year controllers. This is handled in Onboarding.

  // Mock sign-up function
  void signUp(BuildContext context) async {
    if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
      // Save login state and user data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('name', nameController.text);
      await prefs.setString('email', emailController.text);
      // Mark onboarding as incomplete
      await prefs.setBool('isOnboardingComplete', false);

      // Navigate to the onboarding flow
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Izpolni vsa polja')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registracija')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Ime')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => signUp(context), child: Text('Registriraj se')),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  final emailController = TextEditingController();

  // Mock password reset
  void resetPassword(BuildContext context) {
    if (emailController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Povezava za ponastavitev gesla poslana.')));
      Navigator.pop(context); // Go back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vnesi email')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pozabljeno geslo')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Vnesi Gmail')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => resetPassword(context), child: Text('Pošlji povezavo')),
          ],
        ),
      ),
    );
  }
}

// --- Onboarding Flow ---

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Form key to validate dropdowns
  final _formKey = GlobalKey<FormState>();

  // Mock data for dropdowns
  final schools = ['Gimnazija Maribor', 'Srednja elektro šola', 'Višja šola L.I.V.E.'];
  final programs = ['Računalništvo in informatika', 'Ekonomist', 'Varstvo okolja', 'Logistično inženirstvo'];
  final years = ['1. letnik', '2. letnik', '3. letnik', '4. letnik'];

  // State variables to hold selected values
  String? _selectedSchool;
  String? _selectedProgram;
  String? _selectedYear;

  // Save onboarding data to SharedPreferences
  void _saveOnboarding() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form values

      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Store selected data
      await prefs.setString('school', _selectedSchool!);
      await prefs.setString('program', _selectedProgram!);
      await prefs.setString('year', _selectedYear!);
      // Mark onboarding as complete
      await prefs.setBool('isOnboardingComplete', true);

      // Navigate to the main app
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dopolni svoj profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // School Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSchool,
                hint: Text('Izberi šolo'),
                items: schools.map((school) {
                  return DropdownMenuItem(value: school, child: Text(school));
                }).toList(),
                onChanged: (value) => setState(() => _selectedSchool = value),
                validator: (value) => value == null ? 'Prosim, izberi šolo' : null,
              ),
              SizedBox(height: 16),

              // Program Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedProgram,
                hint: Text('Izberi program'),
                items: programs.map((program) {
                  return DropdownMenuItem(value: program, child: Text(program));
                }).toList(),
                onChanged: (value) => setState(() => _selectedProgram = value),
                validator: (value) => value == null ? 'Prosim, izberi program' : null,
              ),
              SizedBox(height: 16),

              // Year Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedYear,
                hint: Text('Izberi letnik'),
                items: years.map((year) {
                  return DropdownMenuItem(value: year, child: Text(year));
                }).toList(),
                onChanged: (value) => setState(() => _selectedYear = value),
                validator: (value) => value == null ? 'Prosim, izberi letnik' : null,
              ),
              SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveOnboarding,
                child: Text('Shrani in nadaljuj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Main App Pages ---

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Mock list of subjects
  final subjects = ['Matematika', 'Programiranje', 'Fizika', 'Zgodovina', 'Angleščina', 'Okoljevarstvo'];
  String query = ''; // Current search query

  // Logic to filter subjects based on the query
  List<String> getFilteredSubjects() {
    if (query.isEmpty) {
      return subjects; // Return all if query is empty
    }
    return subjects.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredSubjects(); // Get the filtered list

    return Scaffold(
      appBar: AppBar(title: Text('Predmeti')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Išči predmet',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => setState(() => query = val),
            ),
          ),
          // List of filtered subjects
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filtered[index]),
                  leading: Icon(Icons.book),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to the materials page for the selected subject
                    Navigator.pushNamed(
                      context,
                      '/subject_materials',
                      arguments: filtered[index], // Pass the subject name
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Page to browse materials for a specific subject
class SubjectMaterialsPage extends StatefulWidget {
  final String subjectName;
  const SubjectMaterialsPage({super.key, required this.subjectName});

  @override
  _SubjectMaterialsPageState createState() => _SubjectMaterialsPageState();
}

class _SubjectMaterialsPageState extends State<SubjectMaterialsPage> {
  // State list to hold materials
  List<Map<String, dynamic>> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials(); // Load materials when the page opens
  }

  // Load materials from SharedPreferences
  Future<void> _loadMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the JSON string, default to '[]' if null
    final String materialsString = prefs.getString('materials') ?? '[]';
    // Decode the JSON string into a List
    final List<dynamic> allMaterials = jsonDecode(materialsString);

    // Filter the list for the current subject
    setState(() {
      _materials = allMaterials
          .cast<Map<String, dynamic>>()
          .where((m) => m['subject'] == widget.subjectName)
          .toList();
    });
  }

  // Function to open a file using the open_file package
  Future<void> _openFile(String path) async {
    final result = await OpenFile.open(path);
    if (result.type != ResultType.done) {
      // Handle error (e.g., no app to open file)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Napaka pri odpiranju datoteke: ${result.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectName)), // Show subject name in app bar
      body: _materials.isEmpty
          ? Center(child: Text('Za ta predmet še ni gradiv.')) // Show message if empty
          : ListView.builder(
              itemCount: _materials.length,
              itemBuilder: (context, index) {
                final material = _materials[index];
                return ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text(material['title']), // File name
                  subtitle: Text(material['path']), // File path
                  onTap: () => _openFile(material['path']), // Open file on tap
                );
              },
            ),
      // Floating action button to add new material
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigate to AddMaterialPage and pass the subject name
          Navigator.pushNamed(
            context,
            '/add_material',
            arguments: widget.subjectName,
          ).then((_) {
            // After returning from AddMaterialPage, reload the list
            _loadMaterials();
          });
        },
      ),
    );
  }
}

// Page to add new material with file upload
class AddMaterialPage extends StatefulWidget {
  final String subjectName;
  const AddMaterialPage({super.key, required this.subjectName});

  @override
  _AddMaterialPageState createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage> {
  PlatformFile? _pickedFile; // Holds the file picked by the user

  // Function to pick a file
  Future<void> _pickFile() async {
    // Use FilePicker to select a file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // Define allowed file extensions
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'],
    );

    if (result != null) {
      // If a file is picked, update the state
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  // Function to save the material to mock storage
  Future<void> _saveMaterial() async {
    if (_pickedFile == null) {
      // Show error if no file is selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Prosim, izberi datoteko.')));
      return;
    }

    // Get SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Get existing materials list
    final String materialsString = prefs.getString('materials') ?? '[]';
    final List<dynamic> allMaterials = jsonDecode(materialsString);

    // Create a new material entry
    final newMaterial = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
      'subject': widget.subjectName,
      'title': _pickedFile!.name,
      'path': _pickedFile!.path!, // This is the file path on the device
    };

    // Add new material to the list
    allMaterials.add(newMaterial);

    // Save the updated list back to SharedPreferences
    await prefs.setString('materials', jsonEncode(allMaterials));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gradivo shranjeno!')));
    // Go back to the previous page
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj gradivo za ${widget.subjectName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Button to trigger file picker
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Izberi datoteko'),
            ),
            SizedBox(height: 16),
            // Show the name of the selected file
            Text(
              'Izbrano: ${_pickedFile?.name ?? 'Nobena datoteka'}',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            // Button to save the material
            ElevatedButton(
              onPressed: _saveMaterial,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink, // Theme color
                foregroundColor: Colors.white,
              ),
              child: Text('Shrani gradivo'),
            ),
          ],
        ),
      ),
    );
  }
}
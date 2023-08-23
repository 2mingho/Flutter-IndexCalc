import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Índice Académico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light, // Modo claro por defecto
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Modo oscuro
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class Course {
  final String name;
  final int credits;
  final String grade;

  Course({required this.name, required this.credits, required this.grade});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Course> _courses = [];
  double _calculatedIndex = 0.0;

  String _currentGrade = 'A'; // Valor por defecto
  String _currentCourseName = '';
  int _currentCredits = 0;

  final List<int> _creditOptions = [0, 1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de Índice Académico'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Modificar el color de fondo en función del modo activo
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ...
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre de la materia',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _currentCourseName = value;
                  });
                },
                initialValue: _currentCourseName,
              ),
              DropdownButton<String>(
                value: _currentGrade,
                onChanged: (String? newValue) {
                  setState(() {
                    _currentGrade = newValue!;
                  });
                },
                items: <String>['A', 'B', 'C', 'R', 'F']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        )),
                  );
                }).toList(),
              ),
              DropdownButton<int>(
                value: _currentCredits,
                onChanged: _currentCourseName.isNotEmpty || _currentCredits == 0
                    ? (int? newValue) {
                        setState(() {
                          _currentCredits = newValue!;
                        });
                      }
                    : null,
                items: _creditOptions.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value == 0 ? '0' : value.toString()),
                  );
                }).toList(),
                hint: Text(
                  _currentCredits == 0
                      ? 'Créditos'
                      : '$_currentCredits créditos',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _canAddCourse() ? _addCourse : null,
                child: const Text('Agregar Materia'),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Materia')),
                    DataColumn(label: Text('Literal')),
                    DataColumn(label: Text('Creds')),
                    DataColumn(label: Text('')),
                  ],
                  columnSpacing: 24.0,
                  rows: _courses.map((course) {
                    Color color;
                    if (course.grade == 'A') {
                      color = Colors.green;
                    } else if (course.grade == 'B') {
                      color = Colors.blue;
                    } else if (course.grade == 'C') {
                      color = Colors.yellow;
                    } else if (course.grade == 'F') {
                      color = Colors.red;
                    } else {
                      color = Colors.black;
                    }

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(course.name, style: TextStyle(color: color)),
                        ),
                        DataCell(
                          Text(course.grade, style: TextStyle(color: color)),
                        ),
                        DataCell(
                          Text(course.credits.toString(),
                              style: TextStyle(color: color)),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _courses.remove(course);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: _courses.isNotEmpty
                    ? () => _calculateIndex(_courses)
                    : null,
                child: const Text('Calcular Índice'),
              ),
              Text(
                'Índice Calculado: ${_calculatedIndex.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reset,
        child: const Icon(Icons.restore),
      ),
    );
  }

  bool _canAddCourse() {
    return _currentCourseName.isNotEmpty &&
        (_currentCredits == 0 || _currentCredits > 0);
  }

  void _addCourse() {
    // Verificar si ya existe una materia con el mismo nombre
    if (_courses.any((course) => course.name == _currentCourseName)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Ya existe una materia con ese nombre.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _courses.add(Course(
          name: _currentCourseName,
          credits: _currentCredits,
          grade: _currentGrade,
        ));
        // Limpiar los campos después de agregar la materia
        _currentCourseName = '';
        _currentGrade = 'A';
        _currentCredits = 0;
      });
    }
  }

  void _calculateIndex(List<Course> courses) {
    int totalCredits = 0;
    double totalScore = 0.0;

    for (var course in courses) {
      if (course.grade == 'A') {
        totalScore += 4.0 * course.credits;
        totalCredits += course.credits;
      } else if (course.grade == 'B') {
        totalScore += 3.0 * course.credits;
        totalCredits += course.credits;
      } else if (course.grade == 'C') {
        totalScore += 2.0 * course.credits;
        totalCredits += course.credits;
      } else if (course.grade == 'F') {
        totalCredits += course.credits;
      }
    }

    if (totalCredits > 0) {
      setState(() {
        _calculatedIndex = totalScore / totalCredits;
      });
    } else {
      setState(() {
        _calculatedIndex = 0.0;
      });
    }
  }

  void _reset() {
    setState(() {
      _currentCourseName = '';
      _currentGrade = 'A';
      _currentCredits = 0;
      _courses.clear();
      _calculatedIndex = 0.0;
    });
  }
}

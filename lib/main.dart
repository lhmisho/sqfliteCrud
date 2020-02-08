import 'package:flutter/material.dart';
import './dbmanager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StudentDbManager dbmanager = new StudentDbManager();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  List<Student> studentList;
  Student student;
  int updateIndex;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sql flite demo'),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: new InputDecoration(labelText: 'name'),
                    controller: _nameController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Name must not be empty',
                  ),
                  TextFormField(
                    decoration: new InputDecoration(labelText: 'course'),
                    controller: _courseController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'course must not be empty',
                  ),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.blueAccent,
                    child: Container(
                        width: width * 0.9,
                        child: Text(
                          'Submit',
                          textAlign: TextAlign.center,
                        )),
                    onPressed: () {
                      _submitStudent(context);
                    },
                  ),
                  FutureBuilder(
                    future: dbmanager.getStudents(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        studentList = snapshot.data;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              studentList == null ? 0 : studentList.length,
                          itemBuilder: (BuildContext context, int index) {
                            Student st = studentList[index];
                            return Card(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: width * 0.6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Name: ${st.name}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          'Course: ${st.course}',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _nameController.text = st.name;
                                      _courseController.text = st.course;
                                      student = st;
                                      updateIndex = index;
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      dbmanager.deleteStudent(st.id);
                                      setState(() {
                                        studentList.removeAt(index);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return new CircularProgressIndicator();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitStudent(BuildContext context) {
    if(_formKey.currentState.validate()){
      if(student==null) {
        Student st = new Student(name: _nameController.text, course: _courseController.text);
        dbmanager.insertStudent(st).then((id)=>{
          _nameController.clear(),
          _courseController.clear(),
          setState((){
            studentList.add(st);
          }),
          print('Student Added to Db ${id}')
        });
      } else {
        student.name = _nameController.text;
        student.course = _courseController.text;

        dbmanager.updateStudent(student).then((id) =>{
          setState((){
            studentList[updateIndex].name = _nameController.text;
            studentList[updateIndex].course= _courseController.text;
          }),
          _nameController.clear(),
          _courseController.clear(),
          student=null
        });
      }
    }
  }
}

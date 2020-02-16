
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trips/models/add_trip_form.dart';


class AddTrip extends StatefulWidget
{
  static final String route = "/addTrip";
  _AddTripState createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip>
{
  final databaseReference = Firestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  AddTripFormData _addTripData = AddTripFormData();
  BuildContext _scaffoldContext;
  File _image;

  Future getWallPaperImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      _addTripData.wallpaperUrl = _image.path.split('/').last;
      print('${_image.path}');
    });
  }

  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Trip'),
      ),
      body: Builder(
        builder: (context)
        {
          _scaffoldContext = context;
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    style: Theme.of(context).textTheme.headline5,
                    decoration: InputDecoration(
                      hintText: 'City',
                    ),
                    onSaved: (value) => _addTripData.city = value,
                  ),
                  TextFormField(
                    style: Theme.of(context).textTheme.headline5,
                    decoration: InputDecoration(
                      hintText: 'Country',
                    ),
                    onSaved: (value) => _addTripData.country = value,
                  ),
                  // TextFormField(
                  //   decoration: InputDecoration(
                  //     hintText: 'Trip wallpaper',
                  //   ),
                  //   onSaved: (value) => _addTripData.destinationImgUrl = value,
                  // ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Short Description',
                    ),
                    onSaved: (value) => _addTripData.description = value,
                  ),
                  _DatePicker(onDateChanged: _handleDateChanged),
                  RaisedButton(
                    onPressed: getWallPaperImage,
                    child: _image == null ? Text('Select image') :
                    Container(
                      child: Image.file(_image),
                    ),
                  ),
                  _buildSubmitBtn(),
                ],
              ),
            ),
          );
        },
      )
    );
  }

  _handleDateChanged(DateTime selectedDate)
  {
    _addTripData.visitedDate = Timestamp.fromDate(selectedDate);
  }

  void _handleSuccess(data)
  {
    // Navigator
    //     .pushNamedAndRemoveUntil(context, '/', 
    //                             (Route<dynamic> route) => false, 
    //                             arguments: HomeScreen()
    //                             );
    Navigator.pop(context);
  }

  void _handleError(response)
  {
    Scaffold.of(_scaffoldContext).showSnackBar(SnackBar(
        content: Text(response['errors']['message'])
      ));
  }

  void _register() async
  {
    databaseReference.collection('Destinations').add({'city': _addTripData.city, 'country': _addTripData.country, 'description': _addTripData.description, 'visitedDate': _addTripData.visitedDate, 'wallpaperUrl' : _addTripData.wallpaperUrl},);
    StorageReference cityReference = FirebaseStorage.instance.ref().child('${_addTripData.city}');
    StorageReference wallpaperFolderRef = cityReference.child('wallpaper');
    StorageReference wallpaperRef = wallpaperFolderRef.child('${_addTripData.wallpaperUrl}');
    wallpaperRef.putFile(_image).onComplete.then(_handleSuccess);
  }

  void _submit()
  {
    final formKey = _formKey.currentState;
    if(formKey.validate())
    {
      formKey.save();
      _register();
    }
    else
    {
      setState(()
      {
        _autoValidate = true;
      });
    }
  }

  Widget _buildSubmitBtn() {
    return Container(
      alignment: Alignment(-1.0, 0.0),
      child: RaisedButton(
        textColor: Colors.white,
        color: Theme.of(context).primaryColor,
        child: const Text('Submit'),
        onPressed: _submit,
      )
    );
  }

}


class _DatePicker extends StatefulWidget {

  final Function(DateTime selectedDate) onDateChanged;

  _DatePicker({@required this.onDateChanged});

  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<_DatePicker> {
  DateTime _dateNow = DateTime.now();
  DateTime _initialDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _initialDate,
        firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
        lastDate: DateTime(_dateNow.year + 1, _dateNow.month, _dateNow.day));
    if (picked != null && picked != _initialDate)
    {
      widget.onDateChanged(picked);
      setState(() {
          _dateController.text = _dateFormat.format(picked);
          _initialDate = picked;
        }
      );
    }
  }

  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        child: new TextFormField(
        enabled: false,
        decoration: new InputDecoration(
          icon: const Icon(Icons.calendar_today),
          hintText: 'Enter date when you traveled',
          labelText: 'Traveled Date',
        ),
        controller: _dateController,
        keyboardType: TextInputType.datetime,
      )),
      IconButton(
        icon: new Icon(Icons.more_horiz),
        tooltip: 'Choose date',
        onPressed: (() {
          _selectDate(context);
        }),
      )
    ]);
  }
}
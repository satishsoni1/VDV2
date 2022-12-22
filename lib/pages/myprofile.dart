import 'package:blog_app/main.dart';
import 'package:blog_app/pages/wallet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Myprofile extends StatefulWidget {
  const Myprofile();

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  bool val1 = false;
  bool val2 = false;
  bool val3 = false;
  bool val4 = false;
  bool val5 = false;

  Color _focus(value) {
    if (value == true)
      return Colors.red;
    else
      return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: <Widget>[
              Stack(children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color.fromARGB(255, 235, 233, 233),
                          spreadRadius: 1,
                        )
                      ],
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 60,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      child: const Icon(
                        Icons.edit,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ]),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                alignment: Alignment.topLeft,
                child: const Text(
                  "Basic Information",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  "Name",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 10),
                  width: 350,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color.fromARGB(255, 235, 233, 233),
                          spreadRadius: 1,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                      shape: BoxShape.rectangle,
                      border: Border.all(color: _focus(val5))),
                  child: TextField(
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(0, 255, 254, 254))),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    onTap: () {
                      setState(() {
                        val5 = true;
                        val1 = false;
                        val3 = false;
                        val4 = false;
                        val2 = false;
                      });
                    },
                  )),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  "Number",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  width: 350,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color.fromARGB(255, 235, 233, 233),
                          spreadRadius: 1,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                      shape: BoxShape.rectangle,
                      border: Border.all(color: _focus(val4))),
                  child: TextField(
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    onTap: () {
                      setState(() {
                        val4 = true;
                        val2 = false;
                        val3 = false;
                        val1 = false;
                        val5 = false;
                      });
                    },
                  )),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  "Email",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  width: 350,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color.fromARGB(255, 235, 233, 233),
                          spreadRadius: 1,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                      shape: BoxShape.rectangle,
                      border: Border.all(color: _focus(val3))),
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    onTap: () {
                      setState(() {
                        val3 = true;
                        val2 = false;
                        val1 = false;
                        val4 = false;
                        val5 = false;
                      });
                    },
                  )),
              Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.fromLTRB(0, 10, 19, 0),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {},
                    child: Text("Update Profile"),
                  )),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                child: const Text(
                  "Password Changes",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  "New Password",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  width: 350,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color.fromARGB(255, 235, 233, 233),
                          spreadRadius: 1,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                      shape: BoxShape.rectangle,
                      border: Border.all(color: _focus(val2))),
                  child: TextField(
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    onTap: () {
                      setState(() {
                        val2 = true;
                        val1 = false;
                        val3 = false;
                        val4 = false;
                        val5 = false;
                      });
                    },
                  )),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  "Retype Password",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  width: 350,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        color: Color.fromARGB(255, 235, 233, 233),
                        spreadRadius: 1,
                      )
                    ],
                    borderRadius: BorderRadius.circular(10),
                    shape: BoxShape.rectangle,
                    border: Border.all(color: _focus(val1)),
                  ),
                  child: TextField(
                    onTap: () {
                      setState(() {
                        val1 = true;
                        val2 = false;
                        val3 = false;
                        val4 = false;
                        val5 = false;
                      });
                    },
                    decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
                        )),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                  )),
              Container(
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.fromLTRB(0, 10, 19, 0),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {},
                    child: const Text("Update Password"),
                  )),
            ],
          ),
        )));
  }
}

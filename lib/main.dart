// ignore: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:tp2/config/api_config.dart';
import 'package:tp2/screens/home_page.dart';

void main() {
  runApp(const ShowApp());
}

class ShowApp extends StatelessWidget {
  const ShowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Show App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), // Ajoute la virgule ici
      home: const HomePage(), // Remplace LoginPage par HomePage
    );
  }
}

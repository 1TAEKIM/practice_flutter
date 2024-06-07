import 'package:flutter/material.dart';
import 'dart:io';

class ResultPage extends StatelessWidget {
  final String result;
  final String imageUrl;

  ResultPage({required this.result, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'HTP 검사 결과',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                if (imageUrl.isNotEmpty)
                  Image.file(File(imageUrl)),
                SizedBox(height: 20),
                Text(
                  '결과: $result',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xff110f12),
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

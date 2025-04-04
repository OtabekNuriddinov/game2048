import 'package:flutter/material.dart';
import 'package:game2048/core/theme/colors.dart';

sealed class AppDialog {
  static Future<dynamic> showMyDialog(void Function()next,BuildContext context){
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("GAME OVER", style: TextStyle(color: AppColors.black, fontSize: 30),),
                SizedBox(height: 10),
                Text("Do you want to play again?", style: TextStyle(fontSize: 16, letterSpacing: 1),)
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  next();
                },
                child: Text("Yes"),
              ),

            ],
          );
        });
  }
}
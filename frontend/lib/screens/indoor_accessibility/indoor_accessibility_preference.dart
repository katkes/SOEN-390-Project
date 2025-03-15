import 'package:flutter/material.dart';

class IndoorAccessibilityPage extends StatefulWidget{
  const IndoorAccessibilityPage({
    super.key,
});
  State<IndoorAccessibilityPage> createState() => IndoorAccessibilityState();
}//end of IndoorAccessibilityPage class

class IndoorAccessibilityState extends State<IndoorAccessibilityPage>{
   bool isMobilityImpaired = false; //assume the user is not.

   Widget build(BuildContext context){
     return Column(
       children: [
         Text('requires mobility considerations: $isMobilityImpaired'),
         Checkbox(
           value: isMobilityImpaired,
           onChanged: (bool? newValue) {
             setState(() {
               isMobilityImpaired = newValue ?? false;
             });
           },
         ),
       ],
     );
   }
}//end of IndoorAccessibilityState class.
import 'package:flutter/material.dart';

//walking, escelator, elevator, stairs.
//
class IndoorAccessibilityPage extends StatefulWidget{
  const IndoorAccessibilityPage({
    super.key,
});
  State<IndoorAccessibilityPage> createState() => IndoorAccessibilityState();
}//end of IndoorAccessibilityPage class



class IndoorAccessibilityState extends State<IndoorAccessibilityPage>{
   bool isMobilityImpaired = false; //assume the user is not.

   bool getMobilityStatus() {
     return isMobilityImpaired; //will be used for testing purposes.
   }

   Widget build(BuildContext context){
     return Column(
       children: [
         const Text("PREFERENCES", style:TextStyle(
             fontSize: 15
         )),
         const Divider(
           color: Colors.grey, // Line color
           thickness: 2,       // Line thickness
           indent: 10,         // Left padding
           endIndent: 10,      // Right padding
         ),

         const Row(
           children:[
             Text('requires mobility considerations: $isMobilityImpaired'),
             Checkbox(
               value: isMobilityImpaired,
               onChanged: (bool? newValue) {
                 setState(() {
                   isMobilityImpaired = newValue ?? false;
                 });
               },
             ),
           ]
         ),






       ],
     );
   }
}//end of IndoorAccessibilityState class.
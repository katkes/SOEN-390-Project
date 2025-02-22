import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class BuildingInformationPopup extends StatelessWidget {
  const BuildingInformationPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popover Example')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: PopoverButton(),
        ),
      ),
    );
  }
}

class PopoverButton extends StatelessWidget {
  const PopoverButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: GestureDetector(
        child: const Center(child: Text('Click Me')),
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => const ListItems(),
            onPop: () => print('Popover was popped!'),
            direction: PopoverDirection.bottom,
            width: 220,
            height: 200,
            arrowHeight: 15,
            arrowWidth: 30,
          );
        },
      ),
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Image.asset(
            "assets/images/buildings/hall.png",
            fit: BoxFit.cover,
            width: 200,
            height: 120,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Hall Building',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BuildingInformationPopup(),
    ),
  );
}

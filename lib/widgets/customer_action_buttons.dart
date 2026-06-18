import 'package:flutter/material.dart';

class CustomerActionButtons
    extends StatelessWidget {

  final VoidCallback onYouGave;
  final VoidCallback onYouGot;

  const CustomerActionButtons({
    super.key,
    required this.onYouGave,
    required this.onYouGot,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Expanded(
          child: ElevatedButton(
            onPressed: onYouGave,
            child:
                const Text('YOU GAVE'),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton(
            onPressed: onYouGot,
            child:
                const Text('YOU GOT'),
          ),
        ),
      ],
    );
  }
}
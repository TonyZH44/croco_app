import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen(
      {super.key,
      required this.parent,
      required this.imageUrl,
      required this.headerText,
      required this.supportText,
      required this.buttonText,
      required this.goBack});

  final Widget parent;
  final String imageUrl, headerText, supportText, buttonText;
  final bool goBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
          ),
          SizedBox(
            width: 320,
            height: 320,
            child: Image.asset(imageUrl),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 24, 0, 4),
            child: Text(
              headerText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            width: 320,
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 116),
            child: Text(
              supportText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            height: 44,
            width: 328,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: TextButton(
                onPressed: (() {
                  if (goBack) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => parent));
                  }
                }),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16),
                )),
          )
        ],
      ),
    );
  }
}

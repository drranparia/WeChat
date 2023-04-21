import 'package:flutter/material.dart';

import '../Class Files/color.dart';
import '../Class Files/textstyle.dart';
import '../Models/message_model.dart';

class MessageBox extends StatelessWidget {
  final bool isMe;
  // final String message;
  MessageModel currentMessage;
  // final bool isSeen;
  String timeStamp;
  MessageBox({
    super.key,
    required this.isMe,
    // required this.message,
    required this.timeStamp,
    required this.currentMessage,
    // required this.isSeen,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 50, maxWidth: 250),
                    decoration: const BoxDecoration(
                      gradient: AColor.buttonGradientShader,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        currentMessage.text.toString(),
                        style: textStyle14W,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // currentMessage.seen == true
                      //     ? const Icon(
                      //         Icons.done_all_rounded,
                      //         size: 20,
                      //         color: AColor.grey,
                      //       )
                      //     : const Icon(
                      //         Icons.done_all_rounded,
                      //         size: 20,
                      //         color: AColor.seen,
                      //       ),
                      // const SizedBox(
                      //   width: 5,
                      // ),
                      Text(timeStamp),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 50, maxWidth: 250),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        currentMessage.text.toString(),
                        style: textStyle14B,
                      ),
                    ),
                  ),
                  Text(timeStamp),
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}

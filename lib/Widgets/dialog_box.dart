import 'package:flutter/material.dart';
import 'package:messanger_app/Models/user_model.dart';

import '../Class Files/color.dart';

class ProfileDialog extends StatefulWidget {
  UserModel? targetUser;

  ProfileDialog({
    super.key,
    required this.targetUser,
  });
  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  @override
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: AColor.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                widget.targetUser!.img.toString(),
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  color: AColor.black.withOpacity(0.5),
                  child: Column(
                    children: [
                      Text(
                        widget.targetUser!.fullname.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          color: AColor.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.targetUser!.email.toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          color: AColor.white,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

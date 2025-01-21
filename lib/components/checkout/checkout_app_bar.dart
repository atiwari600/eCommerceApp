import 'package:flutter/material.dart';

class CheckoutAppBar extends StatefulWidget implements PreferredSizeWidget{
  final String leftButtonText;
  final String rightButtonText;
  final void Function () rightButtonFunction;

  const CheckoutAppBar(this.leftButtonText, this.rightButtonText, this.rightButtonFunction, {super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CheckoutAppBar> createState() => _CheckoutAppBarState();
}

class _CheckoutAppBarState extends State<CheckoutAppBar> {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Text(
              widget.leftButtonText,
              style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              widget.rightButtonFunction();
            },
            child: Text(
                widget.rightButtonText,
                style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                )
            ),
          )
        ],
      ),
    );
  }
}


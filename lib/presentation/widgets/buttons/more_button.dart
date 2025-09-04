import 'package:flutter/material.dart';

class MoreButton extends StatefulWidget {
  const MoreButton({super.key, required this.onTap, required this.text});

  final VoidCallback onTap;
  final String text;

  @override
  State<MoreButton> createState() => _MoreButtonState();
}

class _MoreButtonState extends State<MoreButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
                            width: 120,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: widget.onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: Text(
                                widget.text,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
  }
}
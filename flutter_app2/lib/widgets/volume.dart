import 'package:flutter/material.dart';

class Volume extends StatefulWidget {
  final num volume;
  final bool weightImperial;
  const Volume({super.key, required this.volume, required this.weightImperial});

  @override
  State<Volume> createState() => _VolumeState();
}

class _VolumeState extends State<Volume> {
  late String volume;

  @override
  Widget build(BuildContext context) {
    if (widget.weightImperial == false) {
      volume = "${widget.volume.toStringAsFixed(1)} kg";
    } else {
      volume = "${(widget.volume * 2.2).toStringAsFixed(1)} lbs";
    }
    return Text("Volume: $volume");
  }
}

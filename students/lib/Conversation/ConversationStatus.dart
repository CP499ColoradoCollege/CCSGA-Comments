import 'package:flutter/material.dart';

typedef FutureVoidCallback = Future<void> Function();

class ConversationStatus extends StatelessWidget {
  final FutureVoidCallback updateStatusCallback;
  final String status;
  final bool isCcsga;

  ConversationStatus(this.updateStatusCallback, this.status, this.isCcsga);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FractionallySizedBox(
        child: Card(
          child: ListTile(
            title: Row(children: [
              Spacer(),
              Icon(Icons.pending_outlined),
              SizedBox(
                width: 5,
              ),
              Text("Conversation status:"),
              SizedBox(
                width: 5,
              ),
              Text(status),
              Spacer(),
              isCcsga
                  ? IconButton(
                      icon: Icon(Icons.edit_outlined), onPressed: updateStatus)
                  : Container()
            ]),
          ),
        ),
        widthFactor: 0.6,
      ),
      height: 55,
    );
  }

  void updateStatus() {
    updateStatusCallback();
  }
}

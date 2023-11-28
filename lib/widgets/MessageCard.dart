import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munish_chat_app/API/api.dart';
import 'package:munish_chat_app/customize/Colors.dart';
import 'package:munish_chat_app/customize_snackbar/dialogs.dart';
import 'package:munish_chat_app/customize_snackbar/my_date_util.dart';
import 'package:munish_chat_app/main.dart';
import 'package:munish_chat_app/models/message.dart';

// ignore: must_be_immutable
class MessageCard extends StatefulWidget {
  final Message message;
  var isdelete;
  MessageCard({super.key, required this.message});
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = API.user.uid == widget.message.fromId;

    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      API.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 237, 239, 240),
                border:
                    Border.all(color: const Color.fromARGB(255, 243, 247, 249)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        widget.message.isStar
            ? IconButton(
                onPressed: () {
                  API.Unfavpurite(widget.message);
                },
                icon: Icon(
                  Icons.star_outline,
                  color: Colors.black,
                ))
            : Icon(null)
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 2),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 131, 227, 21),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? widget.message.isdelete
                    ? Text(' message is deleted')
                    : Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      )
                : widget.message.isdelete
                    ? Text('message is deleted')
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ?
                  // widget.message.isdelete?
                  // Text("message is deleted"):
                  // Text(widget.message.msg):
                  // Row(
                  //   children: [
                  //     Text()
                  //   ],
                  // ),
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: appcolor.green, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  : _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: appcolor.green, size: 26),
                      name: 'Save Image',
                      onTap: () async {}),
              _OptionItem(
                  icon: Icon(Icons.star_outline),
                  name: 'Star',
                  onTap: () {
                    API.favourite(widget.message);
                    Navigator.pop(context);
                  }),
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon:
                        const Icon(Icons.edit, color: appcolor.green, size: 26),
                    name: 'Edit Message',
                    onTap: () {}),
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: appcolor.green, size: 26),
                    name: 'Delete for everyone',
                    onTap: () {
                      API.deleteMessage(widget.message); 
                      Navigator.pop(context);
                    }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: appcolor.green, size: 26),
                    name: 'Delete for me',
                    onTap: () {
                      API.deleteForMe(widget.message);
                      Navigator.pop(context);
                    }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: appcolor.green, size: 26),
                    name: 'forward message',
                    onTap: () {
                      // await API.showForwardMessageDialog(widget.message).then((value) {
                      //   Navigator.pop(context);
                      // });
                      API.showForwardMessageDialog(context, widget.message);
                    }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('$name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}

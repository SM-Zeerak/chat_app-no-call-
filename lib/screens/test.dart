import 'dart:io';
import 'package:chat_app_1/Components/fullscreen_image_viewer.dart';
import 'package:chat_app_1/Components/video_player.dart';
import 'package:chat_app_1/screens/search_screen.dart';
import 'package:chat_app_1/screens/widgets/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class ChatScreen extends StatefulWidget {
  final String selectedUserId;
  final String selectedUserDocId;
  final String selectedUserImage; // Changed to String for URL

  ChatScreen({
    required this.selectedUserId,
    required this.selectedUserDocId,
    required this.selectedUserImage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  late String _currentUserId;
  String? _chatId;
  File? _mediaFile; // Can be an image or video
  bool _isUploading = false;
  bool _isVideo = false; // Flag to differentiate between image and video
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final chatService = ChatService();
      _chatId = await chatService.getOrCreateChatId(
        _currentUserId,
        widget.selectedUserDocId,
      );

      setState(() {}); // Refresh the UI when chatId is set
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  Future<void> _showMediaSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Media Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, isVideo: false);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery, isVideo: false);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Record a Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, isVideo: true);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Choose Video from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery, isVideo: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    final pickedFile = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = isVideo;

        if (isVideo) {
          _videoController = VideoPlayerController.file(_mediaFile!)
            ..initialize().then((_) {
              setState(() {}); // Refresh to show video preview
            });
        }
      });
    }
  }

  Future<void> _sendMediaMessage() async {
    if (_mediaFile != null && _chatId != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storagePath = _isVideo ? 'chat_videos' : 'chat_images';
        final storageRef = _storage.ref().child(storagePath).child(fileName);

        final uploadTask = storageRef.putFile(_mediaFile!);
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          print(
              'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
        });

        await uploadTask;
        final mediaUrl = await storageRef.getDownloadURL();

        await _sendMessage(mediaUrl: mediaUrl);

        setState(() {
          _mediaFile = null;
          _isUploading = false;
          if (_videoController != null) {
            _videoController!.dispose();
            _videoController = null;
          }
        });
      } catch (e) {
        print('Error uploading or sending media: $e');
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _sendMessage({String? mediaUrl}) async {
    if ((_messageController.text.isNotEmpty || mediaUrl != null) &&
        _chatId != null) {
      try {
        final messageRef = _database.child('Messages').child(_chatId!).push();
        final timestamp = ServerValue.timestamp;
        final messageData = {
          'senderId': _currentUserId,
          'receiverId': widget.selectedUserDocId,
          'text': _messageController.text,
          'mediaUrl': mediaUrl,
          'isVideo': _isVideo,
          'timestamp': timestamp,
        };

        await messageRef.set(messageData);

        await _database.child('Chats').child(_chatId!).update({
          'lastMessage': _messageController.text,
          'lastMessageTimestamp': timestamp,
        });

        final firestore = FirebaseFirestore.instance;
        final chatDoc = firestore.collection('Chats').doc(_chatId!);
        await chatDoc.set({
          'lastMessage': _messageController.text,
          'lastMessageTimestamp': Timestamp.now(),
        }, SetOptions(merge: true));

        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(widget.selectedUserId),
        actions: [
          CircleAvatar(
            backgroundImage: widget.selectedUserImage.isNotEmpty
                ? NetworkImage(widget.selectedUserImage)
                : AssetImage('assets/default_avatar.png') as ImageProvider,
            radius: 24,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatId == null
                ? Center(child: CircularProgressIndicator())
                : FirebaseAnimatedList(
                    query: _database
                        .child('Messages')
                        .child(_chatId!)
                        .orderByChild('timestamp'),
                    itemBuilder: (context, snapshot, animation, index) {
                      final message = snapshot.value as Map<dynamic, dynamic>;
                      final isSender = message['senderId'] == _currentUserId;

                      return _buildMessageItem(message, isSender);
                    },
                  ),
          ),
          if (_mediaFile != null) _buildMediaPreview(),
          if (_isUploading) _buildUploadProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: _showMediaSourceDialog,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_mediaFile != null) {
                      _sendMediaMessage();
                    } else {
                      _sendMessage();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: _isVideo ? 200 : 100, // Adjust height for video
      child: Stack(
        children: [
          _isVideo
              ? _videoController != null &&
                      _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : Center(child: CircularProgressIndicator())
              : Image.file(
                  _mediaFile!,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  _mediaFile = null;
                  if (_videoController != null) {
                    _videoController!.dispose();
                    _videoController = null;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearProgressIndicator(),
    );
  }

  Widget _buildMessageItem(Map<dynamic, dynamic> message, bool isSender) {
    final isVideo = message['isVideo'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullscreenMediaViewer(
                  mediaUrl: message['mediaUrl'],
                  isVideo: isVideo,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 10),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSender ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: isSender
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message['mediaUrl'] != null)
                        isVideo
                            ? AspectRatio(
                                aspectRatio: 16 / 9,
                                child: VideoPlayerWidget(
                                  url: message['mediaUrl'],
                                ),
                              )
                            : Image.network(
                                message['mediaUrl'],
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              )
                      else
                        Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            color: isSender ? Colors.white : Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              if (!isSender)
                CircleAvatar(
                  backgroundImage: widget.selectedUserImage.isNotEmpty
                      ? NetworkImage(widget.selectedUserImage)
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

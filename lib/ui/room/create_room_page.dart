import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/ui/room/create_rooom_view.dart';
import 'package:memory_weakness/ui/room/standby_room_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class CreateRoomPage extends StatelessWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const CreateRoomPage(),
    );
  }

  const CreateRoomPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final items = setItems();
    final _questionQuantity = items[0];
    final _memberQuantity = items[1];
    const textColor = Color(0xFF5C4444);
    const backColor = Color(0xFFFFFBE5);
    return Scaffold(
        appBar: AppBar(
          title: const Text('CREATE ROOM'),
        ),
        body: Consumer<CreateRoomViewModel>(builder: (context, model, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '問題数 : ',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 100.w,
                        height: 35.h,
                        child: Center(
                          child: DropdownButton(
                            items: _questionQuantity,
                            value: model.selectedQuestionQuantity,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                            dropdownColor: backColor,
                            onChanged: (value) => {
                              model.selectedQuestionQuantity = value! as int,
                              model.notify(),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '参加人数 : ',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 100.w,
                        height: 35.h,
                        child: Center(
                          child: DropdownButton(
                            items: _memberQuantity,
                            value: model.selectedMemberQuantity,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                            dropdownColor: backColor,
                            onChanged: (value) => {
                              model.selectedMemberQuantity = value! as int,
                              model.notify(),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.h),
                child: SizedBox(
                  height: 40.h,
                  width: 100.w,
                  child: GestureDetector(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.orange),
                      child: Center(
                        child: Text(
                          'set',
                          style: TextStyle(
                            fontSize: 30.sp,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      final roomName = await nameNewRoom();
                      await createRoom(model.selectedQuestionQuantity,
                          model.selectedMemberQuantity, roomName);
                      Navigator.of(context).push<dynamic>(
                        StandbyRoomPage.route(roomName: roomName),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }));
  }
}

List<List<DropdownMenuItem<int>>> setItems() {
  final _questionQuantity = <DropdownMenuItem<int>>[];
  final _memberQuantity = <DropdownMenuItem<int>>[];

  _questionQuantity
    ..add(
      DropdownMenuItem(
        value: 1,
        child: Text(
          '1',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 2,
        child: Text(
          '2',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 3,
        child: Text(
          '3',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 4,
        child: Text(
          '4',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );

  _memberQuantity
    ..add(
      DropdownMenuItem(
        value: 1,
        child: Text(
          '1',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 2,
        child: Text(
          '2',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 3,
        child: Text(
          '3',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    )
    ..add(
      DropdownMenuItem(
        value: 4,
        child: Text(
          '4',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  return [_questionQuantity, _memberQuantity];
}

Future<String> nameNewRoom() async {
  final roomQuerySnapshot =
      await FirebaseFirestore.instance.collection('room').get();
  final roomSnapshotList = roomQuerySnapshot.docs;
  var roomName = '0';
  var roomNameList = [];
  if (roomSnapshotList.isNotEmpty) {
    for (int i = 0; i < roomSnapshotList.length; i++) {
      roomNameList.add(roomSnapshotList[i].id);
    }
    for (int i = 0; i < roomNameList.length; i++) {
      if (!roomNameList.contains(i.toString())) {
        roomName = i.toString();
      }
    }
  }
  return roomName;
}

Future<void> createRoom(
    int questionQuantity, int memberQuantity, String roomName) async {
  final roomQuerySnapshot =
      await FirebaseFirestore.instance.collection('room').get();
  final roomSnapshotList = roomQuerySnapshot.docs;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  var valueList = [];
  final valueLength = questionQuantity;
  final rand = math.Random();
  var visibleList = [];
  final preference = await SharedPreferences.getInstance();
  final userName = preference.getString("userName");
  for (int i = 0; i < valueLength; i++) {
    valueList.add(i);
    valueList.add(i);
    visibleList.add(true);
    visibleList.add(true);
  }
  for (var i = valueLength * 2 - 1; i > 0; i--) {
    final n = rand.nextInt(i);
    final temp = valueList[i];
    valueList[i] = valueList[n];
    valueList[n] = temp;
  }
  await FirebaseFirestore.instance.collection('room').doc(roomName).set({
    'members': [uid],
    'names': [userName],
    'points': [0],
    'leaves': [],
    'maxMembers': memberQuantity,
    'questionQuantity': valueLength,
    'values': valueList,
    'openIds': [],
    'visibleList': visibleList,
    'turn': userName,
  });
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'roomID': roomName,
  });
}
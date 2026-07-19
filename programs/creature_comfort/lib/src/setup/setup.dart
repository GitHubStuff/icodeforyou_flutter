// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:creature_comfort/src/data/data_transfer.dart'
    show SinceWhenController;
import 'package:creature_comfort/src/dom/dom.dart'
    show SinceWhen, SinceWhenUser;
import 'package:creature_comfort/src/firebase/since_when_crud.dart'
    show SinceWhenCrud;
import 'package:flutter/material.dart';

class Setup {
  static Future<void> initDOM() async {
    SinceWhenController.reset();
    const feedCritters = SinceWhen(
      identity: 1,
      caption: 'Fed The Critters',
    );
    SinceWhenController.addEvent(feedCritters);

    const tookAmMeds = SinceWhen(identity: 2, caption: 'Took AM meds');
    SinceWhenController.addEvent(tookAmMeds);

    const amber = SinceWhenUser(
      userId: 100,
      email: 'amber@icodeforyou.com',
      name: 'Amber Tand',
      sinceWhenList: [1],
    );
    SinceWhenController.addUser(amber);

    const steven = SinceWhenUser(
      userId: 200,
      email: 'steven@icodeforyou.com',
      name: 'Steven Smith',
      sinceWhenList: [1, 2],
    );
    SinceWhenController.addUser(steven);
  }

  static Future<void> loadIn() async {
    const encoder = JsonEncoder.withIndent('  ');
    final String jsonString = encoder.convert(SinceWhenController.toJson());

    final crud = SinceWhenCrud();
    final sw = Stopwatch()..start();
    await crud.create(jsonString);
    sw.stop();
    debugPrint('create took ${sw.elapsedMilliseconds} ms');

    sw.start();
    final String? _ = await crud.read();
    sw.stop();
    debugPrint('read took ${sw.elapsedMilliseconds} ms');

    sw..start()
    //await crud.delete();
    ..stop();
    debugPrint('delete took ${sw.elapsedMilliseconds} ms');
  }
}

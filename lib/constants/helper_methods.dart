import 'package:firebase_database/firebase_database.dart';
import 'package:soft_ride/Firebase_Service/global.dart';
import 'package:soft_ride/models/user_model.dart';

class HelperMethods {
  static Future<void> readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    // Getting the current user's data using the user's ID
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if(snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        print('USER: \nName: ${userModelCurrentInfo!.name} \nEmail: ${userModelCurrentInfo!.email}');
      }
    });
  }

}
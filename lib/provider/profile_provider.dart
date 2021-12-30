
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _profileName="";
  String _image="";
  String _repoNo="";
  String _repoUrl="";




  void setProfileName(String text) {
    _profileName = text;
    print("vhbnov"+_profileName.toString());
    notifyListeners();
  }

  void setImageUrl(String text) {
    _image = text;
    print("gydjshgkfd"+_image.toString());
    notifyListeners();
  }
  void setRepoNo(String text) {
    _repoNo = text;
    print("dhfhf"+_repoNo.toString());
    notifyListeners();
  }
  void setRepoUrl(String text) {
    _repoUrl = text;
    print("ttfhfj"+_repoUrl.toString());
    notifyListeners();
  }



  String get getProfileName => _profileName;
  String get getImage =>_image;
  String get getRepoNo =>_repoNo;
  String get getRepoUrl =>_repoUrl;


}
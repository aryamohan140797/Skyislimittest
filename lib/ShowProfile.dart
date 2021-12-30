import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:machine_test/provider/profile_provider.dart';
import 'dart:convert';

import 'package:machine_test/template/Starred.dart';
import 'package:machine_test/template/User.dart';
import 'package:machine_test/template/gists.dart';
import 'package:machine_test/template/repo.dart';
import 'package:machine_test/webview.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowProfile extends StatefulWidget {
  final String username, user;

  ShowProfile({this.username, this.user});

  @override
  State<StatefulWidget> createState() {
    return new ProfileState(username: username, user: user);
  }
}

class ProfileState extends State<ShowProfile> {


  bool repo_loading = true,
      gist_loading = true,
      star_loading = true,
      followers_loading = true,
      following_loading = true;
  bool repo_data = false,
      gist_data = false,
      star_data = false,
      followers_data = false,
      following_data = false;

  String username, user;

  ProfileState({this.username, this.user}) {
    this.username = username;
  }

  String base_url = "https://api.github.com/users/";

  String getURL() {
    return base_url + user + "/";
  }
  void _launchURL(url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  var ResBody;
  List<Repo> _repo = [];
  List<Gist> _gist = [];
  
  List<Starred> _starred = [];
  List<User> _followers = [];
  List<User> _following = [];

  getRepo() async {
    final loc = Provider.of<ProfileProvider>(context,listen: false);

    var res = await http.get(Uri.parse(getURL() + "repos"),
        headers: {"Accept": "application/json"});
    ResBody = json.decode(res.body);
    print("dygdi"+ResBody.toString());
    setState(() {
      for (var data in ResBody) {
        _repo.add(new Repo(data['name'], data['description'],
            data['stargazers_count'], data['forks_count'], data['language']));
        repo_data = true;
      }

    });
    repo_loading = false;
  }

  getGist() async {
    var res = await http.get(Uri.parse(getURL() + "gists"),
        headers: {"Accept": "application/json"});
    ResBody = json.decode(res.body);
    setState(() {
      for (var data in ResBody) {
        _gist.add(new Gist(
            description: data['files'].keys.first,
            created_at: data['created_at']));
        gist_data = true;
      }

      gist_loading = false;
    });
  }

  getStarred() async {
    var res = await http.get(Uri.parse(getURL() + "starred"),
        headers: {"Accept": "application/json"});
    ResBody = json.decode(res.body);
    setState(() {
      for (var data in ResBody) {
        _starred.add(new Starred(data['name'], data['stargazers_count'],
            data['forks_count'], data['language']));
        star_data = true;
      }

      star_loading = false;
    });
  }

  getFollowers() async {
    var res = await http.get(Uri.parse(getURL() + "followers"),
        headers: {"Accept": "application/json"});
    ResBody = json.decode(res.body);
    setState(() {
      for (var data in ResBody) {
        _followers.add(new User(
          text: data['login'],
          image: data['avatar_url'],
        ));
        followers_data = true;
      }
      followers_loading = false;
    });
  }

  getFollowing() async {
    var res = await http.get(Uri.parse(getURL() + "following"),
        headers: {"Accept": "application/json"});
    ResBody = json.decode(res.body);
    setState(() {
      for (var data in ResBody) {
        _following.add(new User(
          text: data['login'],
          image: data['avatar_url'],
        ));

        following_data = true;
      }
    });
    following_loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
              backgroundColor: Colors.white,
              title: new Text(
                username,
                style: TextStyle(color: Colors.black),
              ),
              bottom: new TabBar(
                isScrollable: true,
                tabs: [
                  new Tab(
                      child: new Text(
                    "Profile",
                    style: TextStyle(color: Colors.black),
                  )),
                  new Tab(
                      child: new Text(
                    "Repository",
                    style: TextStyle(color: Colors.black),
                  )),
                ],
              )),
          body: new TabBarView(
            children: [
              Container(child: _Followers_data()),
              new Container(child: _Repo_data()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){

      getRepo();
      getGist();
      getStarred();
      getStarred();
      getFollowers();
      getFollowing();
      _Repo_data();

    });

  }

  Widget _Repo_data() {
    final loc = Provider.of<ProfileProvider>(context,listen: false);
    loc.setRepoNo(_repo.length.toString());
    if (repo_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (!repo_data) {
      return new Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("$user have No Repo",
                  style: Theme.of(context).textTheme.display1)
            ]),
      );
    } else {

      return new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            itemBuilder: (_, int index) => InkWell(
                onTap: (){
                  print("dgudog");
                  _launchURL("https://api.github.com/users/aryamohan140797/repos");
                },
                child: _repo[index]),
            itemCount: _repo.length,
          ))
        ],
      );
    }

  }

  Widget _Gist_data() {
    if (gist_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (!gist_data) {
      return new Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("$user have No Gists",
                  style: Theme.of(context).textTheme.display1)
            ]),
      );
    } else {
      return new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            itemBuilder: (_, int index) => _gist[index],
            itemCount: _gist.length,
          ))
        ],
      );
    }
  }

  Widget _Starred_data() {
    if (star_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (!star_data) {
      return new Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("$user haven't starred any Repos",
                  style: Theme.of(context).textTheme.display1)
            ]),
      );
    } else {
      return new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            itemBuilder: (_, int index) => _starred[index],
            itemCount: _starred.length,
          ))
        ],
      );
    }
  }

  Widget _Following_data() {
    if (following_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (!following_data) {
      return new Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("$user is not following to anyone",
                  style: Theme.of(context).textTheme.display1)
            ]),
      );
    } else {
      return new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            itemBuilder: (_, int index) => _following[index],
            itemCount: _following.length,
          ))
        ],
      );
    }
  }

  Widget _Followers_data() {
    final loc = Provider.of<ProfileProvider>(context,listen: false);

    return new Column(
      children: <Widget>[
        new Flexible(
            child: new Container(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              margin: const EdgeInsets.only(right: 5.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10,),
                  new Image.network(loc.getImage,width: 150.0,height: 150.0,),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10,),
                        new Text(
                            loc.getProfileName,
                            style: Theme.of(context).textTheme.title
                        ),
                      SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "No: of Repositories : ",
                                style: TextStyle(color: Colors.black,fontSize: 16.0)
                            ),
                            Text(
                                loc.getRepoNo,
                                style: Theme.of(context).textTheme.title
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ))
      ],
    );
  }

}

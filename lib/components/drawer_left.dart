import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/jinrishici.dart';
import 'package:flutter_app/network/api_network.dart';
import 'package:flutter_app/network/constants.dart';
import 'package:flutter_app/page_login.dart';
import 'package:flutter_app/page_nodes.dart';
import 'package:flutter_app/utils/eventbus.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerLeft extends StatefulWidget {
  @override
  _DrawerLeftState createState() => _DrawerLeftState();
}

class _DrawerLeftState extends State<DrawerLeft> {
  String userName = "", avatar = "";
  Poem poemOne;

  @override
  void initState() {
    super.initState();
    checkLoginState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle aboutTextStyle = themeData.textTheme.body2;
    final TextStyle linkStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);

    //监听登录事件
    bus.on("login", (arg) {
      // do something
      checkLoginState();
    });

    return SizedBox(
      width: 260.0,
      child: new Drawer(
        child: SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountName: GestureDetector(
                  onTap: () {
                    if (userName.isEmpty) {
                      Navigator.push(
                          context, new MaterialPageRoute(builder: (context) => new LoginPage()));
                    } else {
                      // todo -> 个人中心页面
                    }
                  },
                  child: Text(
                    userName.isNotEmpty ? userName : "       登录",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                accountEmail: GestureDetector(
                  onTap: () {
                    if (poemOne != null) {
                      // 显示诗词dialog
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => SimpleDialog(
                                children: <Widget>[
                                  Center(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          poemOne.data.origin.title,
                                          style: TextStyle(
                                              fontSize: 20.0, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(poemOne.data.origin.dynasty +
                                            "·" +
                                            poemOne.data.origin.author),
                                        Container(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            children: poemOne.data.origin.content
                                                .map((value) => Text(value))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ));
                    }
                  },
                  child: Text(poemOne != null ? poemOne.data.content : ""),
                ), // 随机一句短诗词 poems[Random().nextInt(poems.length - 1)]
                currentAccountPicture: new GestureDetector(
                  onTap: () {
                    if (userName.isEmpty) {
                      //未登录
                      Navigator.push(
                          context, new MaterialPageRoute(builder: (context) => new LoginPage()));
                    } else {
                      // todo -> 个人中心页面
                    }
                  },
                  child: new CircleAvatar(
                    backgroundImage: avatar.isNotEmpty
                        ? new NetworkImage("https:" + avatar)
                        : new AssetImage("assets/images/ic_person.png"),
                  ),
                ),
                // todo 这里可以根据一天的不同时间显示不同的background，增加美观
                /*decoration: new BoxDecoration(
                  image: new DecorationImage(
                      fit: BoxFit.cover, image: new NetworkImage("https://i.loli.net/2018/12/06/5c08c7b804e89.png"))),*/
              ),

              // todo 目前没必要，这里后面考虑要不要有
              /*new ListTile(
              leading: new Icon(Icons.explore),
              title: new Text("浏览"),
              onTap: () {
                Navigator.pop(context);
              },
            ),*/

              new ListTile(
                leading: new Icon(Icons.apps),
                title: new Text("节点"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context, new MaterialPageRoute(builder: (context) => new NodesPage()));
                },
              ),
              new ListTile(
                enabled: false, // todo 登录后打开
                leading: new Icon(Icons.notifications),
                title: new Text("通知"),
              ),
              new ListTile(
                enabled: false, // todo 登录后打开
                leading: new Icon(Icons.favorite),
                title: new Text("收藏"),
              ),
              new Divider(),
              new ListTile(
                leading: new Icon(Icons.settings),
                title: new Text("设置"),
              ),
              new ListTile(
                leading: new Icon(Icons.feedback),
                title: new Text("反馈"),
                onTap: () {
                  _launchURL(
                      "mailto:smith@example.org?subject=V2LF%20Feedback&body=New%20feedback");
                },
              ),
              new AboutListTile(
                icon: new Icon(Icons.info),
                child: new Text("关于"),
                applicationName: "V2LF",
                applicationVersion: "v0.0.4",
                applicationLegalese: '© 2018 Wml',
                applicationIcon: new Image.asset(
                  "assets/images/icon/ic_launcher.png",
                  width: 64.0,
                  height: 64.0,
                ),
                aboutBoxChildren: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: RichText(
                        text: TextSpan(
                      children: [
                        TextSpan(
                            style: aboutTextStyle,
                            text:
                                "V2LF is a v2ex unofficial app.'V2LF' means 'way to love flutter'.\n\nTo see the source code for this app, please visit the "),
                        _LinkTextSpan(
                          style: linkStyle,
                          url: 'https://github.com/w4mxl/V2exByFlutter',
                          text: 'v2lf github repo',
                        ),
                        TextSpan(
                          style: aboutTextStyle,
                          text: '.\n\n¯\\_(ツ)_/¯',
                        ),
                      ],
                    )),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future checkLoginState() async {
    SharedPreferences sp = await getSP();
    var spUsername = sp.getString(SP_USERNAME);
    if (spUsername != null && spUsername.length > 0) {
      // todo 加了这个后每次刷新的体验要优化一下
      getOnePoem();
      setState(() {
        userName = spUsername;
        avatar = sp.getString(SP_AVATAR);
      });
    }
  }

  Future getOnePoem() async {
    var poem = await NetworkApi.getPoem();
    print(poem.token);
    setState(() {
      if (poem != null) poemOne = poem;
    });
  }
}

class _LinkTextSpan extends TextSpan {
  _LinkTextSpan({TextStyle style, String url, String text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch(url);
              });
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Fluttertoast.showToast(
        msg: '您似乎没在手机上安装邮件客户端 ?',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
        gravity: ToastGravity.BOTTOM);
  }
}

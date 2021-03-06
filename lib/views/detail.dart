import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../store/api.dart';
import '../modules/detail/detailModel.dart';
import '../store/index.dart';
import 'package:flutter_image/network.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_html/flutter_html.dart';
import '../utils/http.dart';

class Detail extends StatefulWidget {
    final String id;

    Detail(this.id);

    @override
    State<StatefulWidget> createState() {
        // TODO: implement createState
        return new _DetailState();
    }
}

class _DetailState extends State<Detail> {
    DetailItem detailItem;
    bool isRefreshing = false;

    Future reqData({@required String itemId}) {
        final dio = createDio();
        final url = Api.getDetailUrl(id: itemId);
        print(url);
        return dio.get(url).then((res) {
            print(res);
            if (res.data['success'] = true) {
                var data = res.data['data'];
                return DetailItem.fromJson(data);
            } else {
                throw new Exception();
            }
        });
    }

    // 采用Dart原生进行请求，可用，但已废弃
    /*_reqData({@required String item_id, VoidCallback complete}) {
        var httpClient = new HttpClient();
        var url = Uri.parse(Api.detailData + item_id);
        return httpClient.getUrl(url).then((HttpClientRequest request) {
            return request.close();
        }).then((HttpClientResponse response) {
            response.transform(utf8.decoder).join().then((contents) {
//                print('detail内容：${contents}');
                print('url地址:${Api.detailData}$item_id');
                print('detail数据长度：${contents.length}');
                var data = json.decode(contents);
                if (data['code'] == 200) {
                    setState(() {
                        detailItem = DetailItem.fromJson(data['data']);
                    });
                }
            });
        }).catchError((error) {
            print(error);
        }).whenComplete(() {});
    }*/

    @override
    void initState() {
        // TODO: implement initState
        WidgetsBinding.instance.addPostFrameCallback((_) {
            print('详情页渲染完成');
        });
        super.initState();
        timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());
        refresh();
    }

    refresh() {
        setState(() {
            isRefreshing = true;
        });
        reqData(itemId: widget.id).then((data) {
            setState(() {
                detailItem = data;
            });
        }).catchError((error) {
            setState(() {
                detailItem = null;
            });
        }).whenComplete(() {
            setState(() {
                isRefreshing = false;
            });
        });
    }

    @override
    Widget build(BuildContext context) {
        GModel gModel = ScopedModel.of<GModel>(context, rebuildOnChange: true);
        gModel.setNum(15);

        // TODO: implement build
        Widget noNetWorkWidget() {
            return new Center(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        new Icon(Icons.signal_wifi_off),
                        new Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: new Text(
                                '网络挂了啊~！',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14.0
                                ),
                            ),
                        ),

                        new RaisedButton(
                            child: new Text('点击刷新'),
                            color: Colors.lightBlue,
                            textColor: Colors.white,
                            onPressed: refresh
                        )
                    ],
                ),
            );
        }

        return new Scaffold(
            backgroundColor: Colors.white,
            appBar: new AppBar(
                title: new Text(detailItem?.detail_source ?? ''),
                backgroundColor: Colors.white,
                brightness: Brightness.light,
                iconTheme: Theme
                    .of(context)
                    .copyWith(brightness: Brightness.light)
                    .iconTheme,
                textTheme: Theme
                    .of(context)
                    .copyWith(brightness: Brightness.light)
                    .textTheme,
                elevation: 0.0,
                bottom: new PreferredSize(
                    child: new Divider(
                        height: 1.0,
                        color: Colors.grey,
                    ),
                    preferredSize: new Size(300.0, 1.0)
                )
            ),
            body: new Stack(
                children: <Widget>[
                    detailItem != null ? new SingleChildScrollView(
                        child: new SafeArea(
                            child: new Padding(
                                padding: new EdgeInsets.all(15.0),
                                child: new Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                        new Text(
                                            detailItem?.title ?? '',
                                            softWrap: true,
                                            textAlign: TextAlign.left,
                                            textDirection: TextDirection.ltr,
                                            style: new TextStyle(fontSize: 24.0),
                                        ),
                                        new Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0, bottom: 10.0),
                                            child: new Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceBetween,
                                                children: <Widget>[
                                                    new Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                            new SizedBox(
                                                                child: new CircleAvatar(
                                                                    backgroundImage: new NetworkImageWithRetry(
                                                                        detailItem
                                                                            ?.avatar_url ??
                                                                            ''),
                                                                    backgroundColor: Colors
                                                                        .white,
                                                                ),
                                                                width: 48.0,
                                                                height: 48.0,
                                                            ),
                                                            new Padding(
                                                                padding: const EdgeInsets
                                                                    .only(left: 10.0),
                                                                child: new Column(
                                                                    mainAxisAlignment: MainAxisAlignment
                                                                        .start,
                                                                    crossAxisAlignment: CrossAxisAlignment
                                                                        .start,
                                                                    children: <Widget>[
                                                                        new Text(
                                                                            detailItem
                                                                                ?.detail_source ??
                                                                                '',
                                                                            style: new TextStyle(
                                                                                fontSize: 16.0,
                                                                                fontWeight: FontWeight
                                                                                    .bold,
                                                                                color: new Color(
                                                                                    0xff222222)
                                                                            ),
                                                                        ),
                                                                        new Text(
                                                                            detailItem !=
                                                                                null
                                                                                ? timeago
                                                                                .format(
                                                                                new DateTime
                                                                                    .fromMillisecondsSinceEpoch(
                                                                                    detailItem
                                                                                        .publish_time *
                                                                                        1000),
                                                                                locale: 'zh_CN')
                                                                                : '',
                                                                            style: new TextStyle(
                                                                                fontSize: 14.0,
                                                                                color: new Color(
                                                                                    0xff9d9d9d)
                                                                            ),
                                                                        )
                                                                    ],
                                                                ),
                                                            )
                                                        ],
                                                    ),
                                                ],
                                            ),
                                        ),
                                        new Html(
                                            data: detailItem?.content ?? '<p>掉毛没有</p>',
                                            onLinkTap: (url) {
                                                print(url);
                                            }
                                        )
                                    ],
                                ),
                            )
                        )
                    ) : noNetWorkWidget(),
                    new Offstage(
                        offstage: !isRefreshing,
                        child: new Center(
                            child: new CupertinoActivityIndicator(
                                radius: 20.0,
                            ),
                        )
                    )

                ]
            )

        );
    }
}


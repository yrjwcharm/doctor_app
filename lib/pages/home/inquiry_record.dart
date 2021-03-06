import 'package:doctor_project/common/style/gsy_style.dart';
import 'package:doctor_project/http/http_request.dart';
import 'package:doctor_project/pages/my/rp_detail.dart';
import 'package:doctor_project/utils/colors_utils.dart';
import 'package:doctor_project/utils/common_utils.dart';
import 'package:doctor_project/widget/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doctor_project/pages/home/inquiry_detail.dart';
import 'package:doctor_project/pages/my/write_case_detail.dart';
import '../../http/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:doctor_project/widget/custom_outline_button.dart';
import 'package:doctor_project/widget/custom_elevated_button.dart';
import 'package:doctor_project/pages/my/write_case.dart';
import '../../utils/toast_util.dart';

class InquiryRecord extends StatefulWidget {
  final String userId;

  const InquiryRecord({Key? key, required this.userId}) : super(key: key);

  @override
  _InquiryRecordState createState() => _InquiryRecordState(userId);
}

class _InquiryRecordState extends State<InquiryRecord> {
  final ScrollController _scrollController = ScrollController(); //listview的控制器
  List list = [];
  String tapIndex ='';
  String status = '';
  List tabList = [
    {'label': '全部', 'checked': true, 'value':''},
    {'label': '已完成', 'checked': false, 'value': '4'},
    {'label': '已取消', 'checked': false, 'value': '6'},
  ];
  String userId;

  _InquiryRecordState(this.userId);

  int _page = 1; //加载的页数
  bool isMore = true; //是否正在加载数据
  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
        _getMore();
      }
    });
  }

  /**
   * 初始化list数据 加延时模仿网络请求
   */
  Future getData() async {
    var request = HttpRequest.getInstance();
    var res = await request.get(
        Api.getDictListApi +
            '?status=$tapIndex&page=$_page&size=10',
        {});
    if (res['code'] == 200) {
      setState(() {
        list = res['data']['records'];
        print('list+++++++++++++++++----'+list.toString());
        isMore = true;
      });
    } else {
      ToastUtil.showToast(msg: res['msg']);
    }
  }

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<void> _onRefresh() async {
    setState(() {
      _page = 1;
    });
    getData();
  }

  Future _getMore() async {
    if (isMore) {
      _page += 1;
      var request = HttpRequest.getInstance();
      var res = await request.get(
          Api.getDictListApi +
              '?status=&page=$_page&size=10',
          {});
      if (res['code'] == 200) {
        var total = res['data']['total'];
        var size = res['data']['size'];
        int totalPage = (total / size).ceil();
        if (_page <= totalPage) {
          setState(() {
            list.addAll(res['data']['records']);
            isMore = true;
            _page;
          });
        } else {
          setState(() {
            isMore = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtil.bgColor,
      appBar: CustomAppBar(
        '问诊记录',
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 44.0,
            margin:const EdgeInsets.only(bottom: 8.0),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          tapIndex = '';
                          list = [];
                        });
                        getData();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '全部',
                            style: GSYConstant.textStyle(
                                color: tapIndex=='' ? '#06B48D' : '#666666'),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          tapIndex = '2';
                          list = [];
                        });
                        getData();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '已完成',
                            style: GSYConstant.textStyle(
                                color: tapIndex=='2' ? '#06B48D' : '#666666'),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          tapIndex = '8';
                          list = [];
                        });
                        getData();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '已取消',
                            style: GSYConstant.textStyle(
                                color: tapIndex=='8' ? '#06B48D' : '#666666'),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
                displacement: 10.0,
                onRefresh: _onRefresh,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    controller: _scrollController,
                    itemBuilder: (BuildContext context, int index) {
                      var item = list[index];
                      bool state = item['status_dictText']=='已取消'?false:true;
                       List<String>  diagnosis = [];
                       (item['diagnoses']??[]).forEach((element) {
                           diagnosis.add(element['diagnosisName']);
                       });
                       String str = '';
                       diagnosis.forEach((f){
                         if(str == ''){
                           str = "$f";
                         }else {
                           str = "$str"",""$f";
                         }
                       });
        
                      return GestureDetector(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=>  InquiryDetail(dataMap: item))
                           );
                         },
                          child: Column(
                            children: [
                              Container(
                            // height: 100.0,
                                width: double.infinity,
                                padding:
                                const EdgeInsets.only(left: 16.0, top: 16.0,bottom: 13.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipOval(
                                      child:item['photo'].isNotEmpty?Image.network(item['photo'],width: 40.0,height: 40.0,):(item['sex']=='1'?Image.asset('assets/images/boy.png'):Image.asset('assets/images/girl.png'))
                                    ),
                                    const SizedBox(
                                     width: 16.0,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                        Row(
                                          children: [
                                             Text(item['name']??'',
                                                 style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontFamily: 'Medium',
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      ColorsUtil.hexStringColor(
                                                          '#333333'))),
                                          const SizedBox(
                                            width: 16.0,
                                          ),
                                          Text(
                                            '${item['sex'] == '1' ? '男' : '女'} | ${item['age']}岁',
                                            style: GSYConstant.textStyle(
                                                color: '#666666'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                      Text(
                                        '${item['type_dictText']}',
                                        style: GSYConstant.textStyle(
                                            color: '#333333'),
                                      ),
//                                      const SizedBox(
//                                        height: 4.0,
//                                      ),
                                    ],
                                  ),
                                ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                        '${item['status_dictText']=='已接诊'?'已完成':item['status_dictText']}',
                                        style:
                                            GSYConstant.textStyle(color: '#333333'),
                                    ),
                                    const SizedBox(
                                      width: 16.0,
                                    ),
                                    Text(
                                        '¥${item['cost']}',
                                        style:GSYConstant.textStyle(color: '#FF0020'),
                                    ),
                                    const SizedBox(
                                      width: 16.0,
                                    ),
                              ],
                            ),
                                decoration: BoxDecoration(
                                color: Colors.white,
//
                                ),
                              ),
                              Container(
                                padding:
                                const EdgeInsets.only(left: 16.0,bottom: 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 0.5,
                                            color: ColorsUtil.hexStringColor(
                                                '#cccccc',
                                                alpha: 0.3)))),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child:Row(
                                        children: [
                                          Text(
                                            '诊断：${str}',
                                            style: GSYConstant.textStyle(
                                                color: '#333333'),
                                          ),],
                                      ))],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 0.5,
                                            color: ColorsUtil.hexStringColor(
                                                '#cccccc',
                                                alpha: 0.3)))),
                              ),
                              Container(
                              height: 42.0,
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 16.0,right: 16.0),
                              alignment: Alignment.centerLeft,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child:
                                      Text(
                                        item['lastTime'],
                                        style: GSYConstant.textStyle(color: '#666666'),
                                        ),
                                ),

                                CustomOutlineButton(
                                  title: '写病历',
                                  textStyle: GSYConstant.textStyle(
                                      fontSize: 13.0, color: '#666666'),
                                  padding:(
                                      const EdgeInsets.symmetric(horizontal: 13.0)
                                ),

                                  height: 28.0,
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderColor: ColorsUtil.hexStringColor('#09BB8F'),
                                  onPressed: () async {
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => WriteCase(registeredId:item['id'],

                                                  userInfoMap: item,)));

                                  },
                                ),

                              ],
                            )

                          ),
                          
                          const SizedBox(
                            height: 8.0,
                            width: double.infinity,
                          ),
                        ],
                      ));
                    })),
          )
        ],
      ),
    );
  }
}

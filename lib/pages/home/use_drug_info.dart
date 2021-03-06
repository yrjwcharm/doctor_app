import 'dart:convert';
import 'dart:math';

import 'package:doctor_project/common/event/event_bus.dart';
import 'package:doctor_project/common/style/gsy_style.dart';
import 'package:doctor_project/utils/colors_utils.dart';
import 'package:doctor_project/utils/toast_util.dart';
import 'package:doctor_project/widget/custom_app_bar.dart';
import 'package:doctor_project/widget/custom_safeArea_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doctor_project/utils/event_bus_util.dart';
import 'package:flutter_picker/flutter_picker.dart';
import '../../utils/svg_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widget/numberwidget.dart';

class UseDrugInfo extends StatefulWidget {
  Map drugInfoMap; //药品信息
  Map instructionsMap; //药品使用方法列表（用量、服药单位、用法等）
  UseDrugInfo(
      {Key? key, required this.drugInfoMap, required this.instructionsMap})
      : super(key: key);

  @override
  _UseDrugInfoState createState() => _UseDrugInfoState(
      drugInfoMap: this.drugInfoMap, instructionsMap: this.instructionsMap);
}

class _UseDrugInfoState extends State<UseDrugInfo> {
  /* 药品信息
  新增字段：
     count 个数
     dosage 用量
     frequency 次数
     usage 用法
     medicationDays 用药天数
     remark 备注
  */
  Map drugInfoMap;

  Map instructionsMap;

  FocusNode _focusNode = FocusNode();
  _UseDrugInfoState({required this.drugInfoMap, required this.instructionsMap});

  bool isHaveData = false; //是否是点击确认返回的
  final TextEditingController _editingController1 = TextEditingController();
  final TextEditingController _editingController2 = TextEditingController();
  final TextEditingController _editingController3 = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List list = [
    {'label': '使用频次：', 'placeholder': '请选择频次'},
    {'label': '剂量和单位：', 'placeholder': ''},
    {'label': '用法：', 'placeholder': '请选择用法'},
    {'label': '持续用药天数：', 'placeholder': '请输入用药天数'}
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('1111,${this.drugInfoMap}');
    drugInfoMap['count'] = 1;
    drugInfoMap['dosage'] = "";
    drugInfoMap['frequency'] = "";
    drugInfoMap['_frequency'] = "";
    // drugInfoMap['baseUnit'] = "";
    drugInfoMap['usage'] = "";
    drugInfoMap['_usage'] = "";
    drugInfoMap['medicationDays'] = "";
    drugInfoMap['remark'] = "";
    setState(() {
       list[1]['placeholder']=drugInfoMap['baseUnit'];
    });

  }

  /*
  data 数据源数组
  item 需要改变的数据源
  index 索引，用于区分需要改变的数据源参数为哪个
   */
  List<Widget> dialogData(List<String> data, List _data, Map item, int index) {
    List<Widget> widgetList = [];
    for (int i = 0; i < data.length; i++) {
      StatelessWidget dialog = SimpleDialogOption(
        child: Text(data[i]),
        onPressed: () {
          Navigator.of(context).pop();
          item['placeholder'] = data[i];
          if (index == 0) {
            drugInfoMap['_frequency'] = _data[i]['detailValue'];
            drugInfoMap['frequency'] = data[i];
          }  else if (index == 2) {
            drugInfoMap['_usage'] = _data[i]['detailValue'];
            drugInfoMap['usage'] = data[i];
          }
          setState(() {
          });
        },
      );

      widgetList.add(dialog);
      widgetList.add(
        const Divider(),
      );
    }

    return widgetList;
  }

  void _showSimpleDialog1() async {
    var result = await showDialog(
        useRootNavigator: false,
        barrierDismissible: true, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (context) {
          return SimpleDialog(
            // title:Text(""),
            children: dialogData(instructionsMap["freqType"],
                instructionsMap["_freqType"], list[0], 0),
          );
        });
  }


  void _showSimpleDialog3() async {
    var result = await showDialog(
        useRootNavigator: false,
        barrierDismissible: true, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: dialogData(instructionsMap["useType"],
                instructionsMap["_useType"], list[2], 2),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        '用药信息',
      
      ),
      backgroundColor: ColorsUtil.bgColor,
      body: Column(
        children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 40.0,
                  padding: const EdgeInsets.only(left: 16.0),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Text(
                    '请依据上传的病历/疾病资料，选择准确的药品名称、剂量和规格',
                    style:
                        GSYConstant.textStyle(fontSize: 12.0, color: '#EC605D'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 14.0, left: 16.0, right: 16.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              height: 3.0,
                            ),
                            Text(
                              drugInfoMap["medicinename"],
                              style: GSYConstant.textStyle(
                                  fontSize: 15.0, color: '#333333'),
                            ),
                            const SizedBox(
                              height: 6.0,
                            ),
                            Text(
                              //packageUnitid_dictText
                              '规格：' +
                                  drugInfoMap["specification"]
                                  +
                                  "/" +
                                  drugInfoMap["packageUnit"]
                              ,
                              style: GSYConstant.textStyle(
                                  fontSize: 13.0, color: '#888888'),
                            ),
                            Text(
                              drugInfoMap["manuname"]??'',
                              style: GSYConstant.textStyle(
                                  fontSize: 13.0, color: '#888888'),
                            )
                          ],
                        ),
                      ),
                       Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            NumberControllerWidget(
                              // iconWidth:10,
                              numText: drugInfoMap['count'].toString(),
                              addValueChanged: (num){

                              },
                              removeValueChanged: (num){
                              },
                              updateValueChanged: (num){
                                setState(() {
                                  drugInfoMap['count']=num;
                                });
                                // setState(() {
                                //   _productNum = num;
                                //   setState(() {
                                //     _saleprice = _productNum * widget.saleprice;
                                //   });
                                // });
                              },
                            ),
                            const SizedBox(height: 10.0,),
                            Text(
                              '库存：' + drugInfoMap["stockNum"].toString(),
                              style: GSYConstant.textStyle(
                                  color: '#888888', fontSize: 13.0),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  height: 44.0,
                  padding: const EdgeInsets.only(left: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '用法用量',
                    style: GSYConstant.textStyle(
                        fontFamily: 'Medium',
                        fontWeight: FontWeight.w500,
                        color: '#333333'),
                  ),
                ),
                Column(
                  children: list
                      .asMap()
                      .keys
                      .map((index) => GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              _showSimpleDialog1();
                            } else if (index == 1) {
                              // _showSimpleDialog2();
                            } else if (index == 2) {
                              _showSimpleDialog3();
                            }
                          },
                          child: Container(
                              height: 40.0,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        bottom: BorderSide(
                                            color: ColorsUtil.hexStringColor(
                                                '#cccccc',
                                                alpha: 0.3)))),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 98.0,
                                      child: Text(
                                        list[index]['label'],
                                        style: GSYConstant.textStyle(
                                            color: '#333333'),
                                      ),
                                    ),
                                    Visibility(
                                      visible: index == 1,
                                      child: Expanded(
                                          flex: 12,
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            controller: _editingController1,
                                            cursorColor:
                                                ColorsUtil.hexStringColor(
                                                    '#666666'),
                                            style: GSYConstant.textStyle(
                                                color: '#666666'),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9]")), //数字包括小数
                                            ],
                                             textAlign: TextAlign.right,
                                            decoration: InputDecoration(
                                                // filled: true,
                                                // fillColor: Colors.red,
                                                border: InputBorder.none,
                                                hintText: "请输入数量",
                                                hintStyle:
                                                    GSYConstant.textStyle(
                                                        color: '#999999')),
                                            onChanged: (value) {
                                              drugInfoMap['dosage']= value;
                                              setState(() {
                                              });
                                            },
                                            onSubmitted: (value) {
                                              print(value);
                                              drugInfoMap['dosage']= value;
                                               setState(() {

                                               });
                                            },
                                          )),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: index == 3
                                              ? _editingController2
                                              : null,
                                          cursorColor:
                                              ColorsUtil.hexStringColor(
                                                  '#666666'),
                                          style: GSYConstant.textStyle(
                                              color: '#666666'),
                                          inputFormatters: index == 3
                                              ? [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          "[0-9]")), //数字包括小数
                                                ]
                                              : [],
                                          textAlign: TextAlign.right,
                                          enabled: index == 3,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: list[index]
                                                  ['placeholder'],
                                              hintStyle: GSYConstant.textStyle(
                                                  color: '#999999')),
                                          onChanged: (value) {
                                            setState(() {
                                              drugInfoMap.update(
                                                  "medicationDays",
                                                  (value) =>
                                                      _editingController2.text);
                                            });
                                          },
                                          onSubmitted: (value) {
                                            setState(() {
                                              drugInfoMap.update(
                                                  "medicationDays",
                                                  (value) =>
                                                      _editingController2.text);
                                            });
                                          },
                                        )),
                                   index!=1? const SizedBox(
                                      width: 8.0,
                                    ):Container(),
                                    Visibility(
                                        visible: index!=1,
                                        child: SvgUtil.svg('arrow.svg'))
                                  ],
                                ),
                              ))))
                      .toList(),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 16.0, top: 9.0),
                  constraints: const BoxConstraints(minHeight: 80.0),
                  alignment: Alignment.topLeft,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '备注：',
                        style: GSYConstant.textStyle(color: '#333333'),
                      ),
                      const SizedBox(
                        width: 6.0,
                      ),
                      Expanded(
                          child: TextField(
                        controller: _editingController3,
                        inputFormatters: [],
                        cursorColor: ColorsUtil.hexStringColor('#666666'),
                        style: GSYConstant.textStyle(color: '#666666'),
                        decoration: InputDecoration(
                            hintText: '请输入...',
                            isCollapsed: true,
                            hintStyle: GSYConstant.textStyle(color: '#999999'),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero),
                        onChanged: (value) {
                          setState(() {
                            drugInfoMap.update(
                                "remark", (value) => _editingController3.text);
                          });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            drugInfoMap.update(
                                "remark", (value) => _editingController3.text);
                          });
                        },
                      ))
                    ],
                  ),
                ),
              ],
            ),
          )),
          Container(
            alignment: Alignment.center,
            child: CustomSafeAreaButton(
              title: '确认',
              onPressed: () {
                String dosageStr = drugInfoMap['dosage'];
                String usageStr = drugInfoMap["usage"];
                if (dosageStr.isEmpty || usageStr.isEmpty) {
                  Fluttertoast.showToast(
                      msg: '请选择或输入用法用量', gravity: ToastGravity.CENTER);
                  return;
                }
                EventBusUtil.getInstance().fire(drugInfoMap);
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}

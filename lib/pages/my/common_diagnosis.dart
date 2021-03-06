import 'package:doctor_project/common/style/gsy_style.dart';
import 'package:doctor_project/http/http_request.dart';
import 'package:doctor_project/pages/my/update_common_diagnosis.dart';
import 'package:doctor_project/utils/colors_utils.dart';
import 'package:doctor_project/utils/svg_util.dart';
import 'package:doctor_project/widget/custom_safeArea_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../http/api.dart';
import '../../model/common_diagnosis_modal.dart';
import '../../utils/toast_util.dart';
import '../../widget/custom_app_bar.dart';

class CommonDiagnosis extends StatefulWidget {
  String doctorId;

  CommonDiagnosis({Key? key, required this.doctorId}) : super(key: key);

  @override
  _CommonDiagnosisState createState() => _CommonDiagnosisState(this.doctorId);
}

class _CommonDiagnosisState extends State<CommonDiagnosis> {
  String doctorId;

  _CommonDiagnosisState(this.doctorId);

  List<Data> commonDiagnosisList = [];

  @override
  void initState() {
    super.initState();
    getCommonDiagnosisList();
  }

  getCommonDiagnosisList() async {
    var response = await HttpRequest.getInstance()
        .get(Api.getCommonDiagnosisTemplateApi + '?doctorId=$doctorId', {});
    var res = CommonDiagnosisModal.fromJson(response);
    if(res.code==200){
        commonDiagnosisList = res.data!;
        setState(() {});
    }
  }

  Widget _renderRow(BuildContext context, int index) {
    var item = commonDiagnosisList[index];
    List<Details> details = item.details!;
    // "diagnosisName": "跖趾关节结核",
    // "seqNo": 1,
    // "diagnosisId": 1,
    // "diagnosisCode": "A18.012+",
    details.sort((a,b)=>b.isMaster!-a.isMaster!);

    List<String> list =[];
    details.forEach((item) {
        if(item.isMaster==1){
         list.add('${item.diagnosisName}(主诊断)');
        }else{
          list.add('${item.diagnosisName}');
        }
    });
    String diagnosis=list.join('、');
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            // An action can be bigger than the others.
            // flex: 2,
            onPressed: (BuildContext context) async {
              var res = await HttpRequest.getInstance()
                  .post(Api.delTemplateApi, {'id': item.id});
              if (res['code'] == 200) {
                getCommonDiagnosisList();
              } else {
                ToastUtil.showToast(msg: res['msg']);
              }
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                const Icon(Icons.delete),
                Text('删除', style: TextStyle(fontSize:ScreenUtil().setSp(13.0))),
              ],
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdateCommonDiagnosis(doctorId: doctorId,id:item.id!,name:item.name!,diagnosis:item.details!, deptName: item.deptIdDictText!, deptId: item.deptId!,))).then((value) => getCommonDiagnosisList());

        },
        child:Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(width: 0.5, color: ColorsUtil.hexStringColor('#cccccc',alpha: 0.3)))
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(child:
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(item.name!,style: GSYConstant.textStyle(fontSize: 14.0,color: '#333333',fontFamily: 'Medium'),) ,
                      (item.deptIdDictText?.isNotEmpty)!?Container(
                        margin: const EdgeInsets.only(left: 8.0),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color:ColorsUtil.primaryColor),
                        ),
                        child: Text(item.deptIdDictText!,style: GSYConstant.textStyle(fontSize: 12.0,color:'#06b48d'),),
                      ):const SizedBox.shrink()
                    ],
                  ),
                  const SizedBox(height: 10.0,),
                  Flexible(child: Text(diagnosis,style: GSYConstant.textStyle(color: '#666666'),))
                ],
              ),),
              SvgUtil.svg('detail_arrow.svg')
            ],
          ),
        ))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar('常用诊断'),
        backgroundColor: ColorsUtil.bgColor,
        body: Column(children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Visibility(
                visible: commonDiagnosisList.isNotEmpty,
                child: Container(
                  height: 43.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '共',
                        style: GSYConstant.textStyle(
                            fontSize: 15.0, color: '#666666'),
                      ),
                      const SizedBox(
                        width: 3.0,
                      ),
                      Text(
                        commonDiagnosisList.length.toString(),
                        style: GSYConstant.textStyle(
                            fontSize: 15.0, color: '#f34c35'),
                      ),
                      const SizedBox(
                        width: 3.0,
                      ),
                      Text('条常用诊断',
                          style: GSYConstant.textStyle(
                              fontSize: 15.0, color: '#666666')),
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: commonDiagnosisList.isEmpty,
                  child: Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(147.0)),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SvgUtil.svg('no_data.svg'),
                        const SizedBox(
                          height: 14.0,
                        ),
                        Text(
                          '暂无诊断～',
                          style: GSYConstant.textStyle(
                              fontSize: 15.0, color: '#666666'),
                        )
                      ],
                    ),
                  )),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: commonDiagnosisList.length,
                  itemBuilder: _renderRow),
              Visibility(
                  visible: commonDiagnosisList.isNotEmpty,
                  child: Container(
                    height: 40.0,
                    // decoration: BoxDecoration(
                    //     color: Colors.white
                    // ),
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          '*',
                          style: GSYConstant.textStyle(
                              fontSize: 13.0, color: '#FE5A6B'),
                        ),
                        Text(
                          '操作提示：左滑删除常用诊断',
                          style: GSYConstant.textStyle(
                              fontSize: 13.0, color: '#666666'),
                        )
                      ],
                    ),
                  )),
            ]),
          )),
          // CustomSafeAreaButton(
          //     margin: const EdgeInsets.only(bottom: 16.0),
          //     custom: true,
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: <Widget>[
          //         SvgUtil.svg('increment.svg'),
          //         const SizedBox(
          //           width: 9.0,
          //         ),
          //         Text(
          //           '添加常用诊断',
          //           style: GSYConstant.textStyle(fontSize: 16.0),
          //         )
          //       ],
          //     ),
          //     onPressed: () {
          //       Navigator.push(context, MaterialPageRoute(builder: (contenxt)=>AddCommonDiagnosis()));
          //     })
        ]));
  }
}

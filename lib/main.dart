import 'package:flutter/material.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'home_screen.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseApp());

  String SECRET_ID = "SECRETID"; //永久密钥 secretId
  String SECRET_KEY = "SECRETKEY"; //永久密钥 secretKey

  Cos().initWithPlainSecret(SECRET_ID, SECRET_KEY);

  String region = "ap-guangzhou";
  // 创建 CosXmlServiceConfig 对象，根据需要修改默认的配置参数
  CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
      region: region,
      isDebuggable: true,
      isHttps: true,
  );
  // 注册默认 COS Service
  Cos().registerDefaultService(serviceConfig);

  // 创建 TransferConfig 对象，根据需要修改默认的配置参数
  // TransferConfig 可以设置智能分块阈值 默认对大于或等于2M的文件自动进行分块上传，可以通过如下代码修改分块阈值
  TransferConfig transferConfig = TransferConfig(
      forceSimpleUpload: false,
      enableVerification: true,
      divisionForUpload: 2097152, // 设置大于等于 2M 的文件进行分块上传
      sliceSizeForUpload: 1048576, //设置默认分块大小为 1M
  );
  // 注册默认 COS TransferManger
  await Cos().registerDefaultTransferManger(serviceConfig, transferConfig);

  CosTransferManger transferManager = Cos().getDefaultTransferManger();
  //CosTransferManger transferManager = Cos().getTransferManger("newRegion");
  // 存储桶名称，由 bucketname-appid 组成，appid 必须填入，可以在 COS 控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
  String bucket = "7419-1301953042";
  String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
  String srcPath = "本地文件的绝对路径"; //本地文件的绝对路径
  //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
  String? _uploadId;

  successCallBack() {
    // todo 上传成功后的逻辑
  }
  //上传失败回调
  failCallBack(clientException, serviceException) {
    // todo 上传失败后的逻辑
    if (clientException != null) {
      debugPrint(clientException);
    }
    if (serviceException != null) {
      debugPrint(serviceException);
    }
  }

  transferManager.upload(bucket, cosPath,
      filePath: srcPath,
      uploadId: _uploadId
  );

}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '智能记账本',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

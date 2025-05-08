import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioFilePickerService{

 static Future<void> _requestPermission()async{
    await Permission.storage.request();
    await Permission.audio.request();
  }

  static Future<String?> pickedFile()async{
   await _requestPermission();
   FilePickerResult? result =  await FilePicker.platform.pickFiles(
       type: FileType.audio
     );

   if(result !=null && result.files.single.path !=null){
     return result.files.single.path!;
   }
   return null;
   }




}
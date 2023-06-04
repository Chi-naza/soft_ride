import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestMethods {

  static Future<dynamic> receiveRequest(String url) async {
    
    http.Response httpResponse = await http.get(Uri.parse(url));

    try {
      //successful
      if(httpResponse.statusCode == 200) {
        String responseData = httpResponse.body; //json
        var decodeResponseData = jsonDecode(responseData);
        return decodeResponseData;
      }else {
        return "Error Occurred, Failed. No Response.";
      }
    }
    catch(exp) {
      return "Error Occurred, Failed. No Response.";
    }
  }
}
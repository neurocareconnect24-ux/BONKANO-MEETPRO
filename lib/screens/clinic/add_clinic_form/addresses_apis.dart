import 'package:nb_utils/nb_utils.dart';
import '../../../network/network_utils.dart';
import '../../../utils/api_end_points.dart';
import 'model/city_list_response.dart';
import 'model/country_list_response.dart';
import 'model/state_list_response.dart';

class UserAddressesApis {
  static Future<List<CountryData>> getCountryList({String searchTxt = ''}) async {
    String search = searchTxt.isNotEmpty ? 'search=$searchTxt' : '';
    var res = CountryListResponse.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.countryList}?$search", method: HttpMethodType.GET)));
    return res.data.validate();
  }

  static Future<List<StateData>> getStateList({required int countryId, String searchTxt = ''}) async {
    String search = searchTxt.isNotEmpty ? '&search=$searchTxt' : '';
    var res = StateListResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.stateList}?country_id=$countryId$search', method: HttpMethodType.GET)));
    return res.data.validate();
  }

  static Future<List<CityData>> getCityList({required int stateId, String searchTxt = ''}) async {
    String search = searchTxt.isNotEmpty ? '&search=$searchTxt' : '';
    var res = CityListResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.cityList}?state_id=$stateId$search', method: HttpMethodType.GET)));
    return res.data.validate();
  }
}

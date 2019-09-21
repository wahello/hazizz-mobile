
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/managers/preference_services.dart';

import 'item_list_picker_bloc/item_list_picker_bloc.dart';

class PickedStartPageEvent extends ItemListEvent {
  final String item;
  PickedStartPageEvent({this.item})
      : assert(item != null), super([item]);
  @override
  String toString() => 'PickedStartPageEvent';
}

class StartPageLoadDataEvent extends ItemListEvent {
  StartPageLoadDataEvent();

  @override
  String toString() => 'StartPageLoadDataEvent';
}

//endregion

//region SubjectItemListStates
class PickedStartPageState extends ItemListState {
  final String item;
  PickedStartPageState({this.item})
      : assert(item != null), super([item]);
  @override
  String toString() => 'PickedStartPageState';
}
//endregion


class StartPageItemPickerBloc extends ItemListPickerBloc {
  List<String> dataList;

  @override
  Stream<ItemListState> mapEventToState(ItemListEvent event) async*{
    if(event is PickedStartPageEvent){
      HazizzLogger.printLog("log: PickedState is played");
      yield PickedStartPageState();
    }
    if (event is StartPageLoadDataEvent) {
      try {
        yield Waiting();
        /*
        List<StartPageItem> responseData = StartPageService.getStartPages(context);
        HazizzLogger.printLog("log: responseData: ${responseData}");
        HazizzLogger.printLog("log: responseData type:  ${responseData.runtimeType.toString()}");
        */
        /*
        if(responseData is List<PojoSubject>){
          dataList = responseData;
          if(dataList.isNotEmpty) {
            HazizzLogger.printLog("log: response is List");
            yield ItemListLoaded(data: responseData);
          }else{
            yield Empty();
          }
        }
        */
      } on Exception catch(e){
        HazizzLogger.printLog("log: Exception: ${e.toString()}");
      }
    }
    super.mapEventToState(event);
  }

  @override
  // TODO: implement initialState
  ItemListState get initialState => Empty();
}
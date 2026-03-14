import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment_profile.dart';


//gives ski equipment to all files that need it
final equipmentProvider = NotifierProvider<EquipmentNotifier, List<EquipmentProfile>>(() {
  return EquipmentNotifier();
});

//this class holds list of equipment profiles
//and tells riverpod to check it for updates
class EquipmentNotifier extends Notifier<List<EquipmentProfile>> {
  
  
  //loads mock setups into memory
  @override
  List<EquipmentProfile> build() {
    return [
      EquipmentProfile(
        id: '1',
        name: 'Fischer SL',
        description: 'Swix Blue Wax',
      ),
      EquipmentProfile(
        id: '2',
        name: 'Rossignol GS',
        description: 'Swix Red Wax',
      ),
    ];
  }

  //adds a new profile to the list by creating a new list and adding the new
  //setup to the end, then replaces the old list
  void addProfile(String name, String description) {
    final newProfile = EquipmentProfile(
      //create iD for the profile using the timestamp
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
    );
    //updates the state with the new profile
    state = [...state, newProfile];
  }

  // checks list for the ID #s and makes a new list with all 
  //of the ids that dont match the one we want deleted
  void deleteProfile(String id) {
    state = state.where((profile) => profile.id != id).toList();
  }
}
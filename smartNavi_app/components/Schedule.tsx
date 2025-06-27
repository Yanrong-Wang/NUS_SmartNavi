import React, { useState } from 'react';
import { Picker } from '@react-native-picker/picker';
import { View, Button, TouchableOpacity, Platform, Modal, FlatList} from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { ThemedTextInput } from '@/components/ThemedTextInput';
import { Router } from 'expo-router';
import { ScheduleItem } from '@/components/NavigationContext';
import { ThemedView } from '@/components/ThemedView';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from 'react-native';

const STOPS = [
  "Central Library",
  "Yusof Ishak House",
  "University Hall",
  "Opp University Hall",
  "LT27",
  "S17",
  "Kent Ridge MRT",
  "Opp Kent Ridge MRT",
  "University Town",
  "Prince George's Park Foyer",
  "Prince George's Park",
  "Opp HSSML",
  "BIZ2",
  "COM3",
  "Museum",
];

type ScheduleScreenProps = {
  schedule: ScheduleItem[];
  setSchedule: React.Dispatch<React.SetStateAction<ScheduleItem[]>>;
  setTo: (location: string) => void;
  router: Router;
};

export default function ScheduleScreen({schedule, setSchedule, setTo, router}:ScheduleScreenProps){
    const colorScheme = useColorScheme() ?? 'light';
    // Define the correct colors based on the theme & use it inside modal
    const modalBackgroundColor = Colors[colorScheme].background;
    const modalTextColor = Colors[colorScheme].text;

    // data of newly created events
    const [modalVisible, setModalVisible] = useState(false);
    const [eventName, seteventName] = useState('');
    const [eventTime, seteventTime] = useState('');
    const [eventLocation, seteventLocation] = useState('');

    const addSchedule = () => {
        if (!eventName || !eventTime ||!eventLocation) return;
        setSchedule([
            ...schedule,
            {
                id: Date.now().toString(),
                name: eventName,
                time: eventTime,
                location: eventLocation,
            },
        ]);

        // Clear data and close modal
        setModalVisible(false);
        seteventTime('');
        seteventName('');
        seteventLocation('');
    };

        const pressSchedule = (location: string) => {
            setTo(location);
            router.push('/(tabs)');
        };

        return (
            <ThemedView style={{ padding: 20, paddingTop: 60 }}>
                <ThemedText style={{ fontSize: 24, fontWeight: 'bold', marginBottom: 20 }}>Schedule</ThemedText>
                <FlatList
                    data = {schedule}
                    keyExtractor = {(item) => item.id}
                    renderItem = {({ item }) => (
                        <TouchableOpacity onPress = {() => pressSchedule(item.location)}
                            style = {{ padding: 10}}>
                            <ThemedText style = {{ fontSize: 18 }}>{item.name}</ThemedText>
                            <ThemedText style = {{ fontSize: 16 }}>{item.time}</ThemedText>
                            <ThemedText style = {{ fontSize: 16 }}>{item.location}</ThemedText>
                        </TouchableOpacity>
                    )}
                    ListEmptyComponent={<ThemedText style={{ fontSize: 18 }}>No schedules yet.</ThemedText>}
                    />
                    <ThemedView style={{ marginTop: 20 }}>
                        <Button title="+ Add Schedule" onPress={() => setModalVisible(true)} />
                    </ThemedView>

                    {/* modal for adding a new event */}
                    <Modal visible = {modalVisible} animationType="slide" transparent={true}>
                        <View style = {{flex: 1, justifyContent: 'center'}}>
                            <View style = {{
                                backgroundColor: modalBackgroundColor,
                                padding: 20, borderRadius: 10}}>
                                <ThemedText style = {{ fontSize: 24, fontWeight: 'bold'}}>Add Schedule</ThemedText>
                                <ThemedTextInput
                                    placeholder = "Event Name"
                                    value = {eventName}
                                    onChangeText = {seteventName}
                                    style = {{padding: 10}}
                                />
                                <ThemedTextInput
                                    placeholder = "Event Time"
                                    value = {eventTime}
                                    onChangeText = {seteventTime}
                                    style = {{padding: 10}}
                                />
                                <Picker
                                    selectedValue = {eventLocation}
                                    onValueChange = {seteventLocation}
                                    itemStyle={{ color: modalTextColor }}
                                >
                                    <Picker.Item label = "Select Location" value = "" />
                                    {STOPS.map((stop) => (
                                        <Picker.Item key = {stop} label = {stop} value = {stop} />
                                    ))}
                                </Picker>
                                <View style = {{ flexDirection: 'row', justifyContent: 'flex-end', marginTop: 20}}>
                                    <Button title = "Cancel" onPress = {() => setModalVisible(false)} />
                                    <ThemedView style = {{ width: 10 }} />
                                    <Button title = "Add" onPress = {addSchedule} disabled = {!eventName || !eventTime || !eventLocation} />
                                </View>
                            </View>
                        </View>
                    </Modal>
                </ThemedView>
            );
        }

const styles = StyleSheet.create({
  container: {
    padding: 20,
    paddingTop: 60,
    flex: 1,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  contentContainer: {
    flex: 1,
  },
  scheduleItem: {
    padding: 20,
    marginBottom: 15,
    backgroundColor: '#f5f5f5',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  eventName: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  eventTime: {
    fontSize: 18,
    color: '#666',
    marginBottom: 6,
  },
  eventLocation: {
    fontSize: 18,
    color: '#888',
  },
  emptyText: {
    color: 'black',
    fontSize: 16,
    textAlign: 'center',
    marginTop: 20,
  },
  addButtonContainer: {
    paddingVertical: 15,
    paddingHorizontal: 20,
    paddingBottom: 100,
    backgroundColor: 'white',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },
  addButton: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  addButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  modalContainer: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  modalContent: {
    margin: 20,
    padding: 20,
    backgroundColor: 'white',
    borderRadius: 10,
  },
  modalTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  input: {
    padding: 15,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 5,
    marginBottom: 15,
    fontSize: 16,
  },
  picker: {
    height: 50,
    marginBottom: 20,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    marginTop: 20,
  },
  buttonSpacer: {
    width: 10,
  },
});


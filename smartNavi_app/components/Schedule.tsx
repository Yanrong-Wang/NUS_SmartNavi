import React, { useState } from 'react';
import { Picker } from '@react-native-picker/picker';
import { View, Text, Button, TextInput, TouchableOpacity, Platform, Modal, FlatList, StyleSheet} from 'react-native';
import { Router } from 'expo-router';
import { ScheduleItem } from '@/components/NavigationContext';

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
            <View style={styles.container}>
                <Text style={styles.title}>Schedule</Text>
                <View style={styles.contentContainer}>
                    <FlatList
                        data = {schedule}
                        keyExtractor = {(item) => item.id}
                        renderItem = {({ item }) => (
                            <TouchableOpacity onPress = {() => pressSchedule(item.location)}
                                style = {styles.scheduleItem}>
                                <Text style = {styles.eventName}>{item.name}</Text>
                                <Text style = {styles.eventTime}>{item.time}</Text>
                                <Text style = {styles.eventLocation}>{item.location}</Text>
                            </TouchableOpacity>
                        )}
                        ListEmptyComponent={<Text style={styles.emptyText}>No schedules yet.</Text>}
                        showsVerticalScrollIndicator={false}
                        />
                </View>
                <View style={styles.addButtonContainer}>
                    <TouchableOpacity style={styles.addButton} onPress={() => setModalVisible(true)}>
                        <Text style={styles.addButtonText}>+ Add Schedule</Text>
                    </TouchableOpacity>
                </View>

                {/* modal for adding a new event */}
                <Modal visible = {modalVisible} animationType="slide">
                    <View style = {styles.modalContainer}>
                        <View style = {styles.modalContent}>
                            <Text style = {styles.modalTitle}>Add Schedule</Text>
                            <TextInput
                                placeholder = "Event Name"
                                value = {eventName}
                                onChangeText = {seteventName}
                                style = {styles.input}
                            />
                            <TextInput
                                placeholder = "Event Time"
                                value = {eventTime}
                                onChangeText = {seteventTime}
                                style = {styles.input}
                            />
                            <Picker
                                selectedValue = {eventLocation}
                                onValueChange = {seteventLocation}
                                style = {Platform.OS === 'android' ? styles.picker : undefined}
                            >
                                <Picker.Item label = "Select Location" value = "" />
                                {STOPS.map((stop) => (
                                    <Picker.Item key = {stop} label = {stop} value = {stop} />
                                ))}
                            </Picker>
                            <View style = {styles.buttonContainer}>
                                <Button title = "Cancel" onPress = {() => setModalVisible(false)} />
                                <View style = {styles.buttonSpacer} />
                                <Button title = "Add" onPress = {addSchedule} disabled = {!eventName || !eventTime || !eventLocation} />
                            </View>
                        </View>
                    </View>
                </Modal>
            </View>
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


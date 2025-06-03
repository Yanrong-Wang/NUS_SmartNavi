import React, { useState } from 'react';
import { Picker } from '@react-native-picker/picker';
import { View, Text, Button, TextInput, TouchableOpacity, Platform, Modal, FlatList} from 'react-native';

const STOPS = [
  "Central Library",
  "Yusof Ishak House",
  "Univeristy Hall",
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
];

export default function ScheduleScreen({schedule, setSchedule, setTo, navigation}){
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

        const pressSchedule = (location) => {
            setTo(location);
            navigation.navigate('Home');
        };

        return (
            <View style = {{ padding:20}}>
                <Text style = {{ fontSize: 24, fontWeight: 'bold', marginBottom:20 }}>Schedule</Text>
                <FlatList
                    data = {schedule}
                    keyExtractor = {(item) => item.id}
                    renderItem = {({ item }) => (
                        <TouchableOpacity onPress = {() => pressSchedule(item.location)}
                            style = {{ padding: 10}}>
                            <Text style = {{ fontSize: 18 }}>{item.name}</Text>
                            <Text style = {{ fontSize: 16 }}>{item.time}</Text>
                            <Text style = {{ fontSize: 16 }}>{item.location}</Text>
                        </TouchableOpacity>
                    )}
                    ListEmptyComponent={<Text style={{ color: 'black' }}>No schedules yet.</Text>}
                    />
                    <View style={{ marginTop: 20 }}>
                        <Button title="+ Add Schedule" onPress={() => setModalVisible(true)} />
                    </View>

                    {/* modal for adding a new event */}
                    <Modal visible = {modalVisible} animationType="slide">
                        <View style = {{flex: 1, justifyContent: 'center'}}>
                            <View style = {{padding: 20, backgroundColor: 'white', borderRadius: 10}}>
                                <Text style = {{ fontsize: 24, fontWeight: 'bold'}}>Add Schedule</Text>
                                <TextInput
                                    placeholder = "Event Name"
                                    value = {eventName}
                                    onChangeText = {seteventName}
                                    style = {{padding: 10}}
                                />
                                <TextInput
                                    placeholder = "Event Time"
                                    value = {eventTime}
                                    onChangeText = {seteventTime}
                                    style = {{padding: 10}}
                                />
                                <Picker
                                    selectedValue = {eventLocation}
                                    onValueChange = {seteventLocation}
                                    style = {Platform.OS === 'android' ? { height: 50 }: undefined}
                                >
                                    <Picker.Item label = "Select Location" value = "" />
                                    {STOPS.map((stop) => (
                                        <Picker.Item key = {stop} label = {stop} value = {stop} />
                                    ))}
                                </Picker>
                                <View style = {{ flexDirection: 'row', justifyContent: 'flex-end', marginTop: 20}}>
                                    <Button title = "Cancel" onPress = {() => setModalVisible(false)} />
                                    <View style = {{ width: 10 }} />
                                    <Button title = "Add" onPress = {addSchedule} disabled = {!eventName || !eventTime || !eventLocation} />
                                </View>
                            </View>
                        </View>
                    </Modal>
                </View>
            );
        }
    

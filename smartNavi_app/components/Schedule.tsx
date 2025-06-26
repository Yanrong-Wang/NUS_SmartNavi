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


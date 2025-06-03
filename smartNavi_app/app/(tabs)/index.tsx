import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import ScheduleScreen from '@/components/Schedule';
import HomeScreen from '@/components/HomeScreen';

const tab = createBottomTabNavigator();

export default function App(){
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [error, setError] = useState('');
  const [schedule, setSchedule] = useState([]);

  return (
    <NavigationContainer>
      <tab.Navigator>
        <tab.Screen name = "Home" options = {{tabBarLabel: 'Home'}}>
          {props => (
            <HomeScreen
              {...props}
              from = {from}
              setFrom = {setFrom}
              to = {to}
              setTo = {setTo}
              error = {error}
              setError = {setError}
            />
          )}
        </tab.Screen>
        <tab.Screen name = "schedule" options = {{tabBarLabel: 'Schedule'}}>
          {props => (
            <ScheduleScreen
              {...props}
              schedule = {schedule}
              setSchedule = {setSchedule}
              setTo = {setTo}
            />
          )}
        </tab.Screen>
      </tab.Navigator>
    </NavigationContainer>
  );
}



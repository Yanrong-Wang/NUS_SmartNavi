import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { Platform } from 'react-native';
import RouteSearch from '@/components/Route_Search';
import busRoutes from '@/constants/busRoutes';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import schedule from '@/components/schedule';

const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [error, setError] = useState('');
  const [schedule, setSchedule] = useState('');
  
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name = "Home">
          {Props => (
            <HomeScreen
              {...Props}
              from = {from}
              setFrom = {setFrom}
              to = {to}
              setTo = {setTo}
              error = {error}
              setError = {setError}
              schedule = {schedule}
              setSchedule = {setSchedule}
            />
          )}
        </Stack.Screen>
        <Stack.Screen name = "schedule">
          {props => (
            <ScheduleScreen>
              {...props}
              schedule = {schedule}
              setSchedule = {setSchedule}
              setTo = {setTo}
            />
          )}
        </Stack.Screen)
      </Stack.Navigator>
    </NavigationContainer>
  );


const Stack = createStackNavigator()


/*import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import ScheduleScreen from '@/components/Schedule';
import { ScheduleItem } from '@/components/Schedule';
import HomeScreen from '@/components/HomeScreen';

const tab = createBottomTabNavigator();

export default function App(){
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [error, setError] = useState('');
  const [schedule, setSchedule] = useState<ScheduleItem[]>([]);

  return (
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
  );
}*/
// app/(tabs)/index.tsx

import React from 'react';
import HomeScreen from '@/components/HomeScreen';
import { useNavigationContext } from '@/components/NavigationContext';

export default function IndexScreen() {
  const {
    from,
    setFrom,
    to,
    setTo,
    error,
    setError
  } = useNavigationContext();

  return (
    <HomeScreen
      from={from}
      setFrom={setFrom}
      to={to}
      setTo={setTo}
      error={error}
      setError={setError}
    />
  );
}



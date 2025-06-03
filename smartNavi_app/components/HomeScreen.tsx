import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { Platform } from 'react-native';
import RouteSearch from '@/components/Route_Search';
import busRoutes from '@/constants/busRoutes';

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

// usestate is extracted to the App level 
// use props to pass down state
export default function HomeScreen({to, setTo, from , setFrom, error, setError}){
    function handleOrigin(value: string) {
    setFrom(value);
    if (value === to && value) {
      setError('Origin and destination cannot be the same!');
    } else {
      setError('');
    }
  }

  function handleDestination(value: string) {
    setTo(value);
    if (from === value && value) {
      setError('Origin and destination cannot be the same!');
    } else {
      setError('');
    }
  }

  // Display main page: origin and destination selection
  return (
    <View style={styles.container}>
      <Text style={styles.heading}>NUS SmartNavi: Pick Route</Text>
      <View style={styles.pickerContainer}>
        <Text>Origin:</Text>
        <Picker
          selectedValue={from}
          onValueChange={handleOrigin}
          style={Platform.OS === 'android' ? styles.picker : undefined}
        >
          <Picker.Item label="Select" value="" />
          {STOPS.map(stop => (
            (stop === from || stop !== to) && (
              <Picker.Item key={stop} label={stop} value={stop} />
            )
          ))}
        </Picker>
      </View>

      <View style={styles.pickerContainer}>
        <Text>Destination:</Text>
        <Picker
          selectedValue={to}
          onValueChange={handleDestination}
          style={Platform.OS === 'android' ? styles.picker : undefined}
        >
          <Picker.Item label="Select" value="" />
          {STOPS.map(stop => (
            (stop === to || stop !== from) && (
              <Picker.Item key={stop} label={stop} value={stop} />
            )
          ))}
        </Picker>
      </View>

      {error.length > 0 && (
        <Text style={styles.error}>{error}</Text>
      )}

      <RouteSearch from={from} to={to} disabled={!!error || !from || !to} />
    </View>
  );
}
  
const styles = StyleSheet.create({
  container: {
    marginTop: 40,
    padding: 30,
  },
  heading: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  pickerContainer: {
    marginBottom: 20,
  },
  picker: {
    height: 50,
  },
  error: {
    color: 'red',
    marginBottom: 10,
  },
});
  

  
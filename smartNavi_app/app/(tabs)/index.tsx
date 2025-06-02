import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import RouteSearch from './components/ui/Route_Search';
import busRoutes from './constants/Bus_Route';

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

export default function App() {
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [error, setError] = useState('');

  function handleFromChange(value: string) {
    setFrom(value);
    if (value === to && value) {
      setError('Origin and destination cannot be the same!');
    } else {
      setError('');
    }
  }

  function handleToChange(value: string) {
    setTo(value);
    if (from === value && value) {
      setError('Origin and destination cannot be the same!');
    } else {
      setError('');
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>NUS SmartNavi: Pick Route</Text>

      <View style={styles.pickerContainer}>
        <Text>Origin:</Text>
        <Picker
          selectedValue={from}
          onValueChange={handleFromChange}
          style={styles.picker}
        >
          <Picker.Item label="--Select--" value="" />
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
          onValueChange={handleToChange}
          style={styles.picker}
        >
          <Picker.Item label="--Select--" value="" />
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
    padding: 30,
    backgroundColor: '#fff',
    flex: 1,
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
    width: '100%',
  },
  error: {
    color: 'red',
    marginBottom: 10,
  },
});

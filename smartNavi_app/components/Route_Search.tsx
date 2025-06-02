import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import busRoutes from '@/constants/busRoutes';

type RouteSearchProps = {
  from: string;
  to: string;
  disabled?: boolean;
};

export default function RouteSearch({ from, to, disabled }: RouteSearchProps) {
  const [result, setResult] = useState('');
  const [searched, setSearched] = useState(false);

  function searchRoute() {
    setSearched(true);
    if (!from || !to || from === to) {
      setResult('Please select both origin and destination, and make sure they are different.');
      return;
    }

    const found = busRoutes.filter(route => {
      const fromIdx = route.stops.indexOf(from);
      const toIdx = route.stops.indexOf(to);
      return fromIdx !== -1 && toIdx !== -1 && fromIdx < toIdx;
    });

    if (found.length > 0) {
      setResult(
        `Recommended Bus Route${found.length > 1 ? 's' : ''}: ${found
          .map(r => r.routeName)
          .join(', ')}`
      );
    } else {
      setResult('No direct bus route found for the selected stops.');
    }
  }

  return (
    <View style={styles.container}>
      <Button title="Search" disabled={disabled} onPress={searchRoute} />
      {searched && (
        <Text style={styles.resultText}>{result}</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginTop: 20,
  },
  resultText: {
    minHeight: 32,
    marginTop: 14,
    fontSize: 16,
    color: '#333',
  },
});

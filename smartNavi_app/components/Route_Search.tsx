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

  function findRoute() {
    setSearched(true);
    if (!from || !to || from === to) {
      setResult('Please select both origin and destination, and make sure they are different.');
      return;
    }

    const searchResult = busRoutes.filter(route => {
      const fromIndex = route.stops.indexOf(from);
      const toIndex = route.stops.indexOf(to);
      return fromIndex !== -1 && toIndex !== -1 && fromIndex < toIndex;
    });

    if (searchResult.length > 0) {
      setResult(
        `Recommended Bus Route${searchResult.length > 1 ? 's' : ''}: ${searchResult
          .map(r => r.routeName)
          .join(', ')}`
      );
    } else {
      setResult('No direct bus route found for the selected stops.');
    }
  }

  return (
    <View style={styles.container}>
      <Button title="Search" disabled={disabled} onPress={findRoute} />
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
    marginTop: 20,
    fontSize: 16,
    color: 'black',
  },
});

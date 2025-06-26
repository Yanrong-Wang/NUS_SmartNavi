import React from 'react';
import { TextInput, type TextInputProps, useColorScheme } from 'react-native';
import { Colors } from '@/constants/Colors';

export function ThemedTextInput(props: TextInputProps) {
  // Get the current color scheme (light or dark)
  const colorScheme = useColorScheme();

  const { style, ...otherProps } = props;

// Text color based on the color scheme
  const color = colorScheme === 'dark' ? Colors.dark.text : Colors.light.text;

  // Placeholder text color based on the color scheme
  const placeholderTextColor = colorScheme === 'dark' ? 'rgba(235, 235, 245, 0.6)' : '#8A8A8E';

  return (
    <TextInput
      placeholderTextColor={placeholderTextColor}
      {...otherProps}
      style={[{ color }, style]}
    />
  );
}


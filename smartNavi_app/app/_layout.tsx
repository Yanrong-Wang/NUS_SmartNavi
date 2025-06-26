import { useMemo } from 'react';
import { Colors } from '@/constants/Colors';
import { ThemeProvider, Theme } from '@react-navigation/native';
import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useColorScheme } from 'react-native';
import 'react-native-reanimated';

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const [loaded] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
  });

  if (!loaded) {
    // Async font loading only occurs in development.
    return null;
  }

  const theme: Theme = useMemo(
    () => 
      colorScheme === "light"
        ? ({
            dark: false,
            colors: {
              primary: Colors.light.tint,
              background: Colors.light.background, 
              card: Colors.light.background,
              text: Colors.light.text,
              border: '#c7c7c7',
              notification: 'rgb(255, 59, 48)',
            },
            fonts: {},
          } as Theme)
        : ({
            dark: true,
            colors: {
              primary: Colors.dark.tint,
              background: Colors.dark.background, 
              card: Colors.dark.background,
              text: Colors.dark.text,
              border: '#444444',
              notification: 'rgb(255, 69, 58)',
        },
        fonts: {},
      } as Theme),
  [colorScheme]
);

  return (
    <ThemeProvider value={theme}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="+not-found" />
      </Stack>
      <StatusBar style={colorScheme === 'dark' ? 'light' : 'dark'} />
    </ThemeProvider>
  );
}

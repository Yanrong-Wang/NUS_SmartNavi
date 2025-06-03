import React, { createContext, useContext, useState } from 'react';

export type ScheduleItem = {
    id: string;
    name: string;
    time: string;
    location: string;
};

interface NavigationContextType {
  from: string;
  setFrom: (value: string) => void;
  to: string;
  setTo: (value: string) => void;
  error: string;
  setError: (value: string) => void;
  schedule: ScheduleItem[];
  setSchedule: React.Dispatch<React.SetStateAction<ScheduleItem[]>>;
}

const NavigationContext = createContext<NavigationContextType | undefined>(undefined);

export const NavigationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [error, setError] = useState('');
  const [schedule, setSchedule] = useState<ScheduleItem[]>([]);

  return (
    <NavigationContext.Provider value={{
      from,
      setFrom,
      to,
      setTo,
      error,
      setError,
      schedule,
      setSchedule
    }}>
      {children}
    </NavigationContext.Provider>
  );
};

export const useNavigationContext = () => {
  const context = useContext(NavigationContext);
  if (context === undefined) {
    throw new Error('useNavigationContext must be used within a NavigationProvider');
  }
  return context;
}; 
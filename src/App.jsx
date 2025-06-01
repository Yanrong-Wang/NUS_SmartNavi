import React, { useState } from "react";
import RouteSearch from "./components/Route_search";
import busRoutes from "./components/Bus_route";  

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
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [error, setError] = useState("");

  function handleFromChange(value) {
    setFrom(value);
    if (value === to && value) {
      setError("Origin and destination cannot be the same!");
    } else {
      setError("");
    }
  }
  function handleToChange(value) {
    setTo(value);
    if (from === value && value) {
      setError("Origin and destination cannot be the same!");
    } else {
      setError("");
    }
  }

  return (
  <div style={{ padding: 30 }}>
    <h2>NUS SmartNavi: Pick Route</h2>
    <div style={{ marginBottom: 20 }}>
      <label>
        Origin:
        <select value={from} onChange={e => handleFromChange(e.target.value)}>
          <option value="">--Select--</option>
          {STOPS.map(stop => (
            (stop === from || stop !== to) ? (
              <option key={stop} value={stop}>{stop}</option>
            ) : null
          ))}
        </select>
      </label>
    </div>

    <div style={{ marginBottom: 20 }}>
      <label>
        Destination:
        <select value={to} onChange={e => handleToChange(e.target.value)}>
          <option value="">--Select--</option>
          {STOPS.map(stop => (
            (stop === to || stop !== from) ? (
              <option key={stop} value={stop}>{stop}</option>
            ) : null
          ))}
        </select>
      </label>
    </div>

    {/* Display Error */}
    {error && (
      <div style={{ color: "red", marginTop: 10 }}>
        {error}
      </div>
    )}

    <RouteSearch from={from} to={to} disabled={!!error || !from || !to} />
  </div>
  );
}

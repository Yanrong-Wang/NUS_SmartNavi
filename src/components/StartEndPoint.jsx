import React, { useState } from "react";
const STOPS = [
  "Central Library",
  "Yusof Ishak House",
  "LT27",
  "S17",
  "Kent Ridge MRT",
  "Opp Kent Ridge MRT",
  "University Town",
  "PGP Foyer",
  "Prince Georgia's Park",
  "BIZ2",
  "COM3",
];
export default function App() {
    const [from, setFrom] = useState("");
    const [to, setTo] = useState("");
    const [error, setError] = useState("");

    function handleToChange(e) {
        setTo(e.target.value);
        if (from === e.target.value && e.target.value) {
            setError("Origin and destination cannot be the same!");
        } else {
            setError("");
    }
  }

    function handleFromChange(e) {
      setFrom(e.target.value);
      if (e.target.value === to && e.target.value) {
        setError("Origin and destination cannot be the same!");
    } else {
        setError("");
    }
  }

 return (
    <div style={{ padding: 40, maxWidth: 400 }}>
      <h2>NUS SmartNavi: Pick Route</h2>
      <div style={{ marginBottom: 20 }}>
        <label>
          Origin:
          <select value={from} onChange={handleFromChange}>
            <option value="">--Select--</option>
            {STOPS.map(stop =>
              stop !== to ? (
                <option key={stop} value={stop}>
                  {stop}
                </option>
              ) : null
            )}
          </select>
        </label>
      </div>
      <div style={{ marginBottom: 20 }}>
        <label>
          Destination:
          <select value={to} onChange={handleToChange}>
            <option value="">--Select--</option>
            {STOPS.map(stop =>
              stop !== from ? (
                <option key={stop} value={stop}>
                  {stop}
                </option>
              ) : null
            )}
          </select>
        </label>
      </div>
      {error && (
        <div style={{ color: "red", marginTop: 10 }}>
          {error}
        </div>
      )}
    </div>
  );
}
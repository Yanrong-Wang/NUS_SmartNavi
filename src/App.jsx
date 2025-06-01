import React, { useState } from "react";
import StopSelector from "./components/Bus_route";
import RouteSearch from "./components/Route_search";

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
    <div style={{ padding: 40, maxWidth: 400 }}>
      <h2>NUS SmartNavi: Pick Route</h2>
      <StopSelector
        stops={STOPS}
        from={from}
        to={to}
        setFrom={handleFromChange}
        setTo={handleToChange}
        error={error}
      />
      <Route_search from={from} to={to} disabled={!!error || !from || !to} />
    </div>
  );
}import StartEndPoint from "./components/StartEndPoint";

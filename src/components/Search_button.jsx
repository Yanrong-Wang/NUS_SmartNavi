export default function RouteSearch({ from, to, disabled }) {
  const [result, setResult] = useState("");
  const [searched, setSearched] = useState(false);

  function searchRoute() {
    setSearched(true);
    if (!from || !to || from === to) {
      setResult("Please select both origin and destination, and make sure they are different.");
      return;
    }

    // Search for direct routes
    const found = busRoutes.filter(route => {
      const fromIdx = route.stops.indexOf(from);
      const toIdx = route.stops.indexOf(to);
      return fromIdx !== -1 && toIdx !== -1 && fromIdx < toIdx;
    });

    if (found.length > 0) {
      setResult(
        `Recommended Bus Route${found.length > 1 ? "s" : ""}: ${found
          .map(r => r.routeName)
          .join(", ")}`
      );
    } else {
      setResult("No direct bus route found for the selected stops.");
    }
  }

  
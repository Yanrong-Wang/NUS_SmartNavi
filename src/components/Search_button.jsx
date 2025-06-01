export default function RouteSearch({ from, to, disabled }) {
  const [result, setResult] = useState("");
  const [searched, setSearched] = useState(false);

  function searchRoute() {
    setSearched(true);
    if (!from || !to || from === to) {
      setResult("Please select both origin and destination, and make sure they are different.");
      return;
    }
    
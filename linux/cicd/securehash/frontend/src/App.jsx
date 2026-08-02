import { useState } from 'react'
import axios from 'axios'


const API_URL =
  import.meta.env.VITE_API_URL || '/api'


function App() {
  const [password, setPassword] = useState('')
  const [result, setResult] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')


  async function generateHash() {
    if (!password.trim()) {
      setError('Najpierw wpisz hasło.')
      return
    }

    setLoading(true)
    setError('')
    setResult(null)

    try {
      const response = await axios.post(
        `${API_URL}/hash`,
        {
          password: password
        }
      )

      setResult(response.data)
    } catch (requestError) {
      console.error(requestError)

      setError(
        'Nie udało się połączyć z backendem. Sprawdź stan kontenerów frontend i backend.'
      )
    } finally {
      setLoading(false)
    }
  }


  function handleKeyDown(event) {
    if (event.key === 'Enter' && !loading) {
      generateHash()
    }
  }


  return (
    <main
      style={{
        maxWidth: '850px',
        margin: '60px auto',
        padding: '30px',
        background: 'white',
        borderRadius: '12px',
        boxShadow: '0 4px 16px rgba(0, 0, 0, 0.1)'
      }}
    >
      <h1>SecureHash Portal v1.1.1</h1>

      <p>
        Wpisz przykładowe hasło. Backend wykona kosztowne
        obliczeniowo hashowanie bcrypt.
      </p>

      <div
        style={{
          display: 'flex',
          gap: '10px',
          marginTop: '25px'
        }}
      >
        <input
          type="password"
          placeholder="Wpisz testowe hasło"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          onKeyDown={handleKeyDown}
          disabled={loading}
          style={{
            flex: 1,
            padding: '12px',
            border: '1px solid #cccccc',
            borderRadius: '6px'
          }}
        />

        <button
          onClick={generateHash}
          disabled={loading}
          style={{
            padding: '12px 20px',
            border: 'none',
            borderRadius: '6px',
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          {loading ? 'Hashowanie...' : 'Generuj hash'}
        </button>
      </div>

      {error && (
        <p
          style={{
            marginTop: '20px',
            color: '#b00020'
          }}
        >
          {error}
        </p>
      )}

      {result && (
        <section
          style={{
            marginTop: '30px',
            paddingTop: '20px',
            borderTop: '1px solid #dddddd'
          }}
        >
          <h2>Wynik</h2>

          <p>
            <strong>Czas:</strong> {result.time_ms} ms
          </p>

          <p>
            <strong>Host/pod:</strong> {result.pod}
          </p>

          <label htmlFor="hash-result">
            <strong>Hash bcrypt:</strong>
          </label>

          <textarea
            id="hash-result"
            rows="5"
            value={result.hash}
            readOnly
            style={{
              width: '100%',
              marginTop: '10px',
              padding: '12px',
              resize: 'vertical'
            }}
          />
        </section>
      )}
    </main>
  )
}


export default App

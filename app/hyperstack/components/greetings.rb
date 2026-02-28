class Greetings < HyperComponent
  before_mount do
    @time = Time.now
  end

  after_mount do
    every(1) { mutate @time = Time.now }
  end

  render do
    DIV(style: { fontFamily: 'monospace', padding: '2rem' }) do
      P(style: { fontSize: '1.2rem', color: '#555' }) { 'Greetings from Hyperstack' }
      P(style: { fontSize: '4rem', letterSpacing: '0.05em', margin: '0' }) do
        @time.strftime('%H:%M:%S')
      end
      P(style: { fontSize: '1rem', color: '#888', marginTop: '0.5rem' }) do
        @time.strftime('%A, %B %-d %Y')
      end
    end
  end
end

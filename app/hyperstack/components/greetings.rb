class Greetings < HyperComponent
  before_mount do
    @time   = Time.now
    @name   = ''
    @saving = false
    @dark   = true
  end

  after_mount do
    every(1) { mutate @time = Time.now }
  end

  def sign_guestbook
    mutate @saving = true
    Visit.new(name: @name).save do |success|
      mutate do
        @name   = '' if success
        @saving = false
      end
    end
  end

  # Theme helpers
  def bg;          @dark ? '#0d1117' : '#ffffff';  end
  def text;        @dark ? '#e6edf3' : '#222';     end
  def muted;       @dark ? '#8b949e' : '#888';     end
  def accent;      @dark ? '#58a6ff' : '#555';     end
  def border;      @dark ? '#30363d' : '#eee';     end
  def inp_bg;      @dark ? '#161b22' : '#ffffff';  end
  def clock_color; @dark ? '#3fb950' : 'inherit';  end

  def btn_active?; !@saving && !@name.strip.empty?; end
  def btn_bg;    btn_active? ? (@dark ? '#238636' : '#333') : (@dark ? '#21262d' : '#eee'); end
  def btn_color; btn_active? ? '#ffffff' : (@dark ? '#8b949e' : '#999'); end

  render do
    DIV(style: { fontFamily: 'monospace', padding: '2rem',
                 background: bg, color: text, minHeight: '100vh' }) do

      # Toggle button — top, right-aligned within 50% width
      DIV(class: 'guestbook', style: { textAlign: 'right', marginBottom: '0.5rem' }) do
        BUTTON(style: {
          background: 'none', border: "1px solid #{border}",
          borderRadius: '4px', color: muted, padding: '0.2rem 0.6rem',
          fontSize: '0.75rem', cursor: 'pointer', fontFamily: 'monospace'
        }) { @dark ? '☀ Light' : '🌙 Dark' }.on(:click) { mutate @dark = !@dark }
      end

      # Header
      P(style: { color: accent, fontSize: '1.2rem',
                 textTransform: @dark ? 'uppercase' : 'none' }) do
        'Greetings from Hyperstack'
      end

      # Clock
      P(class: 'clock', style: { letterSpacing: '0.05em', margin: '0',
                                  color: clock_color }) do
        @time.strftime('%I:%M:%S %p')
      end

      # Date
      P(style: { color: muted, fontSize: '1rem', marginTop: '0.5rem',
                 marginBottom: '2.5rem' }) do
        @time.strftime('%A, %B %-d %Y')
      end

      # Guestbook section (half-width)
      DIV(class: 'guestbook') do
        H2(style: { fontSize: '0.85rem', color: accent, marginBottom: '0.25rem',
                    borderBottom: "1px solid #{border}", paddingBottom: '0.5rem',
                    textTransform: @dark ? 'uppercase' : 'none' }) { 'Guestbook' }

        P(style: { fontSize: '0.75rem', color: muted, marginBottom: '1rem' }) do
          'Sign below — open this page in another tab or on your phone to see new entries appear instantly.'
        end

        # Sign form
        DIV(style: { display: 'flex', gap: '0.5rem', marginBottom: '1.5rem' }) do
          INPUT(
            type: :text, placeholder: 'Your name', value: @name,
            disabled: @saving,
            style: { background: inp_bg, border: "1px solid #{border}",
                     borderRadius: '4px', color: text,
                     padding: '0.4rem 0.75rem', fontSize: '0.9rem',
                     fontFamily: 'monospace', flexGrow: 1, outline: 'none' }
          ).on(:change) { |e| mutate @name = e.target.value }

          BUTTON(
            disabled: @saving || @name.strip.empty?,
            style: { background: btn_bg, border: "1px solid #{border}",
                     borderRadius: '4px', color: btn_color,
                     padding: '0.4rem 1rem', fontSize: '0.9rem',
                     fontFamily: 'monospace',
                     cursor: btn_active? ? 'pointer' : 'not-allowed' }
          ) { 'Sign' }.on(:click) { sign_guestbook }
        end

        # Visitor list
        UL(style: { listStyle: 'none', padding: 0, margin: 0 }) do
          Visit.recent.each do |v|
            LI(key: v.id, style: {
              display: 'flex', justifyContent: 'space-between',
              padding: '0.5rem 0', borderBottom: "1px solid #{border}",
              fontSize: '0.9rem'
            }) do
              SPAN { v.name }
              SPAN(style: { color: muted, fontSize: '0.8rem' }) do
                v.created_at.strftime('%b %-d, %I:%M %p')
              end
            end
          end
        end
      end
    end
  end
end

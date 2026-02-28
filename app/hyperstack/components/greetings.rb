class Greetings < HyperComponent
  before_mount do
    @time   = Time.now
    @name   = ''
    @saving = false
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

  render do
    DIV(style: {
      fontFamily:      "'Courier New', Courier, monospace",
      background:      '#0d1117',
      minHeight:       '100vh',
      color:           '#e6edf3',
      padding:         '2rem',
      boxSizing:       'border-box'
    }) do

      # Header
      P(style: { color: '#58a6ff', fontSize: '0.85rem', letterSpacing: '0.15em',
                 textTransform: 'uppercase', marginBottom: '0.25rem' }) do
        'Greetings from Hyperstack'
      end

      # Clock block
      DIV(style: {
        background:    '#161b22',
        border:        '1px solid #30363d',
        borderRadius:  '8px',
        padding:       '1.5rem 2rem',
        display:       'inline-block',
        marginBottom:  '2rem'
      }) do
        P(style: { color: '#8b949e', fontSize: '0.8rem', margin: '0 0 0.25rem' }) do
          @time.strftime('%A, %B %-d %Y')
        end
        P(style: {
          color:        '#3fb950',
          fontSize:     '3.5rem',
          fontWeight:   'bold',
          letterSpacing: '0.05em',
          margin:        0,
          lineHeight:    1
        }) do
          @time.strftime('%H:%M:%S')
        end
      end

      # Guestbook section
      H2(style: { color: '#58a6ff', fontSize: '1rem', letterSpacing: '0.1em',
                  textTransform: 'uppercase', borderBottom: '1px solid #30363d',
                  paddingBottom: '0.5rem', marginBottom: '1rem' }) { 'Guestbook' }

      # Sign form
      DIV(style: { display: 'flex', gap: '0.5rem', marginBottom: '1.5rem' }) do
        INPUT(
          type:        :text,
          placeholder: 'Your name',
          value:       @name,
          disabled:    @saving,
          style: {
            background:   '#161b22',
            border:       '1px solid #30363d',
            borderRadius: '6px',
            color:        '#e6edf3',
            padding:      '0.4rem 0.75rem',
            fontSize:     '0.9rem',
            outline:      'none',
            flexGrow:     1
          }
        ).on(:change) { |e| mutate @name = e.target.value }

        BUTTON(
          disabled: @saving || @name.strip.empty?,
          style: {
            background:   (@saving || @name.strip.empty?) ? '#21262d' : '#238636',
            border:       '1px solid #30363d',
            borderRadius: '6px',
            color:        (@saving || @name.strip.empty?) ? '#8b949e' : '#ffffff',
            padding:      '0.4rem 1rem',
            fontSize:     '0.9rem',
            cursor:       (@saving || @name.strip.empty?) ? 'not-allowed' : 'pointer'
          }
        ) { 'Sign' }.on(:click) { sign_guestbook }
      end

      # Visitor list
      UL(style: { listStyle: 'none', padding: 0, margin: 0 }) do
        Visit.recent.each do |v|
          LI(key: v.id, style: {
            display:       'flex',
            justifyContent: 'space-between',
            padding:       '0.5rem 0.75rem',
            borderBottom:  '1px solid #21262d',
            fontSize:      '0.9rem'
          }) do
            SPAN(style: { color: '#e6edf3' }) { v.name }
            SPAN(style: { color: '#8b949e', fontSize: '0.8rem' }) do
              v.created_at.strftime('%b %-d, %H:%M')
            end
          end
        end
      end
    end
  end
end

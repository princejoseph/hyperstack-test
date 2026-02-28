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
    DIV(style: { fontFamily: 'monospace', padding: '2rem' }) do

      # Header
      P(style: { color: '#555', fontSize: '1.2rem' }) do
        'Greetings from Hyperstack'
      end

      # Clock
      P(class: 'clock', style: { letterSpacing: '0.05em', margin: '0' }) do
        @time.strftime('%I:%M:%S %p')
      end

      # Date
      P(style: { color: '#888', fontSize: '1rem', marginTop: '0.5rem',
                 marginBottom: '2.5rem' }) do
        @time.strftime('%A, %B %-d %Y')
      end

      # Guestbook section (half-width)
      DIV(class: 'guestbook') do
        H2(style: { fontSize: '0.85rem', color: '#888', marginBottom: '1rem',
                    borderBottom: '1px solid #eee', paddingBottom: '0.5rem' }) { 'Guestbook' }

        # Sign form
        DIV(style: { display: 'flex', gap: '0.5rem', marginBottom: '1.5rem' }) do
          INPUT(
            type:        :text,
            placeholder: 'Your name',
            value:       @name,
            disabled:    @saving,
            style: {
              border:       '1px solid #ddd',
              borderRadius: '4px',
              padding:      '0.4rem 0.75rem',
              fontSize:     '0.9rem',
              flexGrow:     1
            }
          ).on(:change) { |e| mutate @name = e.target.value }

          BUTTON(
            disabled: @saving || @name.strip.empty?,
            style: {
              background:   (@saving || @name.strip.empty?) ? '#eee' : '#333',
              border:       'none',
              borderRadius: '4px',
              color:        (@saving || @name.strip.empty?) ? '#999' : '#fff',
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
              display:        'flex',
              justifyContent: 'space-between',
              padding:        '0.5rem 0',
              borderBottom:   '1px solid #eee',
              fontSize:       '0.9rem'
            }) do
              SPAN { v.name }
              SPAN(style: { color: '#888', fontSize: '0.8rem' }) do
                v.created_at.strftime('%b %-d, %I:%M %p')
              end
            end
          end
        end
      end
    end
  end
end

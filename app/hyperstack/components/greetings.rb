class Greetings < HyperComponent
  before_mount do
    @time   = Time.now
    @visits = []
    @name   = ''
    @saving = false
  end

  after_mount do
    every(1) { mutate @time = Time.now }
    load_visits
  end

  def load_visits
    Hyperstack::HTTP.get('/visits') do |response|
      mutate @visits = response.json if response.ok?
    end
  end

  def sign_guestbook
    mutate @saving = true
    Hyperstack::HTTP.post('/visits', payload: { name: @name }) do |response|
      mutate do
        if response.ok?
          @visits = [response.json] + @visits
          @name   = ''
        end
        @saving = false
      end
    end
  end

  render do
    DIV(style: { fontFamily: 'monospace', padding: '2rem' }) do
      P { 'Greetings from Hyperstack' }
      P { @time.strftime('%Y-%m-%d') }
      P { @time.strftime('%H:%M:%S') }

      H2 { 'Guestbook' }

      DIV do
        INPUT(
          type:        :text,
          placeholder: 'Your name',
          value:       @name,
          disabled:    @saving
        ).on(:change) { |e| mutate @name = e.target.value }
        BUTTON(disabled: @saving || @name.strip.empty?) { 'Sign' }
          .on(:click) { sign_guestbook }
      end

      UL do
        @visits.each do |v|
          LI(key: v['id']) { "#{v['name']} at #{v['time']}" }
        end
      end
    end
  end
end

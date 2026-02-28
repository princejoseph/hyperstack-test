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
        Visit.recent.each do |v|
          LI(key: v.id) { v.name }
        end
      end
    end
  end
end

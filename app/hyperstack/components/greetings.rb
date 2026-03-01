class Greetings < HyperComponent
  before_mount do
    @time   = Time.now
    @name   = ""
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
        @name   = "" if success
        @saving = false
      end
    end
  end

  render do
    DIV(class: "page#{@dark ? ' dark' : ''}") do
      # Toggle — top, right-aligned, same 50% width as guestbook
      DIV(class: "toggle-wrap") do
        BUTTON(class: "toggle-btn") { @dark ? "\u2600 Light" : "\u{1F319} Dark" }
          .on(:click) { mutate @dark = !@dark }
      end

      P(class: "header") { "Greetings from Hyperstack" }

      P(class: "clock") { @time.strftime("%I:%M:%S %p") }

      P(class: "date") { @time.strftime("%A, %B %-d %Y") }

      DIV(class: "guestbook") do
        H2(class: "guestbook-title") { "Guestbook" }

        P(class: "hint") do
          "Sign below \u2014 open this page in another tab or on your phone to see new entries appear instantly."
        end

        DIV(class: "sign-form") do
          INPUT(class: "name-input",
                type: :text, placeholder: "Your name",
                value: @name, disabled: @saving
          ).on(:change) { |e| mutate @name = e.target.value }

          BUTTON(class: "sign-btn", disabled: @saving || @name.strip.empty?) { "Sign" }
            .on(:click) { sign_guestbook }
        end

        UL(class: "visitor-list") do
          Visit.recent.each do |v|
            LI(key: v.id, class: "visitor-item") do
              SPAN { v.name }
              SPAN(class: "visitor-time") { v.created_at.strftime("%b %-d, %I:%M %p") }
            end
          end
        end
      end
    end
  end
end

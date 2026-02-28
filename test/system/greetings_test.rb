require "application_system_test_case"

class GreetingsTest < ApplicationSystemTestCase
  test "renders Greetings component" do
    visit root_url
    assert_text "Greetings from Hyperstack"
  end

  test "Greetings component is mounted by React" do
    visit root_url
    assert_selector "[data-react-class]"
    assert_text "Greetings from Hyperstack"
  end

  test "displays a running clock in HH:MM:SS AM/PM format" do
    visit root_url
    assert_text(/\d{1,2}:\d{2}:\d{2} [AP]M/)
  end

  test "displays the current date" do
    visit root_url
    assert_text Date.today.strftime("%Y")
  end

  test "clock ticks" do
    visit root_url
    first_time = find("p", text: /\d{1,2}:\d{2}:\d{2} [AP]M/).text
    sleep 2
    second_time = find("p", text: /\d{1,2}:\d{2}:\d{2} [AP]M/).text
    assert_not_equal first_time, second_time, "Clock should have advanced"
  end

  test "shows guestbook form" do
    visit root_url
    assert_selector "input[type=text]"
    assert_selector "button", text: "Sign"
  end

  test "can sign the guestbook" do
    visit root_url
    find("input[type=text]").fill_in(with: "Test Visitor")
    find("button", text: "Sign").click
    assert_text "Test Visitor", wait: 5
  end

  test "guestbook entry broadcasts in real-time to a second session" do
    # Session B loads first. Wait for the visit list to render — this confirms
    # React is mounted and HyperModel is active. ActionCable connects in
    # parallel, so a brief sleep afterwards ensures subscription is complete.
    using_session("session_b") do
      visit root_url
      assert_selector "ul li", wait: 20
      sleep 3  # let ActionCable finish subscribing + connect-to-transport
    end

    # Session A signs the guestbook
    using_session("session_a") do
      visit root_url
      find("input[type=text]").fill_in(with: "LiveVisitor")
      find("button", text: "Sign").click
      assert_text "LiveVisitor", wait: 5  # optimistic update confirms save
    end

    # Session B should receive the new entry via ActionCable — no page refresh
    using_session("session_b") do
      assert_text "LiveVisitor", wait: 10
    end
  ensure
    Visit.where(name: "LiveVisitor").destroy_all
  end
end

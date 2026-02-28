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

  test "displays a running clock in HH:MM:SS format" do
    visit root_url
    assert_text(/\d{2}:\d{2}:\d{2}/)
  end

  test "displays the current date" do
    visit root_url
    assert_text Date.today.strftime("%Y")
  end

  test "clock ticks" do
    visit root_url
    first_time = find("p", text: /\d{2}:\d{2}:\d{2}/).text
    sleep 2
    second_time = find("p", text: /\d{2}:\d{2}:\d{2}/).text
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
end

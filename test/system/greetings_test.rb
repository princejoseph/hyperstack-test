require "application_system_test_case"

class GreetingsTest < ApplicationSystemTestCase
  test "renders Greetings component" do
    visit root_url
    assert_text "Greetings"
  end

  test "Greetings component is mounted by React" do
    visit root_url
    # The div should be replaced by the React-mounted component
    assert_selector "[data-react-class]"
    assert_text "Greetings"
  end
end


# Simulate pressing enter in a form that doesn't have a submit button
def submit_form(id)
  if Capybara.current_driver == :poltergeist
    page.evaluate_script("$('##{id}').submit()")
  else
    element = find_by_id(id)
    Capybara::RackTest::Form.new(page.driver, element.native).submit(name: nil)
  end
end

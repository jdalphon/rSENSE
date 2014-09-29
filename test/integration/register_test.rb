require 'test_helper'

class RegisterTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'create a user' do
    visit '/'
    find('.navbar').click_on('Register')
    assert page.has_content?('Register for iSENSE')
    fill_in 'user_name',       with: 'Mark S.'
    fill_in 'user_email',      with: 'msherman@cs.uml.edu'
    fill_in 'user_password',   with: 'pietime1'
    fill_in 'user_password_confirmation',
                               with: 'pietime1'
    click_on 'Sign up'

    assert page.has_content?('Welcome! You have signed up successfully.'), 'Failed to register.'
    assert page.has_content?('Mark S.')

    logout

    login('msherman@cs.uml.edu', 'pietime1')

    assert find('.navbar').has_content?('News'), 'Failed log in with new user'
  end
end

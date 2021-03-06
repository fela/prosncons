require 'test_helper'

class PageIntegrationTest < ActionDispatch::IntegrationTest

  setup do
    visit(root_path)
    email = users(:alice).primary_email
    if not page.has_content?(email)
      login email
    end
  end

  test "creating many items" do
    # creating page
    visit(pages_path)
    click_on('New Page')
    fill_in('page_title', with: 'Test title 123')
    fill_in('page_content', with: 'Content 345')
    click_on('Create Page')
    # check page
    assert page.has_content?('Content 345')
    within('.page-header') do
      assert page.has_content?('Test title 123')
    end
    assert page.has_content?('Pros')
    assert page.has_content?('Cons')
    within('.page-content .signature') do
      assert page.has_content?('Alice')
    end

    # edit page
    within('.page-header') do
      click_on('edit')
    end
    fill_in('page_title', with: 'Test title XXX')
    fill_in('page_content', with: 'Content 222')
    click_on('Update Page')
    # check edited page
    assert page.has_content?('Content 222')
    within('.page-header') do
      assert page.has_content?('Test title XXX')
    end

    # add argument and then go back
    page.find('.option-1-content > .option-header .btn').click
    click_on('Back')
    assert page.has_content?('Content 222')
    within('.page-header') do
      assert page.has_content?('Test title XXX')
    end

    # add argument for real
    page.find('.option-1-content > .option-header .btn').click

    fill_in('argument_summary', with: 'TestArgSummary')
    fill_in('argument_description', with: 'TestArgDescription')
    click_on('Create Argument')
    within('.option-1-content') do
      assert page.has_content?('TestArgSummary')
      assert page.has_content?('TestArgDescription')
    end

    within('.option-0-content') do
      assert page.has_no_content?('TestArgSummary')
      assert page.has_no_content?('TestArgDescription')
    end

    within('.option-1-content') do
      click_on('edit')
    end

    fill_in('argument_summary', with: 'TestXXXArgSummary')
    fill_in('argument_description', with: 'TestXXXArgDescription')
    click_on('Update Argument')

    within('.option-1-content') do
      assert page.has_content?('TestXXXArgSummary')
      assert page.has_content?('TestXXXArgDescription')
    end

    sleep 10


    # TODO: to be finished
  end

end
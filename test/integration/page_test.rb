require 'test_helper'

class PageIntegrationTest < ActionDispatch::IntegrationTest

  setup do
    visit(root_path)
    email = users(:alice).primary_email
    if not page.has_content?(email)
      login email
    end
  end

  test "creating page and argument" do
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

    # add argument
    page.all('.option-header')[1].find('.btn').click
  end

end
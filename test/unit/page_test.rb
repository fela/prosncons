require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test "paper trail" do
    page = pages(:page2)
    page.title = 'First Title'
    page.content = 'First content'
    page.save
    page.title = 'Second Title'
    page.content = 'Second content'
    page.save
    page = Page.find(page.id)
    last = page.versions.last.reify
    assert_equal last.title, 'First Title'
    assert_equal last.content, 'First content'
    page = Page.find(page.id)
    assert_equal page.title, 'Second Title'
    assert_equal page.content, 'Second content'
    last.save
    page = Page.find(page.id)
    assert_equal page.title, 'First Title'
    assert_equal page.content, 'First content'
  end
end

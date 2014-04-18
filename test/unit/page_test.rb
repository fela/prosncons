require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test 'paper trail' do
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

  test 'renaming options' do
    page = pages(:page1)
    n_pros = page.arguments1.size
    n_cons = page.arguments2.size
    page.update_attributes(option1: 'test1', option2: 'test2')
    assert_equal n_pros, page.arguments1.size
    assert_equal n_cons, page.arguments2.size
  end

  test 'options with same name' do
    assert_raises do
      pages(:page1).update_attributes(option1: 'abc', option2: 'abc')
    end
  end

  test 'arguments1 and arguments2' do
    arguments1 = pages(:page1).arguments1
    arguments2 = pages(:page1).arguments2
    assert_includes arguments1, arguments(:page1arg1)
    assert_includes arguments1, arguments(:page1arg2)
    assert_includes arguments2, arguments(:page1arg3)
    assert_includes arguments2, arguments(:page1arg4)
    assert_includes arguments2, arguments(:page1arg5)
    assert_equal 2, arguments1.size
    assert_equal 3, arguments2.size
  end
end

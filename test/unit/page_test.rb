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
    refute pages(:page1).update_attributes(option1: 'abc', option2: 'abc')
  end

  test 'arguments1 and arguments2' do
    arg1 = arguments(:page1arg1)
    arg2 = arguments(:page1arg2)
    arg3 = arguments(:page1arg3)
    arg4 = arguments(:page1arg4)
    arg5 = arguments(:page1arg5)

    now = Time.now
    arg1.created_at = now + 2
    arg1.save!
    arg2.created_at = now + 10
    arg2.save!

    arg5.created_at = now + 2
    arg5.save!
    arg3.created_at = now + 1
    arg3.save!
    arg4.created_at = now + 0
    arg4.save!

    arguments1 = pages(:page1).arguments1
    arguments2 = pages(:page1).arguments2
    assert_equal arguments1[0], arg1
    assert_equal arguments1[1], arg2
    assert_equal arguments2[0], arg5
    assert_equal arguments2[1], arg3
    assert_equal arguments2[2], arg4
    assert_equal 2, arguments1.size
    assert_equal 3, arguments2.size
  end
end

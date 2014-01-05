require 'test_helper'
require 'mocha/setup'

class PagesControllerTest < ActionController::TestCase
  setup do
    @page = pages(:page1)
  end

  # helper
  def assert_access_denied(&blk)
    assert_raise(CanCan::AccessDenied, &blk)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  test "should get new" do
    @controller.stubs(:current_user).returns(users(:bob))
    get :new
    assert_response :success
  end

  test "new should fail if not logged in" do
    assert_access_denied do
      get :new
    end
  end

  test "should create page" do
    @controller.stubs(:current_user).returns(users(:bob))
    assert_difference('Page.count') do
      post :create, page: {
          content: @page.content,
          option1: @page.option1,
          option2: @page.option2,
          title: @page.title
      }
    end
    assert_redirected_to page_path(assigns(:page))
  end



  test "should fail to create page if not logged in" do
    page_count = Page.count
    assert_access_denied do
      post :create, page: {
          content: @page.content,
          option1: @page.option1,
          option2: @page.option2,
          title: @page.title
      }
    end
    assert_equal page_count, Page.count
    # TODO: check why the following doesn't work
    #assert_redirected_to pages_path
  end

  test "should show page" do
    get :show, id: @page
    assert_response :success
  end

  test "should get edit" do
    @controller.stubs(:current_user).returns(users(:alice))
    get :edit, id: @page
    assert_response :success
  end

  test "should not get edit if not logged in" do
    assert_access_denied do
      get :edit, id: @page
    end
  end

  test "should not get edit if wrong user" do
    @controller.stubs(:current_user).returns(users(:bob))
    assert_access_denied do
      get :edit, id: @page
    end
  end

  test "should update page" do
    @controller.stubs(:current_user).returns(users(:alice))
    put :update, id: @page, page: {
        content: @page.content,
        option1: @page.option1,
        option2: @page.option2,
        title: @page.title
    }
    assert_redirected_to page_path(assigns(:page))
  end

  test "should not update page if not logged in" do
    assert_access_denied do
      put :update, id: @page, page: {
          content: @page.content,
          option1: @page.option1,
          option2: @page.option2,
          title: @page.title + 'XXX'
      }
    end
  end

  test "should not update page if not creator" do
    @controller.stubs(:current_user).returns(users(:bob))
    assert_access_denied do
      put :update, id: @page, page: {
          content: @page.content,
          option1: @page.option1,
          option2: @page.option2,
          title: @page.title + 'XXX'
      }
    end
  end

  test "should destroy page" do
    @controller.stubs(:current_user).returns(users(:alice))
    assert_no_difference('Page.count') do
      assert_access_denied do
        delete :destroy, id: @page
      end
    end
  end
end

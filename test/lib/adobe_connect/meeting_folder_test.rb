require File.expand_path('../../test_helper.rb', File.dirname(__FILE__))

class AdobeConnectMeetingFolderTest < MiniTest::Unit::TestCase

  AdobeConnect::Config.declare(username: 'test@example.com', password: 'pwd',
    domain: 'http://example.com')

  FOLDER_SUCCESS  = File.read('test/fixtures/folder_success.xml')
  FOLDER_CONTENTS = File.read('test/fixtures/folder_contents.xml')

  def setup
    @folder = AdobeConnect::MeetingFolder.new('1', 'test folder', '/test-meeting/')
  end

  def test_initialize_takes_a_name
    assert_equal @folder.name, 'test folder'
  end

  def test_initialize_takes_an_id
    assert_equal @folder.id, '1'
  end

  def test_initialize_takes_a_url
    assert_equal @folder.url, '/test-meeting/'
  end

  def test_initialize_defaults_to_a_new_service
    assert_instance_of AdobeConnect::Service, @folder.service
  end

  def test_find_returns_a_new_folder
    response = mock(status: 200)
    response.expects(:body).returns(FOLDER_SUCCESS)
    ac_response = AdobeConnect::Response.new(response)

    AdobeConnect::Service.any_instance.
      expects(:request).
      with('sco-search-by-field', query: 'canvas_meetings',
        filter_type: 'folder', field: 'name').
      returns(ac_response)

    folder = AdobeConnect::MeetingFolder.find('canvas_meetings')

    assert_instance_of        AdobeConnect::MeetingFolder, folder
    assert_equal folder.name, 'canvas_meetings'
    assert_equal folder.id,   '25915'
    assert_equal folder.url,  '/meeting-path/'
  end

  def test_contents_returns_folder_contents
    response = mock(status: 200)
    response.expects(:body).returns(FOLDER_CONTENTS)
    ac_response = AdobeConnect::Response.new(response)
    @folder.service.expects(:sco_contents).returns(ac_response)

    assert_equal @folder.contents.xpath('//sco').length, 10
  end
end
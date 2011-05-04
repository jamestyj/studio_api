require 'test_helper'

class RpmTest < Test::Unit::TestCase
  APPLIANCE_ID = 269186
  RPM_ID = 27653

  def respond_load name
    IO.read(File.join(File.dirname(__FILE__), "responses", name))
  end

  def setup
    @connection = StudioApi::Connection.new("test", "test", "http://localhost")
    StudioApi::Rpm.studio_connection = @connection

    rpms_out = respond_load "rpms.xml"
    rpm_out = respond_load "rpm.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/rpms?base_system=sle11_sp1", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, rpms_out, 200
      mock.get "/rpms/#{RPM_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, rpm_out, 200
      mock.delete "/rpms/#{RPM_ID}", {"Authorization"=>"Basic dGVzdDp0ZXN0"}, rpm_out, 200
    end
  end

  def test_find
    res = StudioApi::Rpm.find :all, :params => {:base_system => "sle11_sp1"}
    assert_equal 48, res.size
    res = StudioApi::Rpm.find RPM_ID
    assert "false", res.archive
  end

  def test_delete
    rpm = StudioApi::Rpm.find RPM_ID
    assert rpm.destroy
    assert StudioApi::Rpm.delete RPM_ID
  end

TEST_STRING = "My lovely testing string\n Doodla da da da nicht"
  def test_download
    StudioApi::GenericRequest.any_instance.stubs(:get).with("/rpms/#{RPM_ID}/data").returns(TEST_STRING)
    assert_equal TEST_STRING, StudioApi::Rpm.new(:id=> RPM_ID).content
  end

  def test_upload
    rpm_out = respond_load "rpm.xml"
    StudioApi::GenericRequest.any_instance.stubs(:post).returns(rpm_out)
    assert StudioApi::Rpm.upload(TEST_STRING, "SLE11")
  end

end

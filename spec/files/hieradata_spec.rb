# vim: set ts=2 sw=2 ai et:
describe 'hieradata' do
  same_message = 'bar' # same content as hieradata/common.yaml
  diff_message = 'baz' # different content than hieradata/common.yaml

  hieradata_path = File.join(Helpers::Paths.fixture_path, 'hieradata')
  same_path = File.join(hieradata_path, 'common.yaml')
  diff_path = File.join(hieradata_path, 'diff.example.com.yaml')

  # ensure common.yaml has the data I think it should have
  describe 'common.yaml' do
    before :each do
      @yaml = YAML.load_file same_path
    end
    it "should contain :foo_message => '#{same_message}'" do
      @yaml[:foo_message].should == same_message
    end
    it "should contain 'foo_message' => '#{same_message}'" do
      @yaml['foo_message'].should == same_message
    end
  end

  # ensure diff.example.com.yaml has the data I think it should have
  describe 'diff.example.com.yaml' do
    before :each do
      @yaml = YAML.load_file diff_path
    end
    it "should contain :foo_message => '#{diff_message}'" do
      @yaml[:foo_message].should == diff_message
    end
    it "should contain 'foo_message' => '#{diff_message}'" do
      @yaml['foo_message'].should == diff_message
    end
  end
end

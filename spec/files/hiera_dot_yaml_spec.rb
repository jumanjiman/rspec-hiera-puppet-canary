# vim: set ts=2 sw=2 ai et:

hiera_dot_yaml = File.join(Helpers::Paths.fixture_path, 'files', 'hiera.yaml')
md5sum = 'b01e596e22abe6bfdb508f0f34066c7d'

describe File.basename(hiera_dot_yaml) do
  let(:md5sum) {md5sum}
  let(:datadir_path) {'/opt/puppet/environments/%{::environment}/hieradata'}

  before :each do
    @yaml = YAML.load_file hiera_dot_yaml
  end

  # ensure I don't futz with hiera.yaml
  it "md5sum should == #{md5sum}" do
    Digest::MD5.hexdigest(File.read(hiera_dot_yaml)).should == md5sum
  end

  # ensure hiera.yaml has what I think it should have
  it {@yaml[:backends].should =~ ['yaml']}
  it {@yaml[:yaml][:datadir].should == datadir_path}
  it {@yaml[:hierarchy].should =~ ['%{::fqdn}', 'common']}
end

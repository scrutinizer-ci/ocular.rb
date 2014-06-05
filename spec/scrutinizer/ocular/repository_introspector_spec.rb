
require 'spec_helper'
require 'scrutinizer/ocular/repository_introspector'

describe Scrutinizer::Ocular::RepositoryIntrospector do

  repo_dir = nil
  introspector = nil

  before do
    repo_dir = "/tmp/repo-inspector-rb"

    if Dir.exists? repo_dir
      system("rm -rf " + repo_dir)
    end

    Dir.mkdir(repo_dir)
    system("git init 1>/dev/null", :chdir => repo_dir)
    introspector = Scrutinizer::Ocular::RepositoryIntrospector.new(repo_dir)
  end

  it "returns the current revision" do
    system("echo 'foo' > " + repo_dir + "/foo && git add . && git commit -m 'Foo' 1>/dev/null", :chdir => repo_dir)
    introspector.get_current_revision.should match(/^[a-f0-9]{40}$/)
  end

  it "returns the parents of the revision" do
    system("echo 'foo' > " + repo_dir + "/foo && git add . && git commit -m 'Foo' 1>/dev/null", :chdir => repo_dir)
    base_rev = introspector.get_current_revision
    introspector.get_current_parents.should eql?([])

    system("echo 'bar' > " + repo_dir + "/bar && git add . && git commit -m 'Bar' 1>/dev/null", :chdir => repo_dir)
    introspector.get_current_parents.should eql?([base_rev])
  end

  it "returns the GitHub repository name" do
    system("git remote add origin git@github.com:scrutinizer-ci/ocular.rb", :chdir => repo_dir)
    introspector.get_repository_name.should eql?("g/scrutinizer-ci/ocular.rb")

    system("git remote set-url origin git://github.com:scrutinizer-ci/ocular.rb", :chdir => repo_dir)
    introspector.get_repository_name.should eql?("g/scrutinizer-ci/ocular.rb")
  end

  after do
    unless repo_dir.nil?
      system("rm -rf " + repo_dir)
    end
  end

end

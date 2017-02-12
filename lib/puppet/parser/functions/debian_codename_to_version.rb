begin
  require 'facter/util/debian'
rescue LoadError
  require "#{File.dirname(__FILE__)}/../../../facter/util/debian"
end

module Puppet::Parser::Functions
  versions = Facter::Util::Debian::CODENAMES.invert
  newfunction(:debian_codename_to_version, :type => :rvalue) do |args|
    codename = args[0]
    if versions.has_key? codename
      return versions[codename].to_i
    else
    raise Puppet::ParseError,
          "Could not determine release from codename #{codename}"
    end
  end
end

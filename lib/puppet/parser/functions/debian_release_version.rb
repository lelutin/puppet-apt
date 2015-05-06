module Puppet::Parser::Functions
  newfunction(:debian_release_version, :type => :rvalue) do |args|
    case args[0]
      when 'squeeze'      then '6.0'
      when 'wheezy'       then '7.0'
      when 'jessie'       then '8.0'
      when 'stretch'      then '9.0'
      when 'buster'       then '10.0'
      else ''
    end
  end
end

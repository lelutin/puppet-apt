module Puppet::Parser::Functions
  newfunction(:debian_release_version, :type => :rvalue) do |args|
    case args[0]
      when 'etch'         then '4.0'
      when 'lenny'        then '5.0'
      else ''
    end
  end
end

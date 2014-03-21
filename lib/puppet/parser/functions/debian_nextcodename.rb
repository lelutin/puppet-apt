module Puppet::Parser::Functions
  newfunction(:debian_nextcodename, :type => :rvalue) do |args|
    case args[0]
      when "squeeze" then "wheezy"
      when "wheezy"  then "jessie"
      when "jessie"  then "sid"
      when "sid"     then "experimental"
      else "sid"
    end
  end
end

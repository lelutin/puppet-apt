module Puppet::Parser::Functions
  newfunction(:debian_nextrelease, :type => :rvalue) do |args|
    case args[0]
      when 'oldstable' then 'stable'
      when 'stable'    then 'testing'
      when 'testing'   then 'unstable'
      when 'unstable'  then 'experimental'
      else 'unstable'
    end
  end
end

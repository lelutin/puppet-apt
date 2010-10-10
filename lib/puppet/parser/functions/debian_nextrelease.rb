module Puppet::Parser::Functions
  newfunction(:debian_nextrelease, :type => :rvalue) do |args|
    result = case #{args[0]}
      when 'oldstable' then 'stable'
      when 'stable'    then 'testing'
      when 'testing'   then 'unstable'
      when 'unstable'  then 'experimental'
    end
    return result
  end
end

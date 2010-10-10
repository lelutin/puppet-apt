module Puppet::Parser::Functions
  newfunction(:debian_release, :type => :rvalue) do |args|
    result = case #{args[0]}
      when 'etch'         then 'oldstable'
      when 'lenny'        then 'stable'
      when 'squeeze'      then 'testing'
      when 'sid'          then 'unstable'
      when 'experimental' then 'experimental'
    end
    return result
  end
end

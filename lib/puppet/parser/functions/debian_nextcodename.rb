module Puppet::Parser::Functions
  newfunction(:debian_nextcodename, :type => :rvalue) do |args|
    result = case #{args[0]}
      when 'etch'    then 'lenny'
      when 'lenny'   then 'squeeze'
      when 'squeeze' then 'sid'
      when 'sid'     then 'experimental'
    end
    return result
  end
end

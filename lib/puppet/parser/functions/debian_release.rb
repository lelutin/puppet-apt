module Puppet::Parser::Functions
  newfunction(:debian_release, :type => :rvalue) do |args|
    case args[0]
      when 'etch'         then 'oldstable'
      when 'lenny'        then 'stable'
      when 'squeeze'      then 'testing'
      when 'wheezy'       then 'testing'
      when 'sid'          then 'unstable'
      when 'experimental' then 'experimental'
      else 'testing'
    end
  end
end

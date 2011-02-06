module Puppet::Parser::Functions
  newfunction(:debian_release, :type => :rvalue) do |args|
    case args[0]
      when 'lenny'        then 'oldstable'
      when 'squeeze'      then 'stable'
      when 'wheezy'       then 'testing'
      when 'sid'          then 'unstable'
      when 'experimental' then 'experimental'
      else 'testing'
    end
  end
end

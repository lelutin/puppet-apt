module Puppet::Parser::Functions
  newfunction(:debian_release, :type => :rvalue) do |args|
    case args[0]
      when 'squeeze'      then 'oldstable'
      when 'wheezy'       then 'stable'
      when 'jessie'       then 'testing'
      when 'sid'          then 'unstable'
      when 'experimental' then 'experimental'
      else 'testing'
    end
  end
end

module Puppet::Parser::Functions
  newfunction(:debian_release, :type => :rvalue) do |args|
    case args[0]
      when 'squeeze'      then 'oldoldstable'
      when 'wheezy'       then 'oldstable'
      when 'jessie'       then 'stable'
      when 'stretch'      then 'testing'
      when 'sid'          then 'unstable'
      when 'experimental' then 'experimental'
      else 'testing'
    end
  end
end

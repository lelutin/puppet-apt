module Puppet::Parser::Functions
  newfunction(:debian_nextrelease, :type => :rvalue) do |args|
    case #{args[0]} {
      oldstable: { 'stable' }
      stable:    { 'testing' }
      testing:   { 'unstable' }
      unstable:  { 'experimental' }
    }
  end
end

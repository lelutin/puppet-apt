module Puppet::Parser::Functions
  newfunction(:debian_release, :type => :rvalue) do |args|
    case #{args[0]} {
      etch:         { 'oldstable' }
      lenny:        { 'stable' }
      squeeze:      { 'testing' }
      sid:          { 'unstable' }
      experimental: { 'experimental' }
    }
  end
end

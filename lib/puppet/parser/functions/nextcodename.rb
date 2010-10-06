module Puppet::Parser::Functions
  newfunction(:debian_nextcodename, :type => :rvalue) do |args|
    case #{args[0]} {
      etch:    { 'lenny' }
      lenny:   { 'squeeze' }
      squeeze: { 'sid' }
      sid:     { 'experimental' }
    }
  end
end

begin
  require 'facter/util/debian'
end

def debian_codename_to_next(codename)
  if codename == "sid"
    return "experimental"
  else
    codenames = Facter::Util::Debian::CODENAMES.values
    i = codenames.index(codename)
    if i and i+1 < codenames.count
      return codenames[i+1]
    end
  end
end

Facter.add(:debian_nextcodename) do
  confine :operatingsystem => 'Debian'
  setcode do
    debian_codename_to_next(Facter.value('debian_codename'))
  end
end

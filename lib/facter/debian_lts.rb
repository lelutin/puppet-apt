begin
  require 'facter/util/debian'
end

Facter.add(:debian_lts) do
  confine :operatingsystem => 'Debian'
  setcode do
    if Facter::Util::Debian::LTS.include? Facter.value('debian_codename')
      true
    else
      false
    end
  end
end

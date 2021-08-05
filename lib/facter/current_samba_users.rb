Facter.add(:current_samba_users) do
  setcode do
    Facter::Util::Resolution.exec("pdbedit -L | cut -f 1 -d ':'").split("\n")
  end
end

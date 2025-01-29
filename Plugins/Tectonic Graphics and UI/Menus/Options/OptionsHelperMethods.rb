def darkMode?
  return false if $Options.nil?
  return $Options.dark_mode == 0
end
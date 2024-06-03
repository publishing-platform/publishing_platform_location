files = Dir.chdir(__dir__) do
  `git ls-files -z`.split("\x0").reject do |f|
    (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
  end
end

puts files
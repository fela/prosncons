scores = []
a = 2
b = 1
15.times do
  r = rand 6
  up = (rand**3 * 30 * r).round
  down = (rand**3 * 10 * r).round
  score = (a + up).to_f/(a+b+up+down)
  scores << {up: up, down: down, score: score}
end

scores.uniq!{|x|[x[:up], x[:down]]}
scores.sort!{|x,y|y[:score]<=>x[:score]}
scores.each do |el|
  puts "#{(el[:score]*100).round}\t+#{el[:up]}\t-#{el[:down]}"
end

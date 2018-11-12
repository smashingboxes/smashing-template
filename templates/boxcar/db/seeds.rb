Dir[File.dirname(__FILE__) + "/seeds/*.rb"].each { |file| require file }

# rubocop:disable Rails/Output
%w(User).each do |model|
  print "Seeding #{model.pluralize}..." unless Rails.env.test?
  "#{model}Seeds".constantize.run
  puts "done" unless Rails.env.test?
end
# rubocop:enable Rails/Output

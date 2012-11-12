require 'eventmachine'
require 'forwardable'
require 'em-systemcommand'
require 'em-fs' 

EM.run do 
  EM::Dir['/tmp/testing/*'].each_entry do |entry|
    puts "Some entry: #{entry}"
    EM::SystemCommand.execute "rsync -av entry a#{entry}" do |on|
      on.success do |y|
        puts "success: #{y}"
      end
      on.stdout.data do |d|
        puts "data: #{d}"
      end
      on.stdout.update do |u|
        puts "up: #{u}"
      end
    end
  end
end

EM.run do
  EM::FileUtils.cp '/tmp/testing/1352205937', '/tmp/testing/a1352205937' do |on|
    on.exit do |status|
      puts 'Copied!'
    end
  end
end

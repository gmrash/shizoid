# frozen_string_literal: true

namespace :databank do
  task :delete, [:id] => :environment do |t, args|
    if args.count.zero?
      puts 'Specify databank ID'
      break
    end
    id = args[:id].to_i
    databank = DataBank.find_by(id: id)
    if id.zero? || !databank.present?
      puts 'Wrong databank ID'
      break
    end
    databank.destroy
    # Chats.where('data_bank_ids @> ?', id)
  end

  task list: :environment do
    databanks = DataBank.pluck(:id, :name)
    puts "Available Databanks: #{databanks.count}"
    puts DataBank.pluck(:id, :name).map {|d| "#{d.first}: #{d.second}"}.join("\n")
  end

  task :import, [:name, :file] => :environment do |t, args|
    unless args[:name].present? && args[:file].present?
      puts 'Specify databank name and filename'
      break
    end
    puts 'Loading new data…'
    words = File.read(args[:file]).downcase.split(' ')
    databank = DataBank.create!(name: args[:name])
    puts "Creating databank #{databank.name} with id#{databank.id}"
    Pair.learn(chat_id: nil, data_bank_id: databank.id, words: words)
    puts "Done!"
  end

  task :update, [:id, :file] => :environment do |t, args|
    id = args[:id].to_i
    databank = DataBank.find_by(id: id)
    if id.zero? || !databank.present?
      puts 'Wrong databank ID'
      break
    end
    unless args[:file].present?
      puts 'Specify filename'
      break
    end
    puts 'Loading new data…'
    words = File.read(args[:file]).downcase.split(' ')
    puts 'Removing old data…'
    Pair.where(chat_id: nil, data_bank_id: databank.id).destroy_all
    puts 'Learning new data…'
    Pair.learn(chat_id: nil, data_bank_id: databank.id, words: words)
    puts 'Done'
  end
end

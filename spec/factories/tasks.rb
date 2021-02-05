FactoryBot.define do
  factory :task do
    source

    state { :pending }
    status { :ok }
  end
end

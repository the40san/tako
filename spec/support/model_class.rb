class ModelA < ActiveRecord::Base
  def yield_method
    yield self
  end
end

class ModelB < ActiveRecord::Base
end

class CreateModelA < ActiveRecord::Migration
  def change
    create_table :model_as do |t|
      t.integer :value1
      t.string  :value2

      t.timestamps null: false
    end
  end
end

class CreateModelB < ActiveRecord::Migration
  def change
    create_table :model_bs do |t|
      t.integer :value3
      t.string  :value4

      t.timestamps null: false
    end
  end
end

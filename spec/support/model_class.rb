class ModelA < ActiveRecord::Base
  def yield_method
    yield self
  end
end

class ModelB < ActiveRecord::Base
end

class User < ActiveRecord::Base
  has_many :logs
  has_one :wallet
end

class Wallet < ActiveRecord::Base
  belongs_to :user
  force_shard :shard01
end

class Log < ActiveRecord::Base
  belongs_to :user
  force_shard :shard02

  def self.sharded_class_method(user_id)
    Log.create(user_id: user_id)
  end

  def sharded_method(user_id)
    Log.create(user_id: user_id)
  end
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

class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps null: false
    end
  end
end

class CreateWallet < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.belongs_to :user
      t.timestamps null: false
    end
  end
end

class CreateLog < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.belongs_to :user
      t.timestamps null: false
    end
  end
end

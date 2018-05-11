class ModelA < ActiveRecord::Base
  def yield_method
    yield self
  end
end

class ModelB < ActiveRecord::Base
end

class ForceShardRoot < ActiveRecord::Base
  has_many :force_shard_a
  has_one :force_shard_b
end

class ForceShardA < ActiveRecord::Base
  force_shard :shard01
  belongs_to :force_shard_root
end

class ForceShardB < ActiveRecord::Base
  force_shard :shard02
  belongs_to :force_shard_root

  def self.sharded_class_method(rid)
    ForceShardB.create(force_shard_root_id: rid)
  end

  def sharded_method(rid)
    ForceShardB.create(force_shard_root_id: rid)
  end
end

class User < ActiveRecord::Base
  has_many :logs
  has_one :wallet
end

class Wallet < ActiveRecord::Base
  belongs_to :user
end

class Log < ActiveRecord::Base
  belongs_to :user
  scope :number_gteq, ->(val) { where("number >= ?", val) }
end

class Blog < ActiveRecord::Base
  has_many :articles
  has_one :author
end

class Article < ActiveRecord::Base
  belongs_to :blog
end

class Author < ActiveRecord::Base
  belongs_to :blog
end

class Character < ActiveRecord::Base
  has_many :skills, through: :character_skills
  has_many :character_skills
end

class Skill < ActiveRecord::Base
  has_many :characters, through: :character_skills
  has_many :character_skills
end

class CharacterSkill < ActiveRecord::Base
  belongs_to :character
  belongs_to :skill
end

class SaveAlias < ActiveRecord::Base
end

class CreateAllTables < ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration
  def change
    create_table :model_as do |t|
      t.integer :value1
      t.string  :value2

      t.timestamps null: false
    end

    create_table :model_bs do |t|
      t.integer :value3
      t.string  :value4

      t.timestamps null: false
    end

    create_table :force_shard_roots do |t|
      t.timestamps null: false
    end

    create_table :force_shard_as do |t|
      t.belongs_to :force_shard_root
      t.timestamps null: false
    end

    create_table :force_shard_bs do |t|
      t.belongs_to :force_shard_root
      t.timestamps null: false
    end

    create_table :users do |t|
      t.timestamps null: false
    end

    create_table :blogs do |t|
      t.timestamps null: false
    end

    create_table :wallets do |t|
      t.belongs_to :user
      t.timestamps null: false
    end

    create_table :articles do |t|
      t.belongs_to :blog
      t.timestamps null: false
    end

    create_table :logs do |t|
      t.belongs_to :user
      t.integer :number
      t.timestamps null: false
    end

    create_table :authors do |t|
      t.belongs_to :blog
      t.timestamps null: false
    end

    create_table :characters do |t|
      t.timestamps null: false
    end

    create_table :skills do |t|
      t.timestamps null: false
    end

    create_table :character_skills do |t|
      t.belongs_to :character
      t.belongs_to :skill
      t.timestamps null: false
    end

    create_table :save_aliases do |t|
      t.integer :value1
      t.timestamps null: false
    end
  end
end

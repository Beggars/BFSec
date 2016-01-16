class CreateBdusers < ActiveRecord::Migration

  def up
    create_table :bdUsers do |t|
      t.string :username
      t.string :email
      t.string :tel
      t.string :mark
    end
  end

  def change
    create_table :bdUsers do |t|
      t.string :username
      t.string :email
      t.string :tel
      t.string :mark
    end
  end

  def down
    drop_table :bdUsers
  end
end

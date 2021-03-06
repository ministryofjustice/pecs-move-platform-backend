class CreateFrameworks < ActiveRecord::Migration[6.0]
  def change
    create_table :frameworks, id: :uuid do |t|
      t.string :name, null: false
      t.string :version, null: false

      t.timestamps
    end

    add_index :frameworks, [:name, :version], unique: true
  end
end

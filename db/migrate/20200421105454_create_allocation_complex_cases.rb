class CreateAllocationComplexCases < ActiveRecord::Migration[5.2]
  def change
    create_table :allocation_complex_cases, id: :uuid do |t|
      t.string :key, null: false
      t.string :title, null: false
      t.timestamps
    end
  end
end

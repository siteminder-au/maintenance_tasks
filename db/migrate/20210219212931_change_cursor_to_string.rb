# frozen_string_literal: true
class ChangeCursorToString < ActiveRecord::Migration[6.1]
  def up
    change_table(:maintenance_tasks_runs) do |t|
      t.change(:cursor, :string)
    end
  end


    def down
    change_table(:maintenance_tasks_runs) do |t|
      t.change(:cursor, :bigint)
    end
  end
end

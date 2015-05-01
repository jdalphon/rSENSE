class AddShouldLogToVisualizations < ActiveRecord::Migration
  def change
    add_column :visualizations, :should_log, :boolean, default: false
  end
end

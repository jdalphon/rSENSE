class UpdateDefaultVis < ActiveRecord::Migration
  def up
    # Default should be nil.
    change_column :projects, :default_vis, :text, default: nil

    say 'Updating default visualizations...'

    Project.all.each do |p|
      next if p.default_vis.nil?
      dv = p.default_vis.downcase
      if dv == 'none'
        p.default_vis = nil
      else
        p.default_vis =  "{\"canvas\":\"#{dv}_canvas\"}"
      end
      p.save
    end
  end

  def down
    change_column :projects, :default_vis, :text
    Project.all.each do |p|
      next if p.default_vis.nil?
      dv = p.default_vis.downcase
      old_way = JSON.parse(dv)['canvas'].split('_')[0].capitalize
      p.default_vis = old_way
      p.save
    end
  end
end

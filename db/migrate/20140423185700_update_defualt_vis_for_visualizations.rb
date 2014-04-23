class UpdateDefualtVisForVisualizations < ActiveRecord::Migration
  def up
    say 'Updating defaultVis setting in all visualizations...'

    Visualization.all.each do |v|
      data = JSON.parse(v.data)
      old = data['defaultVis']
      new = "{\"canvas\":\"#{old.downcase}_canvas\"}"
      data['defaultVis'] = new
      v.data = data.to_json
      v.save
    end
  end

  def down
    Visualization.all.each do |v|
      data = JSON.parse(v.data)
      new = data['defaultVis']
      old = JSON.parse(new)['canvas'].split('_')[0].capitalize
      data['defaultVis'] = old
      v.data = data.to_json
      v.save
    end
  end
end

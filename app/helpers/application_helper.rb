module ApplicationHelper
  def content_helper(obj)
    render 'shared/content', obj: obj
  end

  def title_and_edit_menu(obj)
    if can_edit?(obj)
      name = obj.class.to_s.split('_').map(&:capitalize).join(' ')
      render 'shared/title_and_menu', obj: obj, typeName: name
    end
  end

  def get_field_name(field)
    if field == 1
      'Timestamp'
    elsif field == 2
      'Number'
    elsif field == 3
      'Text'
    elsif field == 5
      'Longitude'
    elsif field == 4
      'Latitude'
    else
      'invalid input: try get_field_type(int)'
    end
  end

  def get_field_type(field)
    if field == 'Timestamp'
      1
    elsif field == 'Number'
      2
    elsif field == 'Text'
      3
    elsif field == 'Longitude'
      5
    elsif field == 'Latitude'
      4
    else
      'invalid input: try get_field_name(string)'
    end
  end

  def has_key?(proj)
    proj && session[:contrib_access].to_i == proj.id
  end

  def key?(proj)
    proj && session[:contrib_access].to_i == proj.id
  end

  def key_name(proj, key)
    first_key = ContribKey.where('project_id=? AND key=?', proj, key).first
    if first_key.nil?
      nil
    else
      first_key.name
    end
  end

  # Begin permissions stuff
  def can_edit?(obj)
    return false if current_user.nil?
    return true  if current_user.try(:admin)
    return false if obj.nil?

    case obj
    when DataSet
      obj.owner.id == current_user.try(:id)
    when User
      obj.id == current_user.try(:id)
    when Project, Visualization, MediaObject
      obj.try(:owner).try(:id) == current_user.try(:id)
    when Field
      obj.try(:owner).try(:owner).try(:id) == current_user.try(:id)
    else
      false
    end
  end

  def can_hide?(obj)
    if current_user.nil?
      return false
    end

    case obj
    when Project, Tutorial
      (obj.owner.id == current_user.try(:id)) || current_user.try(:admin)
    else
      false
    end
  end

  def can_delete?(obj)
    if current_user.nil?
      return false
    end

    case obj
    when Project
      current_user.try(:admin) || (obj.owner == current_user && obj.data_sets.count == 0)
    when User, Tutorial, News
      current_user.try(:admin)
    when DataSet, Visualization
      (obj.owner.id == current_user.try(:id)) || current_user.try(:admin)
    when MediaObject
      (obj.owner.id == current_user.try(:id)) || current_user.try(:admin)
    when Field
      (obj.owner.owner.id == current_user.try(:id)) || current_user.try(:admin)
    else
      false
    end
  end

  def can_admin?(_obj)
    if current_user.nil?
      return false
    end

    current_user.try(:admin)
  end

  def render_title
    if @namespace[:controller] != 'projects' or !params.key?(:id)
      "iSENSE - #{@namespace[:controller].capitalize}"
    else
      title_proj = Project.find(params[:id]).name
      "iSENSE - #{title_proj}"
    end
  end

  def is_admin?
    unless current_user.nil?
      if current_user.admin == true
        return true
      end
    end
    false
  end
end

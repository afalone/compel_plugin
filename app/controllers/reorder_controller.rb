class ReorderController < ApplicationController

  unloadable

  menu_item :compel_pos_orpo, :only => :developer
  menu_item :compel_pos_orit, :only => :ideveloper

  # TODO: to settings
  GROUP_DEVELOPERS = 12 # to perm
  GROUP_IDEVELOPERS = 69 # to perm

  def show
    @issues = Issue.ordered_for_user(User.current.id)
  end

  def developer
    @users = Group.find(GROUP_DEVELOPERS).users.sort
    if (params[:id] and !params[:id].empty?)
      @developer = User.find(params[:id])
      if (@developer or User.current.admin?)
        @issues = Issue.get_ordered_for_user(@developer)
      end
    end
  end

  def ideveloper
    @users = Group.find(GROUP_IDEVELOPERS).users.sort
    if (params[:id] and !params[:id].empty?)
      @developer = User.find(params[:id])
      if (@developer or User.current.admin?)
        @issues = Issue.get_ordered_for_user(@developer)
      end
    end
    render 'developer'
  end

#  def project
#    @project = Project.find(params[:id])
#    @issues = Issue.get_ordered_for_project(@project.id)
#  end

  def order_user_issues
    order_issues(params[:issues], 'position_for_user', params['maxpos'])
    render :nothing => true
  end

#  def order_project_issues
#    order_issues(params[:issues], 'position_for_project', params['maxpos'])
#    render :nothing => true
#  end

  private

  def order_issues(issues_list, position_field, maxpos)
    if maxpos
      maxpos = maxpos.to_i
    end
    issues_list.each_with_index do |id, index|
      if maxpos and (index + 1) > maxpos and Issue.find(id)[position_field] == nil
        break
      else
        Issue.update_all([position_field + "=?", index + 1], ["id=?", id])
      end
    end
  end

end

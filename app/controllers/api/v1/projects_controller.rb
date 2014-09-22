module Api
  module V1
    class ProjectsController < ::ProjectsController
      skip_before_filter :authorize
      skip_before_filter :verify_authenticity_token
      before_filter :set_user, only: [:create]
      before_filter :allow_cross_site_requests

      def index
        super
      end

      def show
        super
      end

      def create
        project = Project.new
        project.user_id = current_user.id

        if params[:project_name].nil?
          if current_user.name[-1].downcase == 's'
            project.title = "#{current_user.name}' Project"
          else
            project.title = "#{current_user.name}'s Project"
          end
        else
          project.title = params[:project_name]
        end

        respond_to do |format|
          if project.save
            format.json { render json: project.to_hash(false), status: :created, location: project }
          else
            format.json { render json: project.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end
end


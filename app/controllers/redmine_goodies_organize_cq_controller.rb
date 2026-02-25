class RedmineGoodiesOrganizeCqController < ApplicationController

  # Returns two arrays of IssueQuery ids (visible to the current user, within
  # the given project context) whose project_id is nil — i.e. "all projects" queries.
  #   public_global_ids  – non-private queries (shown under "Custom queries")
  #   private_global_ids – private queries     (shown under "My custom queries")
  def index
    project = params[:project_id].present? ? Project.find_by(id: params[:project_id]) : nil

    queries = IssueQuery.visible.global_or_on_project(project).sorted.to_a

    render json: {
      public_global_ids:  queries.reject(&:is_private?).select { |q| q.project_id.nil? }.map(&:id),
      private_global_ids: queries.select(&:is_private?).select  { |q| q.project_id.nil? }.map(&:id)
    }
  end
end

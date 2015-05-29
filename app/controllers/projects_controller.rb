class ProjectsController < ApplicationController
  def index
    render :index, locals: { project: project, projects: projects }
  end

  private

  def project
    @project ||= params[:project]
  end

  def projects
    @projects ||= {
      'depth' => 'Depth',
      'bemazed' => 'Bemazed',
      'marti' => 'Marti',
      'dilemma' => 'Dilemma',
      'basic_game_engine' => 'Basic Game Engine',
      'tracert' => 'TraceRT',
      'toroidwars' => 'Toroid Wars',
      'code2html' => 'Code2HTML'
    }
  end
end

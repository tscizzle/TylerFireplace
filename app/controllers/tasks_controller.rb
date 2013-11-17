class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, except: [:index, :new, :create]

  def index
    @new_task = Task.new(user: current_user)
    @tasks = current_user.get_tasks(session[:time_frame], session[:policies], session[:location])
  end

  def new
  end

  def create
    @new_task = current_user.add_task(params[:title], params[:content])
    unless @new_task.errors.any?
      @new_task = Task.new(user: current_user)
      @new_task.update_metadata(params[:metadata])

      # metadata[:day_range] = [false, true, true, false, false,...]
      # metadata[:time_range] = [false, true, true, ...]
      # metadata[:locations] = [id1, id2, ...]
      # metadata[:tags] = [id1, id2, ...]
    end
    respond_to do |format|
      format.js
    end
  end

  def show
  end

  def edit
  end

  def update
    @task.update(task_params)
    @task.update_metadata(params[:metadata])

    # metadata[:day_range] = [false, true, true, false, false,...]
    # metadata[:time_range] = [false, true, true, ...]
    # metadata[:locations] = [id1, id2, ...]
    # metadata[:tags] = [id1, id2, ...]
  end

  def destroy
  end

  # Stores filter policies in session.
  # 'policies' must be a hash. Ignores keys not in 'POLICIES'.
  def update_policies
    params[:policies].each do |k, v| 
      # Ensure that value is boolean with !!
      session[k] = !!v if Task::POLICIES.include?(k)
    end
  end

  # Stores filter time frame in session.
  # 'time_frame' must be in 'TIME_FRAMES'.
  def update_time_frame
    time_frame = params[:time_frame]
    session[:time_frame] = time_frame if Task::TIME_FRAMES.include?(time_frame)
  end

  private

    def set_task
      @task = Task.find_by(id: params[:id])

      # Check that task exists.
      unless @task
        respond_to do |format|
          flash.alert = "Task not found."
          format.js { render js: "window.location.href = '#{home_url}" }
        end
      end 
    end

    # Sanitize params.
    def task_params
      params.require(:task).permit(:title, :content, :important, :long_lasting)
    end
end

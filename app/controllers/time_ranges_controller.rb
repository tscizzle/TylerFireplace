class TimeRangesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_range, except: [:create]

  def create
    @new_time_range = current_user.create_time_range(time_range_params[:name])
    @new_time_range.update(time_range_params)

    unless @new_time_range.errors.any?
      @time_range = @new_time_range
      @new_time_range = TimeRange.new(user: current_user)

      @time_range.update_times(@metadata[:time_range_select])
      flash.now[:list] = "Time Range Created"
    end
  end

  def update
    @time_range.update(time_range_params)
    @time_range.update_times(@metadata[:time_range_select])

    unless @time_range.errors.any?
      flash.now[:list] = "Time Range Updated"
    end
  end

  def destroy
    @time_range_id = @time_range.id
    @time_range.destroy

    flash.now[:list] = "Time Range Deleted"
  end

  private

    def set_time_range
      @time_range = current_user.get_time_ranges.find_by(id: params[:id])

      # Check that time_range exists.
      unless @time_range
        respond_to do |format|
          format.js { render status: 404 }
        end
      end 
    end

    # Sanitize params.
    def time_range_params
      params.require(:time_range).permit(:name)
    end
end

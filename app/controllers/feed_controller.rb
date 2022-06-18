class FeedController < ApplicationController
  before_action :authenticate_user!, :set_feed, only: %i[show update destroy]

  # GET /feed or /feed.json
  # # TODO: paginated list, for the first iteration this is ok
  def index
    @feeds = Feed.all
    @feeds = @feeds.where(user_id: current_user.id)
    render json: @feeds, each_serializer: FeedSerializer
  end

  # GET /feed/1 or /feed/1.json
  def show
    @feed = Feed.find_by(id: params[:id])
    render json: @feed, serializer: FeedSerializer
  end

  # POST /feed or /feed.json
  def create
    @feed = Feed.new(feed_params)

    respond_to do |format|
      if @feed.save
        format.html { redirect_to feed_url(@feed), notice: "Feed was successfully created." }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feed/1 or /feed/1.json
  def update
    permitted_params = feed_params.permit(:description, :title, :uri)
    respond_to do |format|
      if @feed.update(permitted_params)
        format.json { render json: @feed, serializer: FeedSerializer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feed/1 or /feed/1.json
  def destroy
    @feed.destroy

    respond_to do |format|
      format.html { redirect_to feeds_url, notice: "Feed was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feed_params
      params.fetch(:feed, {})
    end
end

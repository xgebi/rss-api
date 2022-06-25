class FeedController < ApplicationController
  before_action :authenticate_user!, :set_feed, only: %i[show update destroy]

  # GET /feed.json
  # # TODO: paginated list, for the first iteration this is ok
  def index
    @feeds = Feed.all
    @feeds = @feeds.where(user_id: current_user.id)
    render json: @feeds, each_serializer: FeedSerializer
  end

  # GET /feed/1.json
  def show
    @feed = Feed.find_by(id: params[:id])
    render json: @feed, serializer: FeedSerializer
  end

  # POST /feed or /feed.json
  def create
    permitted_params = feed_params.permit(:description, :title, :uri, :feed_type)
    permitted_params[:uri] = format_feed_uri feed_params
    @feed = Feed.new(permitted_params)
    @feed.user = current_user

    if @feed.save
      render json: @feed, serializer: FeedSerializer
    else
      render json: @feed.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /feed/1.json
  def update
    permitted_params = feed_params.permit(:description, :title, :uri, :feed_type)
    permitted_params[:uri] = format_feed_uri permitted_params

    if @feed.update(permitted_params)
      render json: @feed, serializer: FeedSerializer
    else
      render json: @feed.errors, status: :unprocessable_entity
    end
  end

  # DELETE /feed/1.json
  def destroy
    @feed.destroy

    format.json { head :no_content }
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

  def format_feed_uri(params)
    uri = params[:uri]
    uri = strip_tracking_params uri
    uri = uri[0, uri.rindex('/')] if uri[-1] == '/'
    uri
  end

  def strip_tracking_params(uri)
    result = []
    uri[uri.index('?') + 1, uri.length].split('&').each do |param|
      unless param.index('utm')
        result.push(param)
      end
    end

    uri[0, uri.rindex('?') + 1] + result.join('&')
  end
end

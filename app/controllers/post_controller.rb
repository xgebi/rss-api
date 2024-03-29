##
# Class handling CRUD operations related to posts
#
class PostController < ApplicationController
  before_action :authenticate_user!, :set_post, only: %i[ show edit update destroy ]

  ##
  # Function which gets all posts. Will be removed because of performance issues.
  # Replacement will implement pagination
  #
  # GET /post.json
  def index
    fetch_posts
  end

  ##
  # Function which shows individual posts
  #
  # GET /post/1.json
  def show
    render json: @post, serializer: PostSerializer, status: :ok
  end

  # GET /post/new
  def new
    @post = Post.new
  end

  # GET /post/1/edit
  def edit
  end

  # POST /post or /post.json
  def create
    @post = Post.new(post_params)

    if @post.save
      render json: @post, serializer: PostSerializer, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /post/1.json
  def update
    permitted_params = post_params.permit(:read, :current_time)
    if @post.update(permitted_params)
      render json: @post, serializer: PostSerializer, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /post/1 or /post/1.json
  def destroy
    @post.destroy

    format.json { head :no_content }
  end

  def refresh_posts
    pfs = ProcessFeedService.new(current_user)
    pfs.process_articles if params[:type] == 'article'
    pfs.process_podcasts if params[:type] == 'episode'
    fetch_posts
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id]) if params[:id]
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.fetch(:post, {})
  end

  def fetch_posts
    page = params[:page]
    page ||= 1
    size = params[:size]
    size ||= 30
    @posts = Post.all.where(users: current_user.id, post_type: params[:type]).joins(:article_content).order(pub_date: :desc).page(page).per(size)
    render json: @posts, each_serializer: PostListSerializer
  end
end

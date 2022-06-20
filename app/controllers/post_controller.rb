class PostController < ApplicationController
  before_action :authenticate_user!, :set_post, only: %i[ show edit update destroy ]

  # GET /post or /post.json
  def index
    # TODO pagination,pubDate is probably better than created_at, so both will be addressed after first prototype
    fetch_posts
  end

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
    permitted_params = post_params.permit(:read)
    byebug
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
    pfs.process_articles if params[:type] == 'articles'
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
    @posts = Post.all.where(users: current_user.id, post_type: params[:type]).joins(:article_content).order(pub_date: :desc)
    render json: @posts, each_serializer: PostSerializer
  end
end

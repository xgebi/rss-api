class PostController < ApplicationController
  before_action :authenticate_user!, :set_post, only: %i[ show edit update destroy ]

  # GET /post or /post.json
  def index
    byebug
    # TODO pagination,pubDate is probably better than created_at, so both will be addressed after first prototype
    @posts = Post.all.where(users: current_user.id, post_type: params[:type]).order(created_at: :desc)
    render json: @posts, each_serializer: PostSerializer
  end

  # GET /post/1 or /post/1.json
  def show
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

    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /post/1 or /post/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /post/1 or /post/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def refresh_posts
    pfs = ProcessFeedService.new(current_user)
    pfs.process_articles if params[:type] == 'articles'
    pfs.process_podcasts if params[:type] == 'podcasts'
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
end

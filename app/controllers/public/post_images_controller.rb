class Public::PostImagesController < ApplicationController
before_action :login_check, only: [:new, :index, :show, :edit, :hashtag ]
before_action :side_view, only: [ :new, :index, :show, :edit, :hashtag ]

  # 新規投稿
  def new
    @post_image = PostImage.new
  end

  # 投稿データの保存
  def create
    @post_image = PostImage.new(post_image_params)
    @post_image.user_id = current_user.id
    if @post_image.save
       redirect_to post_images_path
    else
      @post_image = PostImage.new
      @post_categories = PostCategory.all
      @question_categories =QuestionCategory.all
      @hashtags = Hashtag.all.to_a.group_by{ |hashtag| hashtag.post_images.count}
      render :new
    end
  end

  # 投稿一覧
  def index
    @post_images = params[:post_category].present? ? PostCategory.find(params[:post_category]).post_images: PostImage.all
    @hashtags = Hashtag.all.to_a.group_by{ |hashtag| hashtag.post_images.count}
  end

  # 投稿詳細
  def show
    @post_image = PostImage.find(params[:id])
    @user = @post_image.user
    @comment = Comment.new
  end

  # 投稿編集
  def edit
    @post_image = PostImage.find(params[:id])
    if @post_image.user == current_user
      render :edit
    else
      redirect_to post_image_path(@post_image)
    end
  end

  # 投稿更新
  def update
    @post_image = PostImage.find(params[:id])
    if @post_image.update(post_image_params)
       redirect_to post_image_path(@post_image)
    else
       @post_categories = PostCategory.all
       @question_categories =QuestionCategory.all
       @hashtags = Hashtag.all.to_a.group_by{ |hashtag| hashtag.post_images.count}
       render:edit
    end
  end

  # 投稿削除
  def destroy
    @post_image = PostImage.find(params[:id])
    @post_image.destroy
    redirect_to post_images_path
  end

  # ハッシュ
  def hashtag
    @user = current_user
    if params[:name].nil?
      @hashtags = Hashtag.all.to_a.group_by{ |hashtag| hashtag.post_images.count}
    else
      @hashtag = Hashtag.find_by(hashname: params[:name])
      @post_image = @hashtag.post_images.reverse_order
      @hashtags = Hashtag.all.to_a.group_by{ |hashtag| hashtag.post_images.count}
      @post_images = @hashtag.post_images.all
    end

  end

  private

  # 許可
  def post_image_params
    params.require(:post_image).permit(:title, :image, :body, :hashbody, :user_id, :post_category_id)
  end

  # ログインの確認
  def login_check
    unless signed_in?
      redirect_to root_path
    end
  end
  # サイドバー
  def side_view
    @post_categories = PostCategory.all
    @question_categories =QuestionCategory.all
    @hashtags = Hashtag.all.to_a.group_by{ |hashtag| hashtag.post_images.count}
  end

end

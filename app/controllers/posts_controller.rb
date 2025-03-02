class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def index
    matching_posts = Post.all

    @list_of_posts = matching_posts.order({ :created_at => :desc })

    render({ :template => "posts/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_posts = Post.where({ :id => the_id })

    @the_post = matching_posts.at(0)

    render({ :template => "posts/show" })
  end

  def create
    the_post = current_user.posts.build(
      title: params[:query_title],
      body: params[:query_body],
      expires_on: params[:query_expires_on],
      board_id: params[:query_board_id]
    )

    if the_post.save
      redirect_to "/boards/#{the_post.board_id}", notice: "Post created successfully."
    else
      redirect_to "/boards/#{the_post.board_id}", alert: the_post.errors.full_messages.to_sentence
    end

  end

  def update
    the_id = params.fetch("path_id")
    the_post = Post.where({ :id => the_id }).at(0)

    the_post.title = params.fetch("query_title")
    the_post.body = params.fetch("query_body")
    the_post.expires_on = params.fetch("query_expires_on")
    the_post.board_id = params.fetch("query_board_id")

    if the_post.valid?
      the_post.save
      redirect_to("/posts/#{the_post.id}", { :notice => "Post updated successfully."} )
    else
      redirect_to("/posts/#{the_post.id}", { :alert => the_post.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_post = Post.find(params[:path_id])

    if the_post.user == current_user
      the_post.destroy
      redirect_to "/boards/#{the_post.board_id}", notice: "Post deleted successfully."
    else
      redirect_to "/boards/#{the_post.board_id}", alert: "You can only delete your own posts."
    end
  end

end

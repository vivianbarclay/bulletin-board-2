class BoardsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def index
    matching_boards = Board.all

    @list_of_boards = matching_boards.order({ :created_at => :desc })

    render({ :template => "boards/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_boards = Board.where({ :id => the_id })

    @the_board = matching_boards.at(0)

    @matching_posts = Post.where({ :board_id => @the_board.id })

    @active_posts = @matching_posts.where({ :expires_on => (Time.current...) }).order(:expires_on)
    
    @expired_posts = @matching_posts.where.not({ :expires_on => (Time.current...) }).order({ :expires_on => :desc })

    render({ :template => "boards/show" })
  end

  def create
    the_board = current_user.boards.build(name: params[:query_name])

    if the_board.save
      redirect_to "/boards/#{the_board.id}", notice: "Board created successfully."
    else
      redirect_to "/boards", alert: the_board.errors.full_messages.to_sentence
    end

  end

  def update
    the_id = params.fetch("path_id")
    the_board = Board.where({ :id => the_id }).at(0)

    the_board.name = params.fetch("query_name")

    if the_board.valid?
      the_board.save
      redirect_to("/boards/#{the_board.id}", { :notice => "Board updated successfully."} )
    else
      redirect_to("/boards/#{the_board.id}", { :alert => the_board.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_board = Board.find(params[:path_id])

    if the_board.user == current_user
      the_board.destroy
      redirect_to "/boards", notice: "Board deleted successfully."
    else
      redirect_to "/boards", alert: "You are not authorized to delete this board."
    end
  end

end

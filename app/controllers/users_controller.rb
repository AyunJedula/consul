class UsersController < ApplicationController
  has_filters %w{proposals debates comments}, only: :show

  load_and_authorize_resource

  before_action :set_activity_counts, only: :show

  def show
    load_filtered_activity
  end

  private
    def set_activity_counts
      @activity_counts = HashWithIndifferentAccess.new(
                          proposals: Proposal.where(author_id: @user.id).count,
                          debates: Debate.where(author_id: @user.id).count,
                          comments: Comment.where(user_id: @user.id).count)
    end

    def load_filtered_activity
      case params[:filter]
      when "proposals" then load_proposals
      when "debates"   then load_debates
      when "comments"  then load_comments
      else load_available_activity
      end
    end

    def load_available_activity
      if @activity_counts[:proposals] > 0
        load_proposals
        @current_filter = "proposals"
      elsif  @activity_counts[:debates] > 0
        load_debates
        @current_filter = "debates"
      elsif  @activity_counts[:comments] > 0
        load_comments
        @current_filter = "comments"
      end
    end

    def load_proposals
      @proposals = Proposal.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

    def load_debates
      @debates = Debate.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

    def load_comments
      @comments = Comment.where(user_id: @user.id).includes(:commentable).order(created_at: :desc).page(params[:page])
    end

end

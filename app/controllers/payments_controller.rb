class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_pledge

  def new
  end

  def create
    service = Pledges::HandlePayment.new({ stripe_token: params[:stripe_token],
                                           user:         current_user,
                                           pledge:       @pledge
                                        })

    if service.call
      redirect_to @pledge.campaign, notice: "Thanks for completing the payment"
    else
      flash[:alert] = "Error handling payment, please try again."
      render :new
    end
  end

  private

  def find_pledge
    @pledge = Pledge.find params[:pledge_id]
  end
end

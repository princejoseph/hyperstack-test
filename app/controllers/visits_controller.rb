class VisitsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def index
    render json: Visit.order(created_at: :desc).limit(10).map { |v|
      { id: v.id, name: v.name, time: v.created_at.strftime('%H:%M:%S') }
    }
  end

  def create
    name = params[:name].to_s.strip
    name = 'Anonymous' if name.empty?
    visit = Visit.create!(name: name.first(50))
    render json: { id: visit.id, name: visit.name, time: visit.created_at.strftime('%H:%M:%S') }
  end
end

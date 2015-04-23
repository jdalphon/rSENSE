class VislogsController < ApplicationController
  before_action :set_vislog, only: [:show, :edit, :update, :destroy]

  # GET /vislogs
  def index
    @vislogs = Vislog.all
  end

  # GET /vislogs/1
  def show
  end

  # GET /vislogs/new
  def new
    @vislog = Vislog.new
  end

  # GET /vislogs/1/edit
  def edit
  end

  # POST /vislogs
  def create
    @vislog = Vislog.new(vislog_params)

    if @vislog.save
      redirect_to @vislog, notice: 'Vislog was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /vislogs/1
  def update
    if @vislog.update(vislog_params)
      redirect_to @vislog, notice: 'Vislog was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /vislogs/1
  def destroy
    @vislog.destroy
    redirect_to vislogs_url, notice: 'Vislog was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vislog
      @vislog = Vislog.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def vislog_params
      params.require(:vislog).permit(:data, :visualization_id, :user_id)
    end
end

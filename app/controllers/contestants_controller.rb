class ContestantsController < ApplicationController
  before_action :set_contestant, only: [:show, :edit, :update, :destroy, :reactivate]

  # GET /contestants
  # GET /contestants.json
  def index
    @contestants = Contestant.order('id')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contestants }
    end
  end

  # GET /contestants/1
  # GET /contestants/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contestant }
    end
  end

  # GET /contestants/new
  # GET /contestants/new.json
  def new
    @contestant = Contestant.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contestant }
    end
  end

  # GET /contestants/1/edit
  def edit
  end

  # POST /contestants
  # POST /contestants.json
  def create
    @contestant = Contestant.new(contestant_params)

    respond_to do |format|
      if @contestant.save
        format.html { redirect_to new_contestant_path, notice: "#{@contestant.name} has been registered." }
        format.json { render json: @contestant, status: :created, location: @contestant }
      else
        format.html { render action: "new" }
        format.json { render json: @contestant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contestants/1
  # PATCH/PUT /contestants/1.json
  def update
    respond_to do |format|
      if @contestant.update(contestant_params)
        format.html { redirect_to contestants_path, notice: "#{@contestant.name} was updated" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contestant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contestants/1
  # DELETE /contestants/1.json
  def destroy
    @contestant.retire

    respond_to do |format|
      format.html { redirect_to contestants_path, notice: "#{@contestant.name} has retired" }
      format.json { head :no_content }
    end
  end

  # POST /contestants/1
  # DELETE /contestants/1.json
  def reactivate
    @contestant.reactivate

    respond_to do |format|
      format.html { redirect_to contestants_path, notice: "#{@contestant.name} was reactivated" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contestant
      @contestant = Contestant.find(params[:id])
    end

    # Use this method to whitelist the permissible parameters. Example:
    #   params.require(:person).permit(:name, :age)
    #
    # Also, you can specialize this method with per-user checking of permissible
    # attributes.
    def contestant_params
      params.require(:contestant).permit(:name, :retired)
    end
end

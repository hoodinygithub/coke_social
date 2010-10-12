class Admin::ValidTagsController < Admin::ApplicationController
  before_filter :find_valid_tag, :except => [:index, :new, :create]
  
  def index
    if params[:search]
      search = params[:search]
      conditions = [["tags.name like ?", "#{search[:tag_name]}%"]]
      conditions << ["site_id = ?", search[:market]] unless search[:market].to_s.empty?
      conditions << ["deleted_at IS NOT ?", nil] if search[:deleted_at]
      conditions = [conditions.map{|c| c.first}.join(" AND "), *conditions.map{|c| c.last}]
      @valid_tags = ValidTag.all_with_deleted(:conditions => conditions, :include => [:tag, :site])
    else
      @valid_tags = ValidTag.all_with_deleted(:include => [:tag, :site])
    end
    @valid_tag = ValidTag.new(params[:valid_tag])    
  end
  
  def new
    @valid_tag = ValidTag.new(params[:valid_tag])
  end
  
  def create
    @valid_tag = ValidTag.new(params[:valid_tag])
    if @valid_tag.save
      flash[:notice] = "Tag added to the list of valid tags"      
      redirect_to admin_valid_tags_path
    else
      render :new
    end    
  end
  
  # def edit
  #   render :new
  # end
  # 
  # def update
  #   if @valid_tag.update_attributes(params[:valid_tag])
  #     flash[:notice] = "Valid Tag updated"
  #     redirect_to admin_valid_tags_path      
  #   else
  #     render :new      
  #   end
  # end
  
  def destroy
    @valid_tag.mark_as_deleted
    redirect_to admin_valid_tags_path
  end
  
  def restore
    @valid_tag.unmark_as_deleted
    redirect_to admin_valid_tags_path
  end  
  
private
  def find_valid_tag
    @valid_tag = ValidTag.find_with_deleted(params[:id])
  end
end


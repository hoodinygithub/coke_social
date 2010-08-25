module TagsHelper
  def tag_cloud(tags, classes)
    return if tags.empty?
    
    tags.delete_if{|tag| !current_site.tag_ids.include?(tag.id) }
    
    max_count = tags.sort_by(&:taggings_count).last.taggings_count.to_f
    
    tags.each_with_index do |tag, index|
      idx = ((tag.taggings_count / max_count) * (classes.size - 1)).round
      yield tag, classes[idx], index
    end
  end
end

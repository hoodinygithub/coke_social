module TagsHelper
  def tag_cloud(tags, classes)
    return if tags.empty?
    
    max_count = tags.sort_by(&:count).last.count.to_f
    
    tags.each_with_index do |tag, index|
      idx = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[idx], index
    end
  end
end

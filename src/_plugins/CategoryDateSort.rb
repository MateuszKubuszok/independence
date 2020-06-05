module Jekyll
  module CategoryDateSort
    def sort_cat_by_newest(input)
      input.sort_by { |cat| cat[1].max_by { |e| e.date } }.reverse
    end
  end
end

Liquid::Template.register_filter(Jekyll::CategoryDateSort)

# -*- encoding : utf-8 -*-

class Hash

   # Strip all string and remove any blank strings
   def remove_blank!
    each do |k, v|
      if self[k].is_a? String
        self[k] = v.strip
        delete(k) if self[k].empty?
      end
    end
  end

end
